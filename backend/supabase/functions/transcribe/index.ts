// Tilavet (recitation check) proxy — forwards the recorded audio to
// OpenAI's transcription API. Ported from
// Sources/AI/TranscriptionService.swift; OPENAI_API_KEY stays server-side.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const MODEL = "gpt-4o-mini-transcribe";
// Per-IP cap — same reasoning as chat/index.ts.
const RATE_LIMIT = 20;
const RATE_WINDOW_SECONDS = 60 * 60;

export default {
  fetch: withSupabase({ auth: ["publishable", "secret"] }, async (req, ctx) => {
    if (req.method !== "POST") {
      return Response.json({ error: "POST bekleniyor." }, { status: 405 });
    }

    const ip = req.headers.get("x-forwarded-for")?.split(",")[0].trim() ?? "unknown";
    const { data: allowed, error: rateLimitError } = await ctx.supabaseAdmin.rpc("check_rate_limit", {
      p_key: `transcribe:${ip}`,
      p_limit: RATE_LIMIT,
      p_window_seconds: RATE_WINDOW_SECONDS,
    });
    if (!rateLimitError && allowed === false) {
      return Response.json({ error: "Çok fazla istek gönderildi. Lütfen bir süre sonra tekrar deneyin." }, { status: 429 });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return Response.json({ error: "Sunucu yapılandırması eksik." }, { status: 500 });
    }

    const incomingForm = await req.formData();
    const audioFile = incomingForm.get("file");
    if (!(audioFile instanceof File)) {
      return Response.json({ error: "'file' alanı zorunlu." }, { status: 400 });
    }

    const outgoingForm = new FormData();
    outgoingForm.set("model", MODEL);
    outgoingForm.set("language", "ar");
    outgoingForm.set("file", audioFile, "recording.m4a");

    const openaiResponse = await fetch("https://api.openai.com/v1/audio/transcriptions", {
      method: "POST",
      headers: { Authorization: `Bearer ${apiKey}` },
      body: outgoingForm,
    });

    if (!openaiResponse.ok) {
      const text = await openaiResponse.text();
      return Response.json({ error: `OpenAI hatası: ${text}` }, { status: 502 });
    }

    const decoded = (await openaiResponse.json()) as { text?: string };
    if (!decoded.text) {
      return Response.json({ error: "Boş yanıt." }, { status: 502 });
    }

    return Response.json({ text: decoded.text });
  }),
};
