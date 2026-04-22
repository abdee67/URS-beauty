import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/http.ts";
import {
  logPaymentEvent,
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
    const paymentId = String(body.payment_id ?? "").trim();
    if (!paymentId) {
      return errorResponse("payment_id is required.");
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
    const { data: refundQuote, error: refundError } = await userClient.rpc(
      "calculate_refund_quote",
      { p_payment_id: paymentId },
    );

    if (refundError || !refundQuote) {
      return errorResponse(
        "Failed to calculate the refund amount.",
        400,
        refundError?.message,
      );
    }

    const refundableAmount = Number(refundQuote.refundable_amount ?? 0);
    if (!Number.isFinite(refundableAmount) || refundableAmount <= 0) {
      return errorResponse("This payment is not eligible for a refund.", 400);
    }

    const { data: payment, error: paymentError } = await adminClient
      .from("payments")
      .select("*")
      .eq("id", paymentId)
      .eq("customer_id", user.id)
      .single();

    if (paymentError || !payment) {
      return errorResponse("Payment not found.", 404, paymentError?.message);
    }

    if (!payment.stripe_payment_intent_id) {
      return errorResponse(
        "This payment cannot be refunded because it is missing the Stripe payment intent reference.",
        400,
      );
    }

    const stripeRefund = await stripe.refunds.create(
      {
        payment_intent: payment.stripe_payment_intent_id,
        amount: toMinorUnits(refundableAmount, String(payment.currency ?? "etb")),
        metadata: {
          booking_id: payment.booking_id,
          payment_id: payment.id,
        },
      },
      {
        idempotencyKey:
          `refund:${payment.id}:${payment.refunded_amount ?? 0}:${refundableAmount}`,
      },
    );

    const nextRefundedAmount =
      Number(payment.refunded_amount ?? 0) + refundableAmount;
    const nextStatus = nextRefundedAmount >= Number(payment.amount)
      ? "refunded"
      : "partially_refunded";
    const bookingPaymentStatus = nextStatus === "refunded"
      ? "refunded"
      : "partial_refunded";

    const { data: updatedPayment, error: updateError } = await adminClient
      .from("payments")
      .update({
        status: nextStatus,
        refunded_amount: nextRefundedAmount,
        refundable_amount: Math.max(
          Number(payment.amount) - nextRefundedAmount,
          0,
        ),
        verified_at: new Date().toISOString(),
        metadata: {
          ...(payment.metadata ?? {}),
          last_refund_id: stripeRefund.id,
        },
      })
      .eq("id", payment.id)
      .select("*")
      .single();

    if (updateError || !updatedPayment) {
      return errorResponse(
        "Failed to persist the refund result.",
        500,
        updateError?.message,
      );
    }

    await adminClient.from("bookings").update({
      payment_status: bookingPaymentStatus,
      refund_amount: nextRefundedAmount,
      updated_at: new Date().toISOString(),
    }).eq("id", payment.booking_id);

    await logPaymentEvent(adminClient, {
      paymentId: payment.id,
      bookingId: payment.booking_id,
      actorId: user.id,
      eventType: "refund_processed",
      payload: {
        stripe_refund_id: stripeRefund.id,
        refunded_amount: refundableAmount,
        payment_status: nextStatus,
      },
    });

    return jsonResponse({
      payment: updatedPayment,
      refund_quote: refundQuote,
    });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      500,
    );
  }
});
