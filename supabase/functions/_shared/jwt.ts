/**
 * Strict JWT verification for Brain Clean Edge Functions.
 *
 * Layers:
 * 1. Reject missing/malformed Bearer, anon key, or service-role key as tokens.
 * 2. Verify HS256 signature when JWT_SECRET / SUPABASE_JWT_SECRET is set.
 * 3. Enforce exp / role / sub claims.
 * 4. Confirm the user still exists via Auth `getUser()` (revocation / deletion).
 */
import { createClient, type User } from "https://esm.sh/@supabase/supabase-js@2";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export interface VerifiedCaller {
  userId: string;
  user: User;
  token: string;
}

function base64UrlToBytes(input: string): Uint8Array {
  const padded = input.replace(/-/g, "+").replace(/_/g, "/");
  const pad = padded.length % 4 === 0 ? "" : "=".repeat(4 - (padded.length % 4));
  const binary = atob(padded + pad);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  try {
    const json = new TextDecoder().decode(base64UrlToBytes(parts[1]));
    const payload = JSON.parse(json);
    return payload && typeof payload === "object"
      ? payload as Record<string, unknown>
      : null;
  } catch {
    return null;
  }
}

async function verifyHs256Signature(
  token: string,
  secret: string,
): Promise<boolean> {
  const parts = token.split(".");
  if (parts.length !== 3 || !secret) return false;
  try {
    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["verify"],
    );
    const data = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
    const signature = base64UrlToBytes(parts[2]);
    return await crypto.subtle.verify("HMAC", key, signature, data);
  } catch {
    return false;
  }
}

function claimsAreAcceptable(payload: Record<string, unknown>): boolean {
  const role = payload.role;
  if (role === "service_role" || role === "anon") return false;
  if (role !== "authenticated") return false;

  const sub = payload.sub;
  if (typeof sub !== "string" || sub.length < 8) return false;

  const exp = payload.exp;
  if (typeof exp !== "number") return false;
  const nowSec = Math.floor(Date.now() / 1000);
  if (exp <= nowSec + 5) return false;

  return true;
}

/**
 * Returns the authenticated user or an HTTP 401/500 response.
 */
export async function requireAuthenticatedUser(
  req: Request,
): Promise<VerifiedCaller | Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return jsonResponse({ error: "Missing or invalid Authorization" }, 401);
  }

  const token = authHeader.slice("Bearer ".length).trim();
  if (!token) {
    return jsonResponse({ error: "Missing or invalid Authorization" }, 401);
  }

  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (
    (anonKey && token === anonKey) ||
    (serviceRoleKey && token === serviceRoleKey)
  ) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  const payload = decodeJwtPayload(token);
  if (!payload || !claimsAreAcceptable(payload)) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  const jwtSecret = Deno.env.get("SUPABASE_JWT_SECRET") ??
    Deno.env.get("JWT_SECRET") ??
    "";
  if (jwtSecret) {
    const signed = await verifyHs256Signature(token, jwtSecret);
    if (!signed) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  if (!supabaseUrl || !anonKey) {
    return jsonResponse({ error: "Server misconfigured" }, 500);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await userClient.auth.getUser(token);
  if (error || !data?.user?.id) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  if (data.user.id !== payload.sub) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  return { userId: data.user.id, user: data.user, token };
}

export function createServiceClient() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("missing_service_role");
  }
  return createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
