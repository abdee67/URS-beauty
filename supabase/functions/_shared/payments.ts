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

const PLATFORM_COMMISSION_RATE = 0.15;

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

export function roundMoney(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

export function calculateCommissionSplit(totalAmount: number) {
  const commissionAmount = roundMoney(totalAmount * PLATFORM_COMMISSION_RATE);
  const stylistEarning = roundMoney(totalAmount - commissionAmount);

  return {
    commissionAmount,
    stylistEarning,
  };
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

export async function settleCompletedBookingPayment(
  adminClient: SupabaseClient,
  {
    paymentId,
    bookingId,
    customerId,
    paymentAmount,
    currency,
    transactionReference,
    paymentMethod,
  }: {
    paymentId: string;
    bookingId: string;
    customerId?: string | null;
    paymentAmount: number;
    currency: string;
    transactionReference?: string | null;
    paymentMethod: string;
  },
) {
  const { data: booking, error: bookingError } = await adminClient
    .from("bookings")
    .select(
      "id, stylist, status, payment_status, paid_amount, commission_amount, stylist_earning, currency",
    )
    .eq("id", bookingId)
    .single();

  if (bookingError || !booking) {
    throw new Error(bookingError?.message ?? "Booking not found.");
  }

  if (booking.status !== "completed") {
    throw new Error("Only completed bookings can be paid.");
  }

  const totalAmount = Number(paymentAmount ?? 0);
  const normalizedCurrency = String(currency || booking.currency || "etb")
    .toLowerCase();
  const { commissionAmount, stylistEarning } =
    calculateCommissionSplit(totalAmount);

  const walletResult = await adminClient.rpc("credit_stylist_wallet", {
    p_stylist_id: booking.stylist,
    p_booking_id: bookingId,
    p_payment_id: paymentId,
    p_amount: stylistEarning,
    p_currency: normalizedCurrency,
    p_source: "booking_earning",
    p_reference: transactionReference ?? null,
    p_metadata: {
      booking_id: bookingId,
      payment_id: paymentId,
      customer_id: customerId ?? null,
      commission_amount: commissionAmount,
      gross_amount: totalAmount,
    },
  });

  if (walletResult.error) {
    throw new Error(walletResult.error.message);
  }

  const walletPayload = walletResult.data as
    | {
        wallet_id?: string;
        transaction_id?: string;
        balance?: number;
        applied?: boolean;
      }
    | null;

  const { error: bookingUpdateError } = await adminClient.from("bookings")
    .update({
      payment_method: paymentMethod,
      payment_status: "paid",
      paid_amount: totalAmount,
      commission_amount: commissionAmount,
      stylist_earning: stylistEarning,
      updated_at: new Date().toISOString(),
    })
    .eq("id", bookingId);

  if (bookingUpdateError) {
    throw new Error(bookingUpdateError.message);
  }

  return {
    commissionAmount,
    stylistEarning,
    walletId: walletPayload?.wallet_id ?? null,
    walletTransactionId: walletPayload?.transaction_id ?? null,
    walletBalance: walletPayload?.balance ?? null,
    settlementApplied: walletPayload?.applied ?? false,
  };
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
