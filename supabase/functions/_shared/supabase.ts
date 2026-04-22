import { createClient } from "npm:@supabase/supabase-js@2.49.8";

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`${name} is not configured.`);
  }
  return value;
}

const supabaseUrl = requireEnv("SUPABASE_URL");
const supabaseAnonKey =
  Deno.env.get("SUPABASE_ANON_KEY") ??
  Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
const supabaseServiceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");

export function createUserClient(authHeader: string) {
  if (!supabaseAnonKey) {
    throw new Error("SUPABASE_ANON_KEY is not configured.");
  }

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });
}

export function createAdminClient() {
  return createClient(supabaseUrl, supabaseServiceRoleKey);
}
