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

type UsageLimitResult =
  | { ok: true }
  | { ok: false; error: "quota_exceeded"; status: number };

type AiConfig = {
  provider: string;
  apiKey: string;
  model: string;
  baseUrl: string;
};

type ChatCompletionResponse = {
  choices?: Array<{
    message?: {
      content?: unknown;
    };
  }>;
};

const maxMessageLength = 2000;
const defaultDailyRequestLimit = 1000;
const defaultOpenAiBaseUrl = "https://api.openai.com/v1";

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
    provider: (Deno.env.get("AI_PROVIDER")?.trim() ?? "").toLowerCase(),
    apiKey: Deno.env.get("AI_API_KEY")?.trim() ?? "",
    model: Deno.env.get("AI_MODEL")?.trim() ?? "",
    baseUrl: (Deno.env.get("AI_BASE_URL")?.trim() || defaultOpenAiBaseUrl)
      .replace(/\/+$/, ""),
  };
}

function readDailyRequestLimit(): number {
  const configured = Deno.env.get("AI_DAILY_REQUEST_LIMIT")?.trim();
  if (!configured) {
    return defaultDailyRequestLimit;
  }

  const parsed = Number(configured);
  if (!Number.isFinite(parsed) || parsed < 0) {
    return defaultDailyRequestLimit;
  }

  return Math.floor(parsed);
}

function currentDayBucket(): string {
  return new Date().toISOString().slice(0, 10);
}

function isSupportedProvider(provider: string): boolean {
  return provider === "openai" || provider === "openai_compatible";
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

async function checkUsageLimit(): Promise<UsageLimitResult> {
  const limit = readDailyRequestLimit();
  if (limit === 0) {
    return { ok: false, error: "quota_exceeded", status: 429 };
  }

  const supabase = createSupabaseAdminClient();
  if (!supabase) {
    return { ok: true };
  }

  try {
    const { data, error } = await supabase
      .from("translation_usage_events")
      .select("request_count")
      .eq("feature", "ai_chat")
      .eq("day_bucket", currentDayBucket());

    if (error) {
      console.warn("ai chat usage limit check failed", error.message);
      return { ok: true };
    }

    const used = (data ?? []).reduce((sum, row) => {
      const count = Number(row.request_count ?? 0);
      return sum + (Number.isFinite(count) ? count : 0);
    }, 0);

    if (used >= limit) {
      return { ok: false, error: "quota_exceeded", status: 429 };
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown error";
    console.warn("ai chat usage limit check failed", message);
  }

  return { ok: true };
}

function buildSystemPrompt(language: string): string {
  const languageHint = language
    ? ` Antworte bevorzugt in dieser Sprache: ${language}.`
    : "";
  return [
    "Du bist Talvori, ein ruhiger Sprachlern-Assistent.",
    "Hilf knapp, praktisch und lernorientiert.",
    "Erfinde keine persönlichen Daten und frage nach, wenn Kontext fehlt.",
    languageHint,
  ].join(" ");
}

function stringifyContext(context: unknown): string {
  if (context === null || context === undefined) {
    return "";
  }
  if (typeof context === "string") {
    return context.trim();
  }

  try {
    return JSON.stringify(context);
  } catch {
    return "";
  }
}

function buildUserPrompt(message: string, context: unknown): string {
  const contextText = stringifyContext(context);
  if (!contextText) {
    return message;
  }

  return `Kontext:\n${contextText}\n\nNutzerfrage:\n${message}`;
}

async function callOpenAiCompatibleChat(
  config: AiConfig,
  message: string,
  context: unknown,
  language: string,
): Promise<string> {
  const response = await fetch(`${config.baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${config.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: config.model,
      messages: [
        { role: "system", content: buildSystemPrompt(language) },
        { role: "user", content: buildUserPrompt(message, context) },
      ],
      temperature: 0.4,
    }),
  });

  if (!response.ok) {
    throw new Error(`AI provider ${response.status}`);
  }

  const decoded = await response.json() as ChatCompletionResponse;
  const answer = decoded.choices?.[0]?.message?.content;
  if (typeof answer !== "string" || answer.trim().length === 0) {
    throw new Error("AI provider response is missing answer");
  }

  return answer.trim();
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

  const usageLimitCheck = await checkUsageLimit();
  if (!usageLimitCheck.ok) {
    await recordUsageEvent(message, "blocked");
    return jsonResponse(
      { error: usageLimitCheck.error },
      usageLimitCheck.status,
    );
  }

  const config = readAiConfig();
  if (!config.provider || !config.apiKey || !config.model) {
    return jsonResponse({ error: "ai_not_configured" }, 501);
  }
  if (!isSupportedProvider(config.provider)) {
    return jsonResponse({ error: "ai_provider_not_supported" }, 501);
  }

  // Before production:
  // - validate Supabase Auth and user entitlement
  // - enforce per-user AI usage limits
  // - keep provider calls free of full prompt logging and secrets
  try {
    const answer = await callOpenAiCompatibleChat(
      config,
      message,
      context,
      language,
    );
    await recordUsageEvent(message, "success");
    return jsonResponse({ answer });
  } catch {
    await recordUsageEvent(message, "failed");
    return jsonResponse({ error: "ai_request_failed" }, 502);
  }
});
