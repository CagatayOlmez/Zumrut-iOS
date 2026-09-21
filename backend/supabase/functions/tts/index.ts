// Dua recitation audio — generates speech for a dua's Arabic text via
// OpenAI TTS the first time it's requested, then caches the mp3 in the
// `dua-audio` Storage bucket so every later request (any user) for the same
// dua is served instantly with no further OpenAI cost.
//
// NOTE: verify "gpt-4o-mini-tts" is still the model you want at deploy
// time — OpenAI's TTS model lineup changes; this was a reasonable choice
// as of when this function was written, not a guarantee it's current.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const MODEL = "gpt-4o-mini-tts";
const VOICE = "alloy";
const BUCKET = "dua-audio";

export default {
  fetch: withSupabase({ auth: ["publishable", "secret"] }, async (req, ctx) => {
    if (req.method !== "POST") {
      return Response.json({ error: "POST bekleniyor." }, { status: 405 });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return Response.json({ error: "Sunucu yapılandırması eksik." }, { status: 500 });
    }

    const { duaId, text } = (await req.json()) as { duaId?: string; text?: string };
    if (!duaId || !text) {
      return Response.json({ error: "'duaId' ve 'text' zorunlu." }, { status: 400 });
    }

    const path = `${duaId}.mp3`;
    const storage = ctx.supabaseAdmin.storage.from(BUCKET);

    const existing = await storage.createSignedUrl(path, 60 * 60);
    if (!existing.error) {
      const { data: publicData } = storage.getPublicUrl(path);
      return Response.json({ audioUrl: publicData.publicUrl });
    }

    // Only rate-limit past this point — cache hits above are free and
    // shouldn't count against a user just replaying duas.
    const ip = req.headers.get("x-forwarded-for")?.split(",")[0].trim() ?? "unknown";
    const { data: allowed, error: rateLimitError } = await ctx.supabaseAdmin.rpc("check_rate_limit", {
      p_key: `tts:${ip}`,
      p_limit: 20,
      p_window_seconds: 60 * 60,
    });
    if (!rateLimitError && allowed === false) {
      return Response.json({ error: "Çok fazla istek gönderildi. Lütfen bir süre sonra tekrar deneyin." }, { status: 429 });
    }

    const openaiResponse = await fetch("https://api.openai.com/v1/audio/speech", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ model: MODEL, voice: VOICE, input: text, response_format: "mp3" }),
    });

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text();
      return Response.json({ error: `OpenAI hatası: ${errorText}` }, { status: 502 });
    }

    const audioBytes = new Uint8Array(await openaiResponse.arrayBuffer());
    const upload = await storage.upload(path, audioBytes, {
      contentType: "audio/mpeg",
      upsert: true,
    });
    if (upload.error) {
      return Response.json({ error: `Depolamaya yazılamadı: ${upload.error.message}` }, { status: 500 });
    }

    const { data: publicData } = storage.getPublicUrl(path);
    return Response.json({ audioUrl: publicData.publicUrl });
  }),
};
