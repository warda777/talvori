// supabase/functions/translate-word/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

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

async function readJsonBody(req: Request): Promise<TranslateWordRequest> {
  try {
    const body = await req.json();
    return body && typeof body === "object" ? body as TranslateWordRequest : {};
  } catch {
    return {};
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  // TODO before production: add auth, rate limits, and abuse protection.
  const deeplApiKey = Deno.env.get("DEEPL_API_KEY")?.trim();
  if (!deeplApiKey) {
    return jsonResponse({ error: "translation_not_configured" }, 500);
  }

  const body = await readJsonBody(req);
  const text = body.text?.trim() ?? "";
  const targetLang = normalizeLanguage(body.targetLang ?? "");
  const sourceLang = normalizeLanguage(body.sourceLang ?? "");

  if (!text) {
    return jsonResponse({ error: "text_required" }, 400);
  }
  if (!targetLang) {
    return jsonResponse({ error: "target_lang_required" }, 400);
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
    return jsonResponse({ error: "translation_request_failed" }, 502);
  }

  if (!deeplResponse.ok) {
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
    return jsonResponse({ error: "invalid_translation_response" }, 502);
  }

  const translatedText = decoded.translations?.[0]?.text;
  if (typeof translatedText !== "string" || translatedText.trim().length === 0) {
    return jsonResponse({ error: "invalid_translation_response" }, 502);
  }

  return jsonResponse({ translation: translatedText });
});
