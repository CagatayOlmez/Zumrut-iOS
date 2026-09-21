# Zümrüt backend (Supabase)

Bu klasör, Rehber/Tilavet için OpenAI'ı sunucu tarafında çağıran proxy fonksiyonlarını, dua sesini (TTS + cache), ve Dualar/Günün Bilgisi içeriğini tuttuğun veritabanını içeriyor. OpenAI anahtarı yalnızca burada, cihazda hiç yok.

Bunları Claude çalıştıramaz — kendi Supabase/OpenAI hesabınla yapman gerekiyor. `npx supabase` bu makinede çalışıyor (global kurulum gerekmez), aşağıdaki komutları `backend/` klasöründe çalıştır.

## 1. Supabase projesi oluştur

[supabase.com](https://supabase.com) üzerinden ücretsiz bir proje aç. Proje panelinde **Project Settings → API Keys** altından `Project URL` ve **`Publishable key`**'i (`sb_publishable_...` ile başlar) not al — bunlar 5. adımda iOS tarafına girilecek.

> ⚠️ **`anon public` (legacy JWT, `eyJ...` ile başlayan) anahtarı DEĞİL** — o REST çağrılarında (duas/info_cards) çalışır ama deploy edilen Edge Function'lar (`withSupabase` yardımcı fonksiyonu) yalnızca yeni `sb_publishable_...` formatını kabul ediyor. 2026-08-25'te canlı projede doğrulandı: legacy anon key ile `chat` fonksiyonu `INVALID_CREDENTIALS` hatası veriyor, publishable key ile çalışıyor.

## 2. CLI'ı projene bağla

```bash
cd backend
npx supabase login
npx supabase link --project-ref <PROJECT_REF>   # Project Settings → General'de görünür
```

## 3. Veritabanını kur

```bash
npx supabase db push
```

Bu, `supabase/migrations/20260825115609_content.sql` dosyasındaki `duas`/`info_cards` tablolarını ve `dua-audio` Storage bucket'ını oluşturur. İçerik eklemek için artık **Supabase Studio → Table Editor**'a gir, `duas` veya `info_cards` tablosuna satır ekle — uygulama bir sonraki açılışta otomatik çeker, App Store paketi gerekmez.

## 4. OpenAI anahtarını sunucuya ekle ve fonksiyonları yayınla

```bash
npx supabase secrets set OPENAI_API_KEY=sk-...
npx supabase functions deploy chat transcribe tts
```

`tts` fonksiyonundaki model adı (`gpt-4o-mini-tts`) deploy anında güncel olup olmadığını kontrol et — OpenAI'ın TTS model isimleri zamanla değişebilir (`backend/supabase/functions/tts/index.ts` içinde işaretli).

## 5. iOS tarafını bağla

`Sources/Networking/SupabaseConfig.swift` içine 1. adımdaki `Project URL` ve **publishable key**'i yapıştır. Bundan sonra Rehber, Tilavet ve Dualar sesi gerçek anahtarınla çalışır — uygulamayı kullanan kimse hiçbir zaman kendi anahtarını girmek zorunda kalmaz.

Bu proje için zaten yapıldı ve `curl` ile uçtan uca doğrulandı (2026-08-25): `chat`, `tts`, `transcribe` ve REST (`duas`/`info_cards`) hepsi çalışıyor. `dua-audio` bucket'ında test amaçlı oluşmuş bir `test-dua.mp3` dosyası var, istersen Studio → Storage'dan silebilirsin, zararsız.

## Notlar

- Fonksiyonlar `apiKey` header'ıyla çağrılıyor (Supabase'in `withSupabase` yardımcı fonksiyonu bunu doğruluyor) — iOS tarafı bunu `anon key` ile otomatik gönderiyor, ek bir kullanıcı girişi gerekmez.
- `dua-audio` bucket'ı public-read: bir dua ilk kez dinlendiğinde OpenAI TTS ile üretilip bucket'a yazılıyor, sonraki her istek aynı dosyayı anında döndürüyor (tekrar tekrar OpenAI'a gitmiyor).
- Maliyet/kötüye kullanım koruması (rate limiting vb.) bu ilk sürümde yok — kullanıcı sayısı büyürse eklenmesi gereken bir sonraki adım budur.
