// Tilavet (recitation check) proxy — forwards the recorded audio to
// OpenAI's transcription API. Ported from
// Sources/AI/TranscriptionService.swift; OPENAI_API_KEY stays server-side.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const MODEL = "gpt-4o-mini-transcribe";

export default {
  fetch: withSupabase({ auth: ["publishable", "secret"] }, async (req) => {
    if (req.method !== "POST") {
      return Response.json({ error: "POST bekleniyor." }, { status: 405 });
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
