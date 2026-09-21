// Rehber (AI guide) proxy — holds OPENAI_API_KEY server-side so the iOS app
// never ships or handles it. Ported from Sources/AI/RehberService.swift;
// the careful system prompt (no fabricated citations, no fatwas) now lives
// here so it can be tuned without an app release.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const SYSTEM_PROMPT = `Sen Zümrüt uygulamasının İslami rehber asistanısın. Kesin kurallar:
1. Bir hadis veya ayet referansı verirken yalnızca gerçekten emin olduğun kaynakları kullan. Emin değilsen "bu konudaki kesin kaynağı doğrulayamıyorum" de — asla uydurma kitap/sayfa numarası verme.
2. Mezhepler arası görüş farkı varsa bunu belirt, tek bir görüşü kesin doğru gibi sunma.
3. Asla fetva verme veya kesin dini hüküm bildirme. Her cevabın sonuna şunu ekle: "Bu bir fetva değildir. Dini hassas kararlarda yerel bir alim veya müftülüğe danışın."
4. Türkçe, kısa, saygılı ve sıcak bir üslupla cevap ver.`;

const MODEL = "gpt-5.6-terra";
// Per-IP cap — a real user has no reason to send more than this many
// Rehber messages in an hour; a leaked/extracted key running in a loop does.
const RATE_LIMIT = 20;
const RATE_WINDOW_SECONDS = 60 * 60;

interface ChatTurn {
  role: string;
  content: string;
}

export default {
  fetch: withSupabase({ auth: ["publishable", "secret"] }, async (req, ctx) => {
    if (req.method !== "POST") {
      return Response.json({ error: "POST bekleniyor." }, { status: 405 });
    }

    const ip = req.headers.get("x-forwarded-for")?.split(",")[0].trim() ?? "unknown";
    const { data: allowed, error: rateLimitError } = await ctx.supabaseAdmin.rpc("check_rate_limit", {
      p_key: `chat:${ip}`,
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

    const { history, question } = (await req.json()) as {
      history: ChatTurn[];
      question: string;
    };
    if (!question || typeof question !== "string") {
      return Response.json({ error: "'question' zorunlu." }, { status: 400 });
    }

    const messages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...(history ?? []).map((turn) => ({ role: turn.role, content: turn.content })),
      { role: "user", content: question },
    ];

    const openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      // No `temperature` override — this model only supports its default (1).
      body: JSON.stringify({ model: MODEL, messages }),
    });

    if (!openaiResponse.ok) {
      const text = await openaiResponse.text();
      return Response.json({ error: `OpenAI hatası: ${text}` }, { status: 502 });
    }

    const decoded = await openaiResponse.json();
    const content = decoded?.choices?.[0]?.message?.content;
    if (!content) {
      return Response.json({ error: "Boş yanıt." }, { status: 502 });
    }

    return Response.json({ content });
  }),
};
