import { corsHeaders } from "./cors.ts";

export function jsonResponse(
  data: unknown,
  init: ResponseInit = {},
): Response {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });
}

export function errorResponse(
  message: string,
  status = 400,
  details?: unknown,
): Response {
  const payload: Record<string, unknown> = { message };
  if (details != null) {
    payload.details = details;
  }

  return jsonResponse(payload, { status });
}
