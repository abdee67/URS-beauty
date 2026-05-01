import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/http.ts";
import {
  logPaymentEvent,
  resolveIntentPaymentStatus,
  settleCompletedBookingPayment,
  toMinorUnits,
} from "../_shared/payments.ts";
import { getStripe } from "../_shared/stripe.ts";
import { createAdminClient, createUserClient } from "../_shared/supabase.ts";

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
        "id, customer, status, total_amount, currency, payment_status, payment_method, paid_amount, commission_amount, stylist_earning",
      )
      .eq("id", bookingId)
      .single();

    if (bookingError || !booking) {
      return errorResponse("Booking not found.", 404, bookingError?.message);
    }

    if (booking.customer !== user.id) {
      return errorResponse("Booking does not belong to the current user.", 403);
    }

    if (booking.status !== "completed") {
      return errorResponse(
        "Only completed bookings can be charged after service.",
        400,
      );
    }

    if (booking.payment_status === "paid") {
      return errorResponse("This booking has already been paid.", 409);
    }

    const amount = Number(booking.total_amount ?? 0);
    if (!Number.isFinite(amount) || amount <= 0) {
      return errorResponse("Invalid booking amount.", 400);
    }

    const existingPending = await adminClient
      .from("payments")
      .select("*")
      .eq("booking_id", bookingId)
      .eq("customer_id", user.id)
      .eq("payment_method", "card")
      .eq("payment_type", "payment")
      .in("status", [
        "pending",
        "processing",
        "requires_action",
        "pending_verification",
      ])
      .order("created_at", { ascending: false })
      .limit(1);

    if (existingPending.error) {
      return errorResponse(
        "Failed to inspect existing payment attempts.",
        500,
        existingPending.error.message,
      );
    }

    const reusablePayment = existingPending.data?.[0] ?? null;
    if (reusablePayment?.stripe_payment_intent_id) {
      const intent = await stripe.paymentIntents.retrieve(
        reusablePayment.stripe_payment_intent_id,
      );
      const paymentStatus = resolveIntentPaymentStatus(intent);

      const { data: refreshedPayment, error: refreshError } = await adminClient
        .from("payments")
        .update({
          status: paymentStatus,
          transaction_reference: intent.id,
          failure_reason: intent.last_payment_error?.message ?? null,
        })
        .eq("id", reusablePayment.id)
        .select("*")
        .single();

      if (refreshError) {
        return errorResponse(
          "Failed to refresh the existing payment attempt.",
          500,
          refreshError.message,
        );
      }

      if (paymentStatus === "succeeded") {
        await settleCompletedBookingPayment(adminClient, {
          paymentId: refreshedPayment.id,
          bookingId: booking.id,
          customerId: user.id,
          paymentAmount: amount,
          currency: String(booking.currency ?? "etb"),
          transactionReference: intent.id,
          paymentMethod: "card",
        });
      }

      if (!["failed", "cancelled", "refunded", "partially_refunded"].includes(
        paymentStatus,
      )) {
        return jsonResponse({
          payment: refreshedPayment,
          payment_intent_client_secret: intent.client_secret,
          booking_status: booking.status,
          booking_payment_status:
            paymentStatus === "succeeded" ? "paid" : "pending",
        });
      }
    }

    const idempotencyKey = crypto.randomUUID();
    const { data: insertedPayment, error: insertError } = await adminClient
      .from("payments")
      .insert({
        booking_id: booking.id,
        customer_id: user.id,
        payment_method: "card",
        payment_type: "payment",
        status: "pending",
        amount,
        currency: String(booking.currency ?? "ETB").toLowerCase(),
        idempotency_key: idempotencyKey,
        transaction_reference: idempotencyKey,
        metadata: body.metadata ?? {},
      })
      .select("*")
      .single();

    if (insertError || !insertedPayment) {
      return errorResponse(
        "Failed to create a payment record.",
        500,
        insertError?.message,
      );
    }

    const intent = await stripe.paymentIntents.create(
      {
        amount: toMinorUnits(amount, String(booking.currency ?? "ETB")),
        currency: String(booking.currency ?? "ETB").toLowerCase(),
        automatic_payment_methods: { enabled: true },
        description: `URS Beauty booking ${booking.id}`,
        metadata: {
          booking_id: booking.id,
          payment_id: insertedPayment.id,
          customer_id: user.id,
          payment_type: "payment",
        },
        receipt_email: user.email ?? undefined,
      },
      { idempotencyKey },
    );

    const paymentStatus = resolveIntentPaymentStatus(intent);
    const { data: updatedPayment, error: updateError } = await adminClient
      .from("payments")
      .update({
        status: paymentStatus,
        stripe_payment_intent_id: intent.id,
        transaction_reference: intent.id,
        failure_reason: intent.last_payment_error?.message ?? null,
        metadata: {
          ...(insertedPayment.metadata ?? {}),
          stripe_status: intent.status,
        },
      })
      .eq("id", insertedPayment.id)
      .select("*")
      .single();

    if (updateError || !updatedPayment) {
      return errorResponse(
        "Failed to update the payment record.",
        500,
        updateError?.message,
      );
    }

    await adminClient.from("bookings").update({
      payment_method: "card",
      payment_status: "pending",
      updated_at: new Date().toISOString(),
    }).eq("id", booking.id);

    await logPaymentEvent(adminClient, {
      paymentId: updatedPayment.id,
      bookingId: booking.id,
      actorId: user.id,
      eventType: "payment_intent_created",
      payload: {
        stripe_payment_intent_id: intent.id,
        payment_status: paymentStatus,
      },
    });

    return jsonResponse({
      payment: updatedPayment,
      payment_intent_client_secret: intent.client_secret,
      booking_status: booking.status,
      booking_payment_status: "pending",
    });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      500,
    );
  }
});
