// supabase/functions/ai-chat/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type AiChatRequest = {
  message?: string;
  context?: unknown;
  language?: string;
};

type JsonBodyResult =
  | { ok: true; body: AiChatRequest }
  | { ok: false; error: "invalid_json" };

type UsageStatus = "success" | "failed" | "blocked";

const maxMessageLength = 2000;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function createSupabaseAdminClient() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim();
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim();

  if (!supabaseUrl || !serviceRoleKey) {
    return null;
  }

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });
}

function readAiConfig() {
  return {
    provider: Deno.env.get("AI_PROVIDER")?.trim() ?? "",
    apiKey: Deno.env.get("AI_API_KEY")?.trim() ?? "",
    model: Deno.env.get("AI_MODEL")?.trim() ?? "",
  };
}

async function recordUsageEvent(
  message: string,
  status: UsageStatus,
): Promise<void> {
  const supabase = createSupabaseAdminClient();
  if (!supabase) {
    return;
  }

  try {
    const { error } = await supabase.from("translation_usage_events").insert({
      user_id: null,
      feature: "ai_chat",
      request_count: 1,
      character_count: message.length,
      status,
      plan: null,
    });

    if (error) {
      console.warn("ai chat usage event write failed", error.message);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown error";
    console.warn("ai chat usage event write failed", message);
  }
}

async function readJsonBody(req: Request): Promise<JsonBodyResult> {
  try {
    const body = await req.json();
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      return { ok: false, error: "invalid_json" };
    }
    return { ok: true, body: body as AiChatRequest };
  } catch {
    return { ok: false, error: "invalid_json" };
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const parsed = await readJsonBody(req);
  if (!parsed.ok) {
    return jsonResponse({ error: parsed.error }, 400);
  }

  const message = parsed.body.message?.trim() ?? "";
  const language = parsed.body.language?.trim() ?? "";
  const context = parsed.body.context ?? null;
  void language;
  void context;

  if (!message) {
    return jsonResponse({ error: "message_required" }, 400);
  }

  if (message.length > maxMessageLength) {
    await recordUsageEvent(message, "blocked");
    return jsonResponse({ error: "quota_exceeded" }, 429);
  }

  const config = readAiConfig();
  if (!config.provider || !config.apiKey || !config.model) {
    return jsonResponse({ error: "ai_not_configured" }, 501);
  }

  // Provider integration is intentionally not implemented yet.
  // Before production:
  // - validate Supabase Auth and user entitlement
  // - enforce per-user AI usage limits
  // - call the selected provider without logging full prompts or secrets
  // - record success/failed usage events after the provider response
  await recordUsageEvent(message, "failed");
  return jsonResponse({ error: "ai_request_failed" }, 502);
});
