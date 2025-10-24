// supabase/functions/translate-missing/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type ReqBody = {
  // Wie viele insgesamt in diesem Aufruf maximal bearbeiten?
  maxTotal?: number; // Default 5000
  // Wie viele DB-Zeilen pro Runde laden?
  chunkSize?: number; // Default 500 (max 2000)
  // Wie viele Texte pro DeepL-Request?
  deeplBatchSize?: number; // Default 50 (sicher)
  category?: string; // optional Filter, braucht v_words_with_categories
  formality?: "default" | "prefer_more" | "prefer_less";
  writeQa?: boolean; // Back-Translation + qa_score/qa_note (langsamer)
  dryRun?: boolean; // nur simulieren
  sleepMsBetweenBatches?: number; // Pause zwischen DeepL-Requests (Default 150ms)
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const DEEPL_KEY = Deno.env.get("DEEPL_API_KEY")!;
const GLOSSARY_ID = Deno.env.get("DEEPL_GLOSSARY_ID") || "";
const DL_ENDPOINT =
  Deno.env.get("DEEPL_ENDPOINT") || "https://api-free.deepl.com/v2/translate";

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

function jaccard(a: string, b: string) {
  const A = new Set(a.toLowerCase().split(/\s+/).filter(Boolean));
  const B = new Set(b.toLowerCase().split(/\s+/).filter(Boolean));
  const inter = [...A].filter((x) => B.has(x)).length;
  const denom = A.size + B.size - inter;
  return denom > 0 ? inter / denom : 1;
}

async function deeplBatch(
  texts: string[],
  src = "EN",
  tgt = "DE",
  formality?: string
) {
  const form = new URLSearchParams();
  form.append("auth_key", DEEPL_KEY);
  texts.forEach((t) => form.append("text", t));
  form.append("source_lang", src);
  form.append("target_lang", tgt);
  form.append("preserve_formatting", "1");
  if (formality) form.append("formality", formality);
  if (GLOSSARY_ID) form.append("glossary_id", GLOSSARY_ID);

  const maxRetries = 6; // bis ~ 1+2+4+8+16+32s
  let delay = 1000; // ms
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const res = await fetch(DL_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: form.toString(),
    });

    if (res.ok) {
      const json = await res.json();
      return (json?.translations ?? []).map((t: any) => String(t.text));
    }

    // 429 = Rate Limit → warten & retry
    if (res.status === 429) {
      // Retry-After Header, falls vorhanden, respektieren
      const ra = Number(res.headers.get("Retry-After"));
      const waitMs = !Number.isNaN(ra) && ra > 0 ? ra * 1000 : delay;
      await new Promise((r) => setTimeout(r, waitMs));
      delay = Math.min(delay * 2, 30000); // exponentiell bis max 30s
      continue;
    }

    // 5xx → kurzfristige Serverprobleme → kurzer Retry
    if (res.status >= 500 && res.status < 600) {
      await new Promise((r) => setTimeout(r, delay));
      delay = Math.min(delay * 2, 30000);
      continue;
    }

    const txt = await res.text().catch(() => "");
    throw new Error(`DeepL ${res.status}: ${txt}`);
  }

  throw new Error("DeepL: max retries exceeded");
}

serve(async (req) => {
  try {
    // Authorization prüfen (JWT, i. d. R. Anon-Key)
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader)
      return new Response(
        JSON.stringify({ ok: false, error: "Missing Authorization header" }),
        { status: 401 }
      );

    const body = (await req.json().catch(() => ({}))) as ReqBody;
    const maxTotal = Math.max(1, Math.min(body.maxTotal ?? 5000, 50000)); // harte Kappe
    const chunkSize = Math.max(1, Math.min(body.chunkSize ?? 500, 2000)); // pro DB-Load
    const deeplBatchSize = Math.max(
      1,
      Math.min(body.deeplBatchSize ?? 50, 100)
    ); // pro DeepL-Call
    const formality = body.formality ?? "prefer_more";
    const writeQa = !!body.writeQa; // langsamer
    const dryRun = !!body.dryRun;
    const sleepMs = Math.max(0, body.sleepMsBetweenBatches ?? 150);
    const category = body.category?.trim();

    if (!SUPABASE_URL || !SERVICE_KEY)
      return new Response(
        JSON.stringify({
          ok: false,
          error: "Server misconfigured (SUPABASE_URL/SERVICE_KEY)",
        }),
        { status: 500 }
      );
    if (!DEEPL_KEY)
      return new Response(
        JSON.stringify({ ok: false, error: "DEEPL_API_KEY missing" }),
        { status: 500 }
      );

    const sb = createClient(SUPABASE_URL, SERVICE_KEY);

    let processed = 0;
    let fetchedThisRound = 0;
    let rounds = 0;

    const selectMissing = async () => {
      if (category) {
        const r = await sb
          .from("v_words_with_categories")
          .select(
            "id,text,from_lang,to_lang,level,pos,category_slug,translation"
          )
          .eq("category_slug", category)
          .eq("from_lang", "en")
          .eq("to_lang", "de")
          .or("translation.is.null,translation.eq.")
          .order("text", { ascending: true })
          .limit(chunkSize);
        if (r.error) throw r.error;
        return r.data as any[];
      } else {
        const r = await sb
          .from("words")
          .select("id,text,from_lang,to_lang,level,pos,translation")
          .eq("from_lang", "EN".toLowerCase())
          .eq("to_lang", "DE".toLowerCase())
          .or("translation.is.null,translation.eq.")
          .order("text", { ascending: true })
          .limit(chunkSize);
        if (r.error) throw r.error;
        return r.data as any[];
      }
    };

    while (processed < maxTotal) {
      const rows = (await selectMissing()).filter(
        (r) => r.text && String(r.text).trim() !== ""
      );
      fetchedThisRound = rows.length;
      if (fetchedThisRound === 0) break;
      rounds++;

      const texts = rows.map((r) => String(r.text));
      let translations: string[] = [];
      let backTranslations: string[] = [];

      if (dryRun) {
        // nichts
      } else {
        // DeepL in Teilpaketen
        for (let i = 0; i < texts.length; i += deeplBatchSize) {
          const slice = texts.slice(i, i + deeplBatchSize);
          const res = await deeplBatch(slice, "EN", "DE", formality);
          translations.push(...res);
          if (sleepMs) await sleep(sleepMs);
        }
        if (writeQa) {
          for (let i = 0; i < translations.length; i += deeplBatchSize) {
            const slice = translations.slice(i, i + deeplBatchSize);
            const res = await deeplBatch(slice, "DE", "EN", "default");
            backTranslations.push(...res);
            if (sleepMs) await sleep(sleepMs);
          }
        }
      }

      const ts = new Date().toISOString();
      const updates = rows.map((r, i) => {
        const tr = dryRun ? null : translations[i] ?? null;
        const qa_score =
          writeQa && !dryRun
            ? jaccard(String(r.text), backTranslations[i] || "")
            : null;
        const qa_note =
          writeQa && qa_score !== null && qa_score < 0.55
            ? "low_backtranslation_similarity"
            : "";
        return {
          id: r.id,
          text: r.text, // Pflichtfelder für Insert-Sicherheit
          from_lang: r.from_lang,
          to_lang: r.to_lang,
          translation: tr,
          translated_by: tr ? "deepl" : null,
          translated_at: tr ? ts : null,
          qa_score,
          qa_note,
        };
      });

      if (!dryRun) {
        const up = await sb
          .from("words")
          .upsert(updates, { onConflict: "id", ignoreDuplicates: false })
          .select("id");
        if (up.error) throw up.error;
      }

      processed += rows.length;
      if (rows.length === 0) break; // nur stoppen, wenn wirklich nichts mehr fehlt
    }

    return new Response(
      JSON.stringify({
        ok: true,
        processed,
        rounds,
        last_chunk: fetchedThisRound,
        category: category || null,
        formality,
        writeQa,
        dryRun,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("translate-missing error:", e);
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
