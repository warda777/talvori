// supabase/functions/generate-daily-impulses/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type DailyImpulseWord = {
  word?: unknown;
  translation?: unknown;
};

type GenerateDailyImpulsesRequest = {
  words?: unknown;
  count?: unknown;
  language?: unknown;
  style?: unknown;
  targetLevel?: unknown;
  timeSlots?: unknown;
};

type DailyImpulse = {
  slot: string;
  message: string;
  usedWords: string[];
};

type JsonBodyResult =
  | { ok: true; body: GenerateDailyImpulsesRequest }
  | { ok: false; error: "invalid_json" };

type UsageStatus = "success" | "failed" | "blocked";

type UsageLimitResult =
  | { ok: true }
  | { ok: false; error: "quota_exceeded"; status: number };

type AiPublicError =
  | "ai_request_failed"
  | "ai_auth_failed"
  | "ai_rate_limited";

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

type ProviderErrorBody = {
  error?: {
    code?: unknown;
    type?: unknown;
  };
};

class AiProviderException extends Error {
  constructor(
    message: string,
    readonly publicError: AiPublicError,
    readonly responseStatus: number,
    readonly reason: string,
    readonly providerErrorCode: string | null,
    readonly providerErrorType: string | null,
  ) {
    super(message);
  }
}

class AiInvalidResponseException extends Error {}

const maxWords = 5;
const maxWordLength = 80;
const maxStyleLength = 80;
const maxTargetLevelLength = 40;
const defaultDailyRequestLimit = 1000;
const defaultOpenAiBaseUrl = "https://api.openai.com/v1";
const defaultSlots = ["morning", "afternoon", "evening", "day", "later"];

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

function readAiConfig(): AiConfig {
  return {
    provider: (Deno.env.get("AI_PROVIDER")?.trim() ?? "").toLowerCase(),
    apiKey: Deno.env.get("AI_API_KEY")?.trim() ?? "",
    model: Deno.env.get("AI_MODEL")?.trim() ?? "",
    baseUrl: (Deno.env.get("AI_BASE_URL")?.trim() || defaultOpenAiBaseUrl)
      .replace(/\/+$/, ""),
  };
}

function readDailyRequestLimit(): number {
  const configured = Deno.env.get("DAILY_IMPULSE_DAILY_REQUEST_LIMIT")?.trim();
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

function buildChatCompletionsUrl(baseUrl: string): string {
  const normalized = baseUrl.replace(/\/+$/, "");
  if (normalized.endsWith("/chat/completions")) {
    return normalized;
  }
  return `${normalized}/chat/completions`;
}

function publicErrorForProviderStatus(status: number): AiPublicError {
  if (status === 401 || status === 403) {
    return "ai_auth_failed";
  }
  if (status === 429) {
    return "ai_rate_limited";
  }
  return "ai_request_failed";
}

function reasonForProviderStatus(status: number): string {
  if (status === 401 || status === 403) {
    return "provider_auth_failed";
  }
  if (status === 429) {
    return "provider_rate_limited";
  }
  if (status >= 500) {
    return "provider_unavailable";
  }
  return "provider_rejected";
}

function safeString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : null;
}

function normalizeOptionalString(value: unknown, fallback: string): string {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : fallback;
}

function normalizeCount(value: unknown): number | null {
  if (value === undefined || value === null) {
    return 1;
  }

  const parsed = typeof value === "number" ? value : Number(value);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > 5) {
    return null;
  }

  return parsed;
}

function normalizeWords(value: unknown): DailyImpulseWord[] | null {
  if (!Array.isArray(value) || value.length === 0 || value.length > maxWords) {
    return null;
  }

  const words: DailyImpulseWord[] = [];
  for (const raw of value) {
    if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
      return null;
    }

    const entry = raw as DailyImpulseWord;
    const word = safeString(entry.word);
    if (!word || word.length > maxWordLength) {
      return null;
    }

    const translation = safeString(entry.translation);
    words.push({
      word,
      translation: translation && translation.length <= maxWordLength
        ? translation
        : undefined,
    });
  }

  return words;
}

function normalizeTimeSlots(value: unknown, count: number): string[] {
  if (!Array.isArray(value)) {
    return defaultSlots.slice(0, count);
  }

  const slots = value
    .map((slot) => safeString(slot))
    .filter((slot): slot is string => slot !== null)
    .map((slot) => slot.slice(0, 40));

  if (slots.length === 0) {
    return defaultSlots.slice(0, count);
  }

  return slots.slice(0, count);
}

async function readProviderErrorBody(
  response: Response,
): Promise<ProviderErrorBody> {
  try {
    const body = await response.json();
    return body && typeof body === "object" && !Array.isArray(body)
      ? body as ProviderErrorBody
      : {};
  } catch {
    return {};
  }
}

async function recordUsageEvent(
  characterCount: number,
  status: UsageStatus,
): Promise<void> {
  const supabase = createSupabaseAdminClient();
  if (!supabase) {
    return;
  }

  try {
    const { error } = await supabase.from("translation_usage_events").insert({
      user_id: null,
      feature: "daily_impulse",
      request_count: 1,
      character_count: characterCount,
      status,
      plan: null,
    });

    if (error) {
      console.warn("daily impulse usage event write failed", error.message);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown error";
    console.warn("daily impulse usage event write failed", message);
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
      .eq("feature", "daily_impulse")
      .eq("day_bucket", currentDayBucket());

    if (error) {
      console.warn("daily impulse usage limit check failed", error.message);
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
    console.warn("daily impulse usage limit check failed", message);
  }

  return { ok: true };
}

function buildSystemPrompt(): string {
  return [
    "Du bist Talvori, ein ruhiger Sprachlern-Assistent.",
    "Erzeuge kurze, natürliche Messenger-artige Nachrichten für Sprachlernende.",
    "Antworte ausschließlich mit einem JSON-Array ohne Markdown.",
    "Jedes Element muss slot, message und usedWords enthalten.",
    "Schreibe keine trockenen Vokabellisten und keine Erklärtexte.",
  ].join(" ");
}

function buildUserPrompt(
  words: DailyImpulseWord[],
  count: number,
  language: string,
  style: string,
  targetLevel: string,
  timeSlots: string[],
): string {
  const wordLines = words.map((entry) => {
    const translation = safeString(entry.translation);
    return translation ? `- ${entry.word} (${translation})` : `- ${entry.word}`;
  }).join("\n");

  return [
    `Erzeuge genau ${count} kurze Tagesimpuls-Nachricht${count === 1 ? "" : "en"}.`,
    `Sprache: ${language}.`,
    `Stil: ${style}.`,
    `Zielniveau: ${targetLevel}.`,
    `Zeitslots: ${timeSlots.join(", ")}.`,
    "Nutze die folgenden Wörter sinnvoll und natürlich:",
    wordLines,
    "Antwortformat:",
    '[{"slot":"morning","message":"...","usedWords":["..."]}]',
  ].join("\n");
}

async function callOpenAiCompatibleChat(
  config: AiConfig,
  prompt: string,
): Promise<string> {
  const response = await fetch(buildChatCompletionsUrl(config.baseUrl), {
    method: "POST",
    headers: {
      Authorization: `Bearer ${config.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: config.model,
      messages: [
        { role: "system", content: buildSystemPrompt() },
        { role: "user", content: prompt },
      ],
      temperature: 0.55,
    }),
  });

  if (!response.ok) {
    const errorBody = await readProviderErrorBody(response);
    const errorCode = safeString(errorBody.error?.code);
    const errorType = safeString(errorBody.error?.type);
    console.error("daily impulse AI provider request failed", {
      status: response.status,
      errorCode,
      errorType,
    });
    throw new AiProviderException(
      `AI provider ${response.status}`,
      publicErrorForProviderStatus(response.status),
      response.status === 429 ? 429 : 502,
      reasonForProviderStatus(response.status),
      errorCode,
      errorType,
    );
  }

  const decoded = await response.json() as ChatCompletionResponse;
  const answer = decoded.choices?.[0]?.message?.content;
  if (typeof answer !== "string" || answer.trim().length === 0) {
    console.error("daily impulse AI provider response invalid", {
      reason: "missing_answer",
    });
    throw new AiInvalidResponseException("AI provider response is empty");
  }

  return answer.trim();
}

function stripJsonFence(value: string): string {
  return value
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
}

function normalizeImpulse(
  value: unknown,
  fallbackSlot: string,
  fallbackWords: string[],
): DailyImpulse | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const entry = value as Record<string, unknown>;
  const message = safeString(entry.message);
  if (!message) {
    return null;
  }

  const slot = safeString(entry.slot) ?? fallbackSlot;
  const usedWords = Array.isArray(entry.usedWords)
    ? entry.usedWords
      .map((word) => safeString(word))
      .filter((word): word is string => word !== null)
    : fallbackWords;

  return {
    slot,
    message,
    usedWords: usedWords.length > 0 ? usedWords : fallbackWords,
  };
}

function parseImpulses(
  rawAnswer: string,
  count: number,
  words: DailyImpulseWord[],
  timeSlots: string[],
): DailyImpulse[] {
  let decoded: unknown;
  try {
    decoded = JSON.parse(stripJsonFence(rawAnswer));
  } catch {
    throw new AiInvalidResponseException("AI response is not JSON");
  }

  const rawImpulses = Array.isArray(decoded)
    ? decoded
    : decoded && typeof decoded === "object" && !Array.isArray(decoded)
    ? (decoded as { impulses?: unknown }).impulses
    : null;

  if (!Array.isArray(rawImpulses)) {
    throw new AiInvalidResponseException("AI response has no impulses array");
  }

  const fallbackWords = words
    .map((entry) => safeString(entry.word))
    .filter((word): word is string => word !== null);

  const impulses = rawImpulses
    .slice(0, count)
    .map((entry, index) =>
      normalizeImpulse(
        entry,
        timeSlots[index] ?? defaultSlots[index] ?? `slot-${index + 1}`,
        fallbackWords,
      )
    )
    .filter((entry): entry is DailyImpulse => entry !== null);

  if (impulses.length === 0) {
    throw new AiInvalidResponseException("AI response has no valid impulses");
  }

  return impulses;
}

function requestCharacterCount(words: DailyImpulseWord[]): number {
  return words.reduce((sum, entry) => {
    const word = safeString(entry.word) ?? "";
    const translation = safeString(entry.translation) ?? "";
    return sum + word.length + translation.length;
  }, 0);
}

async function readJsonBody(req: Request): Promise<JsonBodyResult> {
  try {
    const body = await req.json();
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      return { ok: false, error: "invalid_json" };
    }
    return { ok: true, body: body as GenerateDailyImpulsesRequest };
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

  const words = normalizeWords(parsed.body.words);
  if (!words) {
    return jsonResponse({ error: "words_required" }, 400);
  }

  const count = normalizeCount(parsed.body.count);
  if (count === null) {
    return jsonResponse({ error: "invalid_count" }, 400);
  }

  const language = normalizeOptionalString(parsed.body.language, "EN")
    .slice(0, 12)
    .toUpperCase();
  const style = normalizeOptionalString(
    parsed.body.style,
    "natural_message",
  ).slice(0, maxStyleLength);
  const targetLevel = normalizeOptionalString(
    parsed.body.targetLevel,
    "learner_friendly",
  ).slice(0, maxTargetLevelLength);
  const timeSlots = normalizeTimeSlots(parsed.body.timeSlots, count);
  const characterCount = requestCharacterCount(words);

  const usageLimitCheck = await checkUsageLimit();
  if (!usageLimitCheck.ok) {
    await recordUsageEvent(characterCount, "blocked");
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

  try {
    const prompt = buildUserPrompt(
      words,
      count,
      language,
      style,
      targetLevel,
      timeSlots,
    );
    const rawAnswer = await callOpenAiCompatibleChat(config, prompt);
    const impulses = parseImpulses(rawAnswer, count, words, timeSlots);
    await recordUsageEvent(characterCount, "success");
    return jsonResponse({ impulses });
  } catch (error) {
    await recordUsageEvent(characterCount, "failed");
    if (error instanceof AiProviderException) {
      return jsonResponse(
        { error: error.publicError, reason: error.reason },
        error.responseStatus,
      );
    }
    if (error instanceof AiInvalidResponseException) {
      console.error("daily impulse AI response invalid", {
        reason: error.message,
      });
      return jsonResponse({ error: "ai_invalid_response" }, 502);
    }

    const errorMessage = error instanceof Error ? error.message : "unknown";
    console.error("daily impulse AI request crashed", { error: errorMessage });
    return jsonResponse(
      { error: "ai_request_failed", reason: "provider_request_failed" },
      502,
    );
  }
});
