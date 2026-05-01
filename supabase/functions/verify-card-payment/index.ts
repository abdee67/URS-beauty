import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/http.ts";
import {
  findOwnedPayment,
  logPaymentEvent,
  mapPaymentStatusToBookingStatus,
  resolveIntentPaymentStatus,
  settleCompletedBookingPayment,
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
    const paymentReference = String(body.payment_reference ?? "").trim();
    if (!paymentReference) {
      return errorResponse("payment_reference is required.");
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
    const { data: payment, error: paymentError } = await findOwnedPayment(
      adminClient,
      user.id,
      paymentReference,
    );

    if (paymentError || !payment) {
      return errorResponse("Payment not found.", 404, paymentError?.message);
    }

    if (!payment.stripe_payment_intent_id) {
      return jsonResponse({ payment });
    }

    const intent = await stripe.paymentIntents.retrieve(
      payment.stripe_payment_intent_id,
    );
    const paymentStatus = resolveIntentPaymentStatus(intent);
    const bookingPaymentStatus = mapPaymentStatusToBookingStatus(paymentStatus);
    const bookingPaidAmount = paymentStatus === "succeeded" ? payment.amount : 0;
    let settlement:
      | {
          commissionAmount: number;
          stylistEarning: number;
          walletId: string | null;
          walletTransactionId: string | null;
          walletBalance: number | null;
          settlementApplied: boolean;
        }
      | null = null;

    const { data: updatedPayment, error: updateError } = await adminClient
      .from("payments")
      .update({
        status: paymentStatus,
        transaction_reference: intent.id,
        failure_reason: intent.last_payment_error?.message ?? null,
        paid_at: paymentStatus === "succeeded" ? new Date().toISOString() : null,
        verified_at: new Date().toISOString(),
        metadata: {
          ...(payment.metadata ?? {}),
          stripe_status: intent.status,
        },
      })
      .eq("id", payment.id)
      .select("*")
      .single();

    if (updateError || !updatedPayment) {
      return errorResponse(
        "Failed to update the payment record.",
        500,
        updateError?.message,
      );
    }

    if (paymentStatus === "succeeded") {
      settlement = await settleCompletedBookingPayment(adminClient, {
        paymentId: payment.id,
        bookingId: payment.booking_id,
        customerId: user.id,
        paymentAmount: Number(payment.amount ?? bookingPaidAmount),
        currency: String(payment.currency ?? "etb"),
        transactionReference: intent.id,
        paymentMethod: "card",
      });
    } else {
      await adminClient.from("bookings").update({
        payment_method: "card",
        payment_status: bookingPaymentStatus,
        paid_amount: bookingPaidAmount,
        updated_at: new Date().toISOString(),
      }).eq("id", payment.booking_id);
    }

    await logPaymentEvent(adminClient, {
      paymentId: payment.id,
      bookingId: payment.booking_id,
      actorId: user.id,
      eventType: "payment_verified",
      payload: {
        stripe_payment_intent_id: intent.id,
        stripe_status: intent.status,
        payment_status: paymentStatus,
        commission_amount: settlement?.commissionAmount ?? null,
        stylist_earning: settlement?.stylistEarning ?? null,
        wallet_transaction_id: settlement?.walletTransactionId ?? null,
        settlement_applied: settlement?.settlementApplied ?? false,
      },
    });

    return jsonResponse({
      payment: updatedPayment,
      booking_payment_status: bookingPaymentStatus,
      booking_status: "completed",
    });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      500,
    );
  }
});
