import { corsHeaders } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { logPaymentEvent, toMinorUnits } from "../_shared/payments.ts";
import { getStripe } from "../_shared/stripe.ts";
import { createAdminClient, createUserClient } from "../_shared/supabase.ts";

const bookingColumns =
  "id, customer, stylist, status, is_reviewed, rescheduled_from, " +
  "rescheduled_count, notes, address, total_amount, scheduled_at, end_at, " +
  "created_at, updated_at, payment_method, payment_status, currency, " +
  "paid_amount, refund_amount, stylist_profile:stylists(business_name), " +
  "booked_services:booking_services(service_name)";

function normalizeReason(value: unknown): string {
  const reason = String(value ?? "booking_cancelled").trim();
  return reason.length === 0 ? "booking_cancelled" : reason;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = request.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse("Authentication required.", 401);
    }

    const body = await request.json().catch(() => ({}));
    const bookingId = String(body.booking_id ?? "").trim();
    const reason = normalizeReason(body.reason);
    if (!bookingId) {
      return errorResponse("booking_id is required.");
    }

    const userClient = createUserClient(authHeader);
    const adminClient = createAdminClient();
    const stripe = getStripe();

    const { data: userResult, error: userError } = await userClient.auth
      .getUser();
    if (userError || !userResult.user) {
      return errorResponse("Authentication required.", 401, userError?.message);
    }

    const user = userResult.user;
    const { data: booking, error: bookingError } = await userClient
      .from("bookings")
      .select(
        "id, customer, status, payment_status, payment_method, total_amount, currency, refund_amount",
      )
      .eq("id", bookingId)
      .single();

    if (bookingError || !booking) {
      return errorResponse("Booking not found.", 404, bookingError?.message);
    }

    if (booking.customer !== user.id) {
      return errorResponse("Booking does not belong to the current user.", 403);
    }

    if (booking.status === "completed" || booking.status === "no_show") {
      return errorResponse("This booking can no longer be cancelled.", 400);
    }

    let nextPaymentStatus = String(booking.payment_status ?? "pending");
    let nextRefundAmount = Number(booking.refund_amount ?? 0);

    const { data: successfulPayment } = await adminClient
      .from("payments")
      .select("*")
      .eq("booking_id", bookingId)
      .eq("customer_id", user.id)
      .eq("payment_type", "payment")
      .in("status", ["succeeded", "partially_refunded", "refunded"])
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (successfulPayment) {
      const { data: refundQuote, error: refundError } = await userClient.rpc(
        "calculate_refund_quote",
        { p_payment_id: successfulPayment.id },
      );

      if (refundError || !refundQuote) {
        return errorResponse(
          "Failed to calculate the refund amount.",
          400,
          refundError?.message,
        );
      }

      const refundableAmount = Number(refundQuote.refundable_amount ?? 0);
      if (refundableAmount > 0) {
        if (!successfulPayment.stripe_payment_intent_id) {
          return errorResponse(
            "The successful payment is missing the Stripe payment intent reference.",
            400,
          );
        }

        const stripeRefund = await stripe.refunds.create(
          {
            payment_intent: successfulPayment.stripe_payment_intent_id,
            amount: toMinorUnits(
              refundableAmount,
              String(successfulPayment.currency ?? "etb"),
            ),
            reason: "requested_by_customer",
            metadata: {
              booking_id: bookingId,
              payment_id: successfulPayment.id,
              cancellation_reason: reason,
            },
          },
          {
            idempotencyKey:
              `cancel-booking-refund:${successfulPayment.id}:${successfulPayment.refunded_amount ?? 0}:${refundableAmount}`,
          },
        );

        const nextRefundedAmount =
          Number(successfulPayment.refunded_amount ?? 0) + refundableAmount;
        const paymentStatus = nextRefundedAmount >=
            Number(successfulPayment.amount ?? 0)
          ? "refunded"
          : "partially_refunded";

        const { error: paymentUpdateError } = await adminClient
          .from("payments")
          .update({
            status: paymentStatus,
            refunded_amount: nextRefundedAmount,
            refundable_amount: Math.max(
              Number(successfulPayment.amount ?? 0) - nextRefundedAmount,
              0,
            ),
            verified_at: new Date().toISOString(),
            metadata: {
              ...(successfulPayment.metadata ?? {}),
              last_refund_id: stripeRefund.id,
              cancelled_booking: true,
            },
          })
          .eq("id", successfulPayment.id);

        if (paymentUpdateError) {
          return errorResponse(
            "Failed to persist the refund result.",
            500,
            paymentUpdateError.message,
          );
        }

        nextPaymentStatus = paymentStatus === "refunded"
          ? "refunded"
          : "partial_refunded";
        nextRefundAmount = nextRefundedAmount;

        await logPaymentEvent(adminClient, {
          paymentId: successfulPayment.id,
          bookingId,
          actorId: user.id,
          eventType: "booking_cancelled_refund_processed",
          payload: {
            stripe_refund_id: stripeRefund.id,
            refunded_amount: refundableAmount,
            payment_status: paymentStatus,
            cancellation_reason: reason,
          },
        });
      } else {
        nextPaymentStatus = successfulPayment.status === "refunded"
          ? "refunded"
          : successfulPayment.status === "partially_refunded"
          ? "partial_refunded"
          : "paid";

        await adminClient.from("payments").update({
          refundable_amount: refundableAmount,
          verified_at: new Date().toISOString(),
          metadata: {
            ...(successfulPayment.metadata ?? {}),
            cancelled_booking: true,
          },
        }).eq("id", successfulPayment.id);

        await logPaymentEvent(adminClient, {
          paymentId: successfulPayment.id,
          bookingId,
          actorId: user.id,
          eventType: "booking_cancelled_refund_skipped",
          payload: {
            refundable_amount: refundableAmount,
            cancellation_reason: reason,
          },
        });
      }
    } else {
      const { data: pendingPayment } = await adminClient
        .from("payments")
        .select("*")
        .eq("booking_id", bookingId)
        .eq("customer_id", user.id)
        .eq("payment_type", "payment")
        .in("status", [
          "pending",
          "processing",
          "requires_action",
          "pending_verification",
        ])
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (pendingPayment) {
        if (pendingPayment.stripe_payment_intent_id) {
          const intent = await stripe.paymentIntents.retrieve(
            pendingPayment.stripe_payment_intent_id,
          );

          if (
            !["canceled", "succeeded"].includes(intent.status)
          ) {
            await stripe.paymentIntents.cancel(
              pendingPayment.stripe_payment_intent_id,
              { cancellation_reason: "requested_by_customer" },
            );
          }
        }

        const { error: paymentUpdateError } = await adminClient
          .from("payments")
          .update({
            status: "cancelled",
            failure_reason: reason,
            verified_at: new Date().toISOString(),
          })
          .eq("id", pendingPayment.id);

        if (paymentUpdateError) {
          return errorResponse(
            "Failed to cancel the pending payment.",
            500,
            paymentUpdateError.message,
          );
        }

        nextPaymentStatus = "failed";

        await logPaymentEvent(adminClient, {
          paymentId: pendingPayment.id,
          bookingId,
          actorId: user.id,
          eventType: "booking_cancelled_pending_payment_closed",
          payload: { cancellation_reason: reason },
        });
      }
    }

    const { data: updatedBooking, error: updateBookingError } = await adminClient
      .from("bookings")
      .update({
        status: "cancelled",
        payment_status: nextPaymentStatus,
        refund_amount: nextRefundAmount,
        updated_at: new Date().toISOString(),
      })
      .eq("id", bookingId)
      .eq("customer", user.id)
      .select(bookingColumns)
      .single();

    if (updateBookingError || !updatedBooking) {
      return errorResponse(
        "Failed to cancel the booking.",
        500,
        updateBookingError?.message,
      );
    }

    return jsonResponse({
      booking: updatedBooking,
      booking_status: updatedBooking.status,
      booking_payment_status: updatedBooking.payment_status,
      refund_amount: updatedBooking.refund_amount,
    });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      500,
    );
  }
});
