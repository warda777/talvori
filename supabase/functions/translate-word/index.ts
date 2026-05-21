// supabase/functions/translate-word/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type TranslateWordRequest = {
  text?: string;
  sourceLang?: string;
  targetLang?: string;
};

type DeepLTranslation = {
  text?: unknown;
};

type DeepLResponse = {
  translations?: DeepLTranslation[];
};

type JsonBodyResult =
  | { ok: true; body: TranslateWordRequest }
  | { ok: false; error: "invalid_json" };

type AuthContext = {
  authorization: string | null;
  userId: string | null;
  clientIp: string | null;
  isAuthenticated: boolean;
};

type AccessCheckResult =
  | { ok: true }
  | {
    ok: false;
    error: "auth_required" | "rate_limit_exceeded" | "quota_exceeded";
    status: number;
  };

type UsageStatus = "success" | "failed" | "blocked";

type UsageLimitResult =
  | { ok: true }
  | { ok: false; error: "quota_exceeded"; status: number };

const maxTextLength = 500;
const defaultDailyRequestLimit = 1000;
const defaultDailyCharacterLimit = 20000;

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

function normalizeLanguage(value: string): string {
  return value.trim().toUpperCase();
}

function readDeepLBaseUrl(): string {
  const configured = Deno.env.get("DEEPL_API_BASE_URL")?.trim();
  return configured && configured.length > 0
    ? configured.replace(/\/+$/, "")
    : "https://api-free.deepl.com";
}

function readUsagePlan(): string | null {
  const configured = Deno.env.get("TRANSLATION_USAGE_PLAN")?.trim();
  return configured && configured.length > 0 ? configured : null;
}

function readDailyRequestLimit(): number {
  const configured = Deno.env.get("TRANSLATION_DAILY_REQUEST_LIMIT")?.trim();
  if (!configured) {
    return defaultDailyRequestLimit;
  }

  const parsed = Number(configured);
  if (!Number.isFinite(parsed) || parsed < 0) {
    return defaultDailyRequestLimit;
  }

  return Math.floor(parsed);
}

function readDailyCharacterLimit(): number {
  const configured = Deno.env.get("TRANSLATION_DAILY_CHARACTER_LIMIT")?.trim();
  if (!configured) {
    return defaultDailyCharacterLimit;
  }

  const parsed = Number(configured);
  if (!Number.isFinite(parsed) || parsed < 0) {
    return defaultDailyCharacterLimit;
  }

  return Math.floor(parsed);
}

function currentDayBucket(): string {
  return new Date().toISOString().slice(0, 10);
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

function envFlagEnabled(name: string): boolean {
  const value = Deno.env.get(name)?.trim().toLowerCase();
  return value === "1" || value === "true" || value === "yes";
}

async function readAuthContext(req: Request): Promise<AuthContext> {
  const authorization = req.headers.get("authorization")?.trim() ?? null;
  const forwardedFor = req.headers.get("x-forwarded-for")?.trim() ?? "";
  const clientIp = forwardedFor.split(",")[0]?.trim() ||
    req.headers.get("cf-connecting-ip")?.trim() ||
    null;
  const bearerToken = authorization?.toLowerCase().startsWith("bearer ")
    ? authorization.slice("bearer ".length).trim()
    : null;
  let userId: string | null = null;

  if (bearerToken) {
    const supabase = createSupabaseAdminClient();
    if (supabase) {
      try {
        const { data, error } = await supabase.auth.getUser(bearerToken);
        if (!error && data.user?.id) {
          userId = data.user.id;
        } else if (error) {
          console.warn("translation auth verification failed", error.message);
        }
      } catch (error) {
        const message = error instanceof Error ? error.message : "unknown error";
        console.warn("translation auth verification failed", message);
      }
    }
  }

  // Dev remains open by default. Production can require auth with
  // TRANSLATE_WORD_REQUIRE_AUTH once deployment provisioning is complete.
  return {
    authorization,
    userId,
    clientIp,
    isAuthenticated:
      userId !== null || (authorization !== null && authorization.length > 0),
  };
}

function checkAuth(auth: AuthContext): AccessCheckResult {
  // Dev remains open by default. Production can require auth by setting this
  // flag after JWT verification is implemented.
  if (envFlagEnabled("TRANSLATE_WORD_REQUIRE_AUTH") && !auth.isAuthenticated) {
    return { ok: false, error: "auth_required", status: 401 };
  }

  return { ok: true };
}

function checkRateLimit(auth: AuthContext): AccessCheckResult {
  void auth;
  // TODO before production:
  // - rate limit by user_id when authenticated
  // - fallback to client IP for anonymous/dev requests
  // - enforce daily free quota and premium quota
  // - return rate_limit_exceeded or quota_exceeded when limits are active
  // - share the same strategy with future AI chat Edge Functions
  return { ok: true };
}

async function recordUsageEvent(
  auth: AuthContext,
  text: string,
  status: UsageStatus,
): Promise<void> {
  const supabase = createSupabaseAdminClient();
  if (!supabase) {
    return;
  }

  try {
    const { error } = await supabase.from("translation_usage_events").insert({
      user_id: auth.userId,
      feature: "translation",
      request_count: 1,
      character_count: text.length,
      status,
      plan: readUsagePlan(),
    });

    if (error) {
      console.warn("translation usage event write failed", error.message);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown error";
    console.warn("translation usage event write failed", message);
  }
}

async function checkUsageLimit(
  auth: AuthContext,
  text: string,
): Promise<UsageLimitResult> {
  const requestLimit = readDailyRequestLimit();
  const characterLimit = readDailyCharacterLimit();
  if (requestLimit === 0 || characterLimit === 0) {
    return { ok: false, error: "quota_exceeded", status: 429 };
  }

  const supabase = createSupabaseAdminClient();
  if (!supabase) {
    return { ok: true };
  }

  try {
    let query = supabase
      .from("translation_usage_events")
      .select("request_count, character_count")
      .eq("feature", "translation")
      .eq("day_bucket", currentDayBucket());

    // Authenticated requests are limited per Supabase user. Development or
    // anonymous requests use a global fallback bucket.
    if (auth.userId) {
      query = query.eq("user_id", auth.userId);
    }

    const { data, error } = await query;
    if (error) {
      console.warn("translation usage limit check failed", error.message);
      return { ok: true };
    }

    const usedRequests = (data ?? []).reduce((sum, row) => {
      const count = Number(row.request_count ?? 0);
      return sum + (Number.isFinite(count) ? count : 0);
    }, 0);
    const usedCharacters = (data ?? []).reduce((sum, row) => {
      const count = Number(row.character_count ?? 0);
      return sum + (Number.isFinite(count) ? count : 0);
    }, 0);

    if (
      usedRequests >= requestLimit ||
      usedCharacters + text.length > characterLimit
    ) {
      return { ok: false, error: "quota_exceeded", status: 429 };
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown error";
    console.warn("translation usage limit check failed", message);
  }

  return { ok: true };
}

async function readJsonBody(req: Request): Promise<JsonBodyResult> {
  try {
    const body = await req.json();
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      return { ok: false, error: "invalid_json" };
    }
    return { ok: true, body: body as TranslateWordRequest };
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

  const auth = await readAuthContext(req);
  const authCheck = checkAuth(auth);
  if (!authCheck.ok) {
    return jsonResponse({ error: authCheck.error }, authCheck.status);
  }
  const rateLimitCheck = checkRateLimit(auth);
  if (!rateLimitCheck.ok) {
    return jsonResponse({ error: rateLimitCheck.error }, rateLimitCheck.status);
  }

  const parsed = await readJsonBody(req);
  if (!parsed.ok) {
    return jsonResponse({ error: parsed.error }, 400);
  }

  const body = parsed.body;
  const text = body.text?.trim() ?? "";
  const targetLang = normalizeLanguage(body.targetLang ?? "");
  const sourceLang = normalizeLanguage(body.sourceLang ?? "");

  if (!text) {
    return jsonResponse(
      { error: "invalid_input", reason: "text_required" },
      400,
    );
  }
  if (!targetLang) {
    return jsonResponse(
      { error: "invalid_input", reason: "target_lang_required" },
      400,
    );
  }
  if (text.length > maxTextLength) {
    return jsonResponse(
      { error: "invalid_input", reason: "text_too_long" },
      413,
    );
  }

  const usageLimitCheck = await checkUsageLimit(auth, text);
  if (!usageLimitCheck.ok) {
    await recordUsageEvent(auth, text, "blocked");
    return jsonResponse(
      { error: usageLimitCheck.error },
      usageLimitCheck.status,
    );
  }

  const deeplApiKey = Deno.env.get("DEEPL_API_KEY")?.trim();
  if (!deeplApiKey) {
    return jsonResponse({ error: "translation_not_configured" }, 500);
  }

  const payload: Record<string, unknown> = {
    text: [text],
    target_lang: targetLang,
  };
  if (sourceLang) {
    payload.source_lang = sourceLang;
  }

  let deeplResponse: Response;
  try {
    deeplResponse = await fetch(`${readDeepLBaseUrl()}/v2/translate`, {
      method: "POST",
      headers: {
        Authorization: `DeepL-Auth-Key ${deeplApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });
  } catch {
    await recordUsageEvent(auth, text, "failed");
    return jsonResponse({ error: "translation_request_failed" }, 502);
  }

  if (!deeplResponse.ok) {
    await recordUsageEvent(auth, text, "failed");
    return jsonResponse(
      {
        error: "translation_failed",
        status: deeplResponse.status,
      },
      502,
    );
  }

  let decoded: DeepLResponse;
  try {
    decoded = await deeplResponse.json() as DeepLResponse;
  } catch {
    await recordUsageEvent(auth, text, "failed");
    return jsonResponse({ error: "invalid_translation_response" }, 502);
  }

  const translatedText = decoded.translations?.[0]?.text;
  if (typeof translatedText !== "string" || translatedText.trim().length === 0) {
    await recordUsageEvent(auth, text, "failed");
    return jsonResponse({ error: "invalid_translation_response" }, 502);
  }

  await recordUsageEvent(auth, text, "success");
  return jsonResponse({ translation: translatedText });
});
