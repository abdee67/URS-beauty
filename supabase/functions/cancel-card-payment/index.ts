import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/http.ts";
import { findOwnedPayment, logPaymentEvent } from "../_shared/payments.ts";
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
    const reason = String(body.reason ?? "payment_cancelled").trim();
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

    if (["succeeded", "refunded", "partially_refunded"].includes(payment.status)) {
      return jsonResponse({ payment });
    }

    if (payment.stripe_payment_intent_id) {
      const intent = await stripe.paymentIntents.retrieve(
        payment.stripe_payment_intent_id,
      );

      if (!["canceled", "succeeded"].includes(intent.status)) {
        await stripe.paymentIntents.cancel(payment.stripe_payment_intent_id);
      }
    }

    const { data: updatedPayment, error: updateError } = await adminClient
      .from("payments")
      .update({
        status: "cancelled",
        failure_reason: reason,
        verified_at: new Date().toISOString(),
      })
      .eq("id", payment.id)
      .select("*")
      .single();

    if (updateError || !updatedPayment) {
      return errorResponse(
        "Failed to cancel the payment.",
        500,
        updateError?.message,
      );
    }

    await adminClient.from("bookings").update({
      status: "cancelled",
      payment_status: "failed",
      updated_at: new Date().toISOString(),
    }).eq("id", payment.booking_id);

    await logPaymentEvent(adminClient, {
      paymentId: payment.id,
      bookingId: payment.booking_id,
      actorId: user.id,
      eventType: "payment_cancelled",
      payload: { reason },
    });

    return jsonResponse({
      payment: updatedPayment,
      booking_status: "cancelled",
      booking_payment_status: "failed",
    });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      500,
    );
  }
});
