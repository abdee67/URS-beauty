import Stripe from "npm:stripe@18.4.0";

let stripeClient: Stripe | null = null;

export function getStripe(): Stripe {
  if (stripeClient != null) {
    return stripeClient;
  }

  const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!secretKey) {
    throw new Error("STRIPE_SECRET_KEY is not configured.");
  }

  stripeClient = new Stripe(secretKey, {
    apiVersion: "2026-03-25.dahlia",
  });

  return stripeClient;
}
