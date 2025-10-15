// supabase/functions/ingest_word/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
type Body = { text: string; fromLang: string; toLang: string };

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const deeplKey    = Deno.env.get("DEEPL_API_KEY")!;

async function translateIfNeeded(text: string, fromLang: string, toLang: string) {
  if (!deeplKey) return null;
  // DeepL: nur wenn translation fehlt (Wir speichern Original + Übersetzung in words)
  const params = new URLSearchParams({
    auth_key: deeplKey,
    text,
    source_lang: fromLang.toUpperCase(),
    target_lang: toLang.toUpperCase()
  });
  const res = await fetch("https://api-free.deepl.com/v2/translate", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: params.toString(),
  });
  if (!res.ok) return null;
  const data = await res.json();
  const translated = data?.translations?.[0]?.text as string | undefined;
  return translated ?? null;
}

function extractWord(raw: string): string | null {
  // URLs raus
  let s = raw.replace(/\bhttps?:\/\/\S+/gi, " ");
  // Sonderzeichen weg, nur Wort-Tokens lassen
  const m = s.match(/\b[a-zA-Z][a-zA-Z'-]{1,38}\b/);
  if (!m) return null;
  const w = m[0].toLowerCase();
  // sehr kurze "stop"-Fragmente filtern (z. B. 'a', 'of')
  if (w.length < 2) return null;
  return w;
}

serve(async (req) => {
  // --- DEBUG: ganz oben, keine Auth nötig ---
  const u = new URL(req.url);
  if (u.searchParams.get("debug") === "ping") {
    return new Response(
      JSON.stringify({ ok: true, fn: "ingest_word", build: "v4-top-shortcircuit" }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  try {
    // Nur für Auth (liest den User aus dem JWT im Header)
    const sbAuth = createClient(supabaseUrl, serviceKey, {
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });

    // Für alle DB-Reads/Writes OHNE Authorization-Header → umgeht RLS
    const sbAdmin = createClient(supabaseUrl, serviceKey);

    // Auth-Kontext holen
    const { data: auth, error: authErr } = await sbAuth.auth.getUser();
    if (authErr) throw authErr;
    if (!auth?.user) return new Response("Unauthorized", { status: 401 });

    // Body + Wort extrahieren
    const body = (await req.json()) as Body;
    const raw  = (body.text ?? "").trim();
    const fromLang = (body.fromLang ?? "").trim();
    const toLang   = (body.toLang ?? "").trim();
    if (!raw || !fromLang || !toLang) return new Response("Bad Request", { status: 400 });

    const text = extractWord(raw);
    if (!text) {
      return new Response(JSON.stringify({ ok:false, error:"No single word found" }),
        { status: 400, headers: { "Content-Type": "application/json" } });
    }

    // 1) exaktes Lookup (wir speichern lowercase)
    const { data: existing, error: sErr } = await sbAdmin
      .from("words")
      .select("id, translation")
      .eq("text", text)
      .eq("from_lang", fromLang)
      .eq("to_lang", toLang)
      .limit(1)
      .maybeSingle();
    if (sErr) throw sErr;

    let wordId = existing?.id as string | undefined;
    let translation = existing?.translation as string | undefined;
    let wasNewWord = false;

    // NEW: Übersetzung nachtragen, falls Wort existiert aber translation leer ist
    if (wordId && (!translation || translation.trim() === "")) {
      const fixTr = await translateIfNeeded(text, fromLang, toLang);
      if (fixTr) {
        const { data: upd, error: upErr2 } = await sbAdmin
          .from("words")
          .update({ translation: fixTr })
          .eq("id", wordId)
          .select("translation")
          .single();
        if (upErr2) throw upErr2;
        translation = upd?.translation ?? fixTr;
      }
    }

    // 2) Insert als UPSERT gegen UNIQUE(text, from_lang, to_lang)
    if (!wordId) {
      const deeplTranslation = await translateIfNeeded(text, fromLang, toLang);
      translation = deeplTranslation ?? translation ?? "";

      const { data: ins, error: upErr } = await sbAdmin
        .from("words")
        .upsert(
          [{ text, translation, from_lang: fromLang, to_lang: toLang }],
          { onConflict: "text,from_lang,to_lang", ignoreDuplicates: false }
        )
        .select("id, translation")
        .single();
      if (upErr) throw upErr;

      wordId = ins.id;
      translation = ins.translation ?? translation ?? "";
      wasNewWord = true;
    }

    // 3) user_words upsert
    const { error: uErr } = await sbAdmin.from("user_words").upsert({
      user_id: auth.user.id,
      word_id: wordId,
      picked: true,
      source: "browser",
    }, { onConflict: "user_id,word_id" });
    if (uErr) throw uErr;

    // 4) Antwort (ohne Browser-Count/Link)
    return new Response(JSON.stringify({
      ok: true,
      wordId,
      text,
      translation,
      wasNewWord,
    }), { status: 200, headers: { "Content-Type": "application/json" }});
  } catch (e: unknown) {
    console.error("ingest_word error:", e);
    let msg = "unknown";
    if (e && typeof e === "object") {
      const a = e as any;
      msg =
        a.message ??
        a.error ??
        a.code ??
        (a.details ? `${a.hint ?? ""} ${a.details}`.trim() : null) ??
        JSON.stringify(a);
    } else {
      msg = String(e);
    }
    return new Response(
      JSON.stringify({ ok: false, error: msg }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

