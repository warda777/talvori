// supabase/functions/ingest_word/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = {
  id?: string; // optional: Force-Translate by UUID
  text?: string;
  fromLang: string;
  toLang: string;
  pos?: string; // optional: 'noun'|'verb'|'adj'|...
  mode?: "create" | "fix"; // 'create' (default) oder 'fix' für Re-Translate/QA
  formality?: "default" | "prefer_more" | "prefer_less";
};

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const deeplKey = Deno.env.get("DEEPL_API_KEY")!; // in Supabase Secrets
const glossaryId = Deno.env.get("DEEPL_GLOSSARY_ID") || ""; // optional
const deeplEndpoint = "https://api-free.deepl.com/v2/translate"; // oder api.deepl.com

function norm(s: string) {
  return s.trim();
}

// Text-Normalisierung: Trim + Whitespace auf einzelne Leerzeichen reduzieren + Case-insensitive
function normalizeText(s: string) {
  return s.replace(/\s+/g, " ").trim().toLowerCase();
}
function jaccard(a: string, b: string) {
  const A = new Set(a.toLowerCase().split(/\s+/));
  const B = new Set(b.toLowerCase().split(/\s+/));
  const inter = [...A].filter((x) => B.has(x)).length;
  return inter / (A.size + B.size - inter || 1);
}

async function deeplTranslate(
  texts: string[],
  source: string,
  target: string,
  formality?: string
) {
  const form = new URLSearchParams();
  form.append("auth_key", deeplKey);
  texts.forEach((t) => form.append("text", t));
  form.append("source_lang", source.toUpperCase());
  form.append("target_lang", target.toUpperCase());
  if (formality) form.append("formality", formality);
  // Tipp: Format beibehalten, bessere Terminologie
  form.append("preserve_formatting", "1");
  if (glossaryId) form.append("glossary_id", glossaryId);

  const res = await fetch(deeplEndpoint, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: form.toString(),
  });
  if (!res.ok) throw new Error(`DeepL ${res.status}`);
  const data = await res.json();
  return (data?.translations ?? []).map((t: any) => String(t.text));
}

serve(async (req) => {
  // Debug-Ping
  if (new URL(req.url).searchParams.get("debug") === "ping") {
    return new Response(
      JSON.stringify({ ok: true, fn: "ingest_word", build: "v5-qa" }),
      { status: 200 }
    );
  }

  try {
    const sbAdmin = createClient(supabaseUrl, serviceKey);

    const authHeader = req.headers.get("Authorization") ?? "";
    let userId: string | null = null;

    try {
      const sbAuth = createClient(supabaseUrl, serviceKey, {
        global: { headers: { Authorization: authHeader } },
      });
      const { data: auth } = await sbAuth.auth.getUser();
      userId = auth?.user?.id ?? null; // kann null sein
    } catch {
      userId = null;
    }

    const body = (await req.json()) as Body;
    const fromLang = norm(body.fromLang ?? "");
    const toLang = norm(body.toLang ?? "");
    const pos = (body.pos ?? "").toLowerCase();
    const mode = body.mode ?? "create";
    const formality = body.formality ?? "prefer_more";

    // Validierung: entweder id ODER text muss vorhanden sein
    if (!body.id && !body.text) {
      return new Response("Bad Request: id or text required", { status: 400 });
    }
    if (!fromLang || !toLang) {
      return new Response("Bad Request: fromLang and toLang required", {
        status: 400,
      });
    }

    let textNormalized = "";
    let existing = null;
    let sErr = null;

    // 1) Force-Translate by ID (wenn id gegeben) - 100% Treffer
    let row = existing;
    if (!row && body.id) {
      const { data: byId, error: idErr } = await sbAdmin
        .from("words")
        .select("id, text, translation, pos, from_lang, to_lang")
        .eq("id", body.id)
        .maybeSingle();

      if (idErr) throw idErr;
      row = byId || null;
      if (row) {
        existing = row;
        textNormalized = normalizeText(row.text || "");
      } else {
        return new Response(
          JSON.stringify({ ok: false, error: "Word not found by id" }),
          { status: 404, headers: { "Content-Type": "application/json" } }
        );
      }
    }
    // 2) Lookup existierendes Wort by text (case-insensitive, whitespace-tolerant)
    else if (body.text) {
      const raw = norm(body.text);
      textNormalized = normalizeText(raw);

      // Versuch 1: ilike (case-insensitive) - jetzt mit normalisiertem Text
      const lookup1 = await sbAdmin
        .from("words")
        .select("id, text, translation, pos, from_lang, to_lang")
        .eq("from_lang", fromLang)
        .eq("to_lang", toLang)
        .ilike("text", textNormalized)
        .limit(1)
        .maybeSingle();

      if (lookup1.error) {
        sErr = lookup1.error;
      } else if (lookup1.data) {
        // Exakte Übereinstimmung nach Normalisierung prüfen (jetzt case-insensitive)
        if (normalizeText(lookup1.data.text) === textNormalized) {
          existing = lookup1.data;
        }
      }

      // Versuch 2: Falls kein Match, exact match mit normalisiertem Text
      if (!existing && !sErr) {
        const lookup2 = await sbAdmin
          .from("words")
          .select("id, text, translation, pos, from_lang, to_lang")
          .eq("text", textNormalized)
          .eq("from_lang", fromLang)
          .eq("to_lang", toLang)
          .limit(1)
          .maybeSingle();

        if (lookup2.error) {
          sErr = lookup2.error;
        } else if (lookup2.data) {
          existing = lookup2.data;
        }
      }

      // Versuch 3: Falls immer noch kein Match, RPC mit btrim für robuste Whitespace-Behandlung
      if (!existing && !sErr) {
        try {
          const { data: lookup3, error: rpcErr } = await sbAdmin.rpc(
            "find_word_by_normalized_text",
            {
              p_text: textNormalized,
              p_from_lang: fromLang,
              p_to_lang: toLang,
            }
          );

          if (!rpcErr && lookup3 && lookup3.length > 0) {
            existing = lookup3[0];
          }
        } catch (rpcError) {
          // RPC-Funktion existiert möglicherweise nicht, das ist OK
          console.log(
            "RPC lookup not available, continuing with standard search"
          );
        }
      }

      if (sErr) throw sErr;
    }

    let wordId = existing?.id as string | undefined;
    let translation = existing?.translation as string | undefined;
    let finalPos = pos || existing?.pos || "";

    // Heuristik: Nomen auf Deutsch groß schreiben
    const enforceGermanNoun = (de: string) =>
      finalPos === "noun" && de
        ? de.replace(/^([a-zäöü])/u, (m) => m.toUpperCase())
        : de;

    // (a) CREATE-Modus: nur übersetzen, wenn leer
    // (b) FIX-Modus: neu übersetzen, wenn leer ODER QA schlecht
    let needsTranslation = !translation || translation.trim() === "";
    let qa_score: number | null = null;
    let qa_note = "";

    if (mode === "fix" && translation) {
      // Back-translation zur Qualität
      const backEn = await deeplTranslate([translation], "DE", "EN", "default");
      const score = jaccard(textNormalized, backEn[0] || "");
      qa_score = score;
      if (score < 0.55) {
        needsTranslation = true;
        qa_note = "low_backtranslation_similarity";
      }
      // POS-Heuristik: Nomen groß
      if (finalPos === "noun" && /^[a-zäöü]/u.test(translation)) {
        needsTranslation = true;
        qa_note = (qa_note ? qa_note + ";" : "") + "noun_capitalization_fix";
      }
    }

    // Übersetzen (DeepL) - nutze normalisierten Text für konsistente Übersetzungen
    if (needsTranslation) {
      if (!deeplKey) {
        return new Response(
          JSON.stringify({ ok: false, error: "DEEPL_API_KEY missing" }),
          { status: 500 }
        );
      }
      const out = await deeplTranslate(
        [textNormalized],
        fromLang,
        toLang,
        formality
      );
      const rawTranslation = out[0] || "";
      translation = enforceGermanNoun(rawTranslation);

      // Logging: Wenn DeepL leer zurückgibt
      if (!translation || translation.trim() === "") {
        console.error("DeepL returned empty translation for:", {
          text: textNormalized,
          fromLang,
          toLang,
          formality,
          rawResponse: out,
        });
        qa_note = (qa_note ? qa_note + ";" : "") + "deepl_empty_result";
      }
    }

    // Upsert (mit normalisiertem Text)
    const payload: any = {
      text: textNormalized,
      translation: translation ?? "",
      from_lang: fromLang,
      to_lang: toLang,
    };
    if (finalPos) payload.pos = finalPos;
    payload.translated_by = "deepl";
    payload.translated_at = new Date().toISOString();
    if (qa_score !== null) payload.qa_score = qa_score;
    if (qa_note) payload.qa_note = qa_note;

    const { data: up, error: upErr } = await sbAdmin
      .from("words")
      .upsert([payload], {
        onConflict: "text,from_lang,to_lang",
        ignoreDuplicates: false,
      })
      .select("id, translation, qa_score, qa_note")
      .single();
    if (upErr) throw upErr;

    wordId = up.id;
    translation = up.translation;

    // user_words upsert (nur wenn userId existiert)
    if (userId) {
      const { error: uErr } = await sbAdmin.from("user_words").upsert(
        {
          user_id: userId,
          word_id: wordId,
          picked: true,
          source: "browser",
        },
        { onConflict: "user_id,word_id" }
      );
      if (uErr) throw uErr;
    }

    return new Response(
      JSON.stringify({
        ok: true,
        wordId,
        text: textNormalized,
        translation,
        qa_score: up.qa_score ?? qa_score,
        qa_note: up.qa_note ?? qa_note,
        mode,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("ingest_word error:", e);
    const msg =
      e && typeof e === "object"
        ? (e as any).message ?? JSON.stringify(e)
        : String(e);
    return new Response(JSON.stringify({ ok: false, error: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
