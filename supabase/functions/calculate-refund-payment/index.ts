import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/http.ts";
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

    const { data: updatedPayment, error: updateError } = await adminClient
      .from("payments")
      .update({
        refundable_amount: refundQuote.refundable_amount ?? 0,
      })
      .eq("id", paymentId)
      .eq("customer_id", user.id)
      .select("*")
      .single();

    if (updateError || !updatedPayment) {
      return errorResponse(
        "Failed to refresh the payment record.",
        500,
        updateError?.message,
      );
    }

    return jsonResponse({
      payment: updatedPayment,
      refund_quote: refundQuote,
      refundable_amount: refundQuote.refundable_amount ?? 0,
    });
  } catch (error) {
    return errorResponse(
      error instanceof Error ? error.message : String(error),
      500,
    );
  }
});
