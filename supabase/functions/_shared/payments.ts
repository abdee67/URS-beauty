import Stripe from "npm:stripe@18.4.0";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2.49.8";

const zeroDecimalCurrencies = new Set([
  "bif",
  "clp",
  "djf",
  "gnf",
  "jpy",
  "kmf",
  "krw",
  "mga",
  "pyg",
  "rwf",
  "ugx",
  "vnd",
  "vuv",
  "xaf",
  "xof",
  "xpf",
]);

export function toMinorUnits(amount: number, currency: string): number {
  const normalizedCurrency = currency.toLowerCase();
  if (zeroDecimalCurrencies.has(normalizedCurrency)) {
    return Math.round(amount);
  }

  return Math.round(amount * 100);
}

export function fromMinorUnits(amount: number, currency: string): number {
  const normalizedCurrency = currency.toLowerCase();
  if (zeroDecimalCurrencies.has(normalizedCurrency)) {
    return amount;
  }

  return amount / 100;
}

export function mapIntentStatus(status: Stripe.PaymentIntent.Status): string {
  switch (status) {
    case "processing":
      return "processing";
    case "requires_action":
      return "requires_action";
    case "succeeded":
      return "succeeded";
    case "canceled":
      return "cancelled";
    case "requires_payment_method":
    case "requires_confirmation":
      return "pending";
    default:
      return "pending";
  }
}

export function resolveIntentPaymentStatus(
  intent: Stripe.PaymentIntent,
): string {
  if (intent.status === "requires_payment_method" && intent.last_payment_error) {
    return "failed";
  }

  return mapIntentStatus(intent.status);
}

export function mapPaymentStatusToBookingStatus(status: string): string {
  switch (status) {
    case "succeeded":
      return "paid";
    case "refunded":
      return "refunded";
    case "partially_refunded":
      return "partial_refunded";
    case "failed":
      return "failed";
    default:
      return "pending";
  }
}

export async function logPaymentEvent(
  adminClient: SupabaseClient,
  {
    paymentId,
    bookingId,
    actorId,
    eventType,
    payload = {},
  }: {
    paymentId: string;
    bookingId: string;
    actorId?: string | null;
    eventType: string;
    payload?: Record<string, unknown>;
  },
) {
  await adminClient.from("payment_audit_logs").insert({
    payment_id: paymentId,
    booking_id: bookingId,
    actor_id: actorId ?? null,
    event_type: eventType,
    payload,
  });
}

export function looksLikeUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}

export async function findOwnedPayment(
  adminClient: SupabaseClient,
  customerId: string,
  paymentReference: string,
) {
  if (looksLikeUuid(paymentReference)) {
    const byId = await adminClient
      .from("payments")
      .select("*")
      .eq("customer_id", customerId)
      .eq("id", paymentReference)
      .maybeSingle();

    if (byId.data) {
      return byId;
    }
  }

  return await adminClient
    .from("payments")
    .select("*")
    .eq("customer_id", customerId)
    .eq("transaction_reference", paymentReference)
    .maybeSingle();
}
