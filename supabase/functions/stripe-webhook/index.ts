import Stripe from "npm:stripe@18.4.0";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/http.ts";
import {
  fromMinorUnits,
  logPaymentEvent,
  mapPaymentStatusToBookingStatus,
  resolveIntentPaymentStatus,
  settleCompletedBookingPayment,
} from "../_shared/payments.ts";
import { getStripe } from "../_shared/stripe.ts";
import { createAdminClient } from "../_shared/supabase.ts";

function requireWebhookSecret(): string {
  const secret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!secret) {
    throw new Error("STRIPE_WEBHOOK_SECRET is not configured.");
  }
  return secret;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return errorResponse("Method not allowed.", 405);
  }

  try {
    const stripe = getStripe();
    const webhookSecret = requireWebhookSecret();
    const signature = request.headers.get("stripe-signature");
    if (!signature) {
      return errorResponse("Missing stripe-signature header.", 400);
    }

    const rawBody = await request.text();
    const event = await stripe.webhooks.constructEventAsync(
      rawBody,
      signature,
      webhookSecret,
      undefined,
      Stripe.createSubtleCryptoProvider(),
    );

    const adminClient = createAdminClient();

    if (event.type === "payment_intent.succeeded" ||
        event.type === "payment_intent.payment_failed" ||
        event.type === "payment_intent.canceled") {
      const intent = event.data.object as Stripe.PaymentIntent;
      const { data: payment } = await adminClient
        .from("payments")
        .select("*")
        .eq("stripe_payment_intent_id", intent.id)
        .maybeSingle();

      if (!payment) {
        return jsonResponse({ received: true, skipped: true });
      }

      const paymentStatus = resolveIntentPaymentStatus(intent);
      const bookingPaymentStatus = mapPaymentStatusToBookingStatus(paymentStatus);
      const paidAmount = paymentStatus === "succeeded"
        ? Number(payment.amount ?? 0)
        : 0;
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

      await adminClient.from("payments").update({
        status: paymentStatus,
        transaction_reference: intent.id,
        failure_reason: intent.last_payment_error?.message ?? null,
        paid_at: paymentStatus === "succeeded" ? new Date().toISOString() : null,
        verified_at: new Date().toISOString(),
        metadata: {
          ...(payment.metadata ?? {}),
          stripe_event_id: event.id,
          stripe_status: intent.status,
        },
      }).eq("id", payment.id);

      if (paymentStatus === "succeeded") {
        settlement = await settleCompletedBookingPayment(adminClient, {
          paymentId: payment.id,
          bookingId: payment.booking_id,
          customerId: payment.customer_id,
          paymentAmount: Number(payment.amount ?? paidAmount),
          currency: String(payment.currency ?? "etb"),
          transactionReference: intent.id,
          paymentMethod: "card",
        });
      } else {
        await adminClient.from("bookings").update({
          payment_method: "card",
          payment_status: bookingPaymentStatus,
          paid_amount: paidAmount,
          updated_at: new Date().toISOString(),
        }).eq("id", payment.booking_id);
      }

      await logPaymentEvent(adminClient, {
        paymentId: payment.id,
        bookingId: payment.booking_id,
        actorId: payment.customer_id,
        eventType: event.type,
        payload: {
          stripe_event_id: event.id,
          stripe_payment_intent_id: intent.id,
          payment_status: paymentStatus,
          commission_amount: settlement?.commissionAmount ?? null,
          stylist_earning: settlement?.stylistEarning ?? null,
          wallet_transaction_id: settlement?.walletTransactionId ?? null,
          settlement_applied: settlement?.settlementApplied ?? false,
        },
      });

      return jsonResponse({ received: true });
    }

    if (event.type === "charge.refunded") {
      const charge = event.data.object as Stripe.Charge;
      if (!charge.payment_intent) {
        return jsonResponse({ received: true, skipped: true });
      }

      const paymentIntentId = typeof charge.payment_intent === "string"
        ? charge.payment_intent
        : charge.payment_intent.id;

      const { data: payment } = await adminClient
        .from("payments")
        .select("*")
        .eq("stripe_payment_intent_id", paymentIntentId)
        .maybeSingle();

      if (!payment) {
        return jsonResponse({ received: true, skipped: true });
      }

      const refundedAmount = fromMinorUnits(
        charge.amount_refunded,
        charge.currency,
      );
      const paymentStatus = refundedAmount >= Number(payment.amount)
        ? "refunded"
        : "partially_refunded";
      const bookingPaymentStatus = paymentStatus === "refunded"
        ? "refunded"
        : "partial_refunded";

      await adminClient.from("payments").update({
        status: paymentStatus,
        refunded_amount: refundedAmount,
        refundable_amount: Math.max(Number(payment.amount) - refundedAmount, 0),
        verified_at: new Date().toISOString(),
        metadata: {
          ...(payment.metadata ?? {}),
          stripe_event_id: event.id,
          last_refund_charge_id: charge.id,
        },
      }).eq("id", payment.id);

      await adminClient.from("bookings").update({
        payment_status: bookingPaymentStatus,
        refund_amount: refundedAmount,
        updated_at: new Date().toISOString(),
      }).eq("id", payment.booking_id);

      await logPaymentEvent(adminClient, {
        paymentId: payment.id,
        bookingId: payment.booking_id,
        actorId: payment.customer_id,
        eventType: event.type,
        payload: {
          stripe_event_id: event.id,
          refunded_amount: refundedAmount,
          charge_id: charge.id,
        },
      });

      return jsonResponse({ received: true });
    }

    return jsonResponse({ received: true, ignored: true });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      400,
    );
  }
});
