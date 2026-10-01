# Zümrüt — Canlıya Çıkış Kontrol Kulesi

Son güncelleme: 2026-10-01 — **App Store'a inceleme için gönderildi (v1.0, Build 1).**

## Durum

| Alan | Durum |
|---|---|
| Git deposu | ✅ github.com/CagatayOlmez/Zumrut-iOS (public) |
| Restore Purchases | ✅ `StoreManager.restorePurchases()` + Premium ekranında buton |
| Gizlilik Politikası | ✅ https://cagatayolmez.github.io/Zumrut-iOS/privacy.html |
| Kullanım Şartları | ✅ https://cagatayolmez.github.io/Zumrut-iOS/terms.html |
| Destek sayfası | ✅ https://cagatayolmez.github.io/Zumrut-iOS/support.html |
| Onboarding gizlilik metni | ✅ düzeltildi (konum/ses verisi iddiası artık doğru) |
| Backend rate limiting | ✅ chat/transcribe/tts fonksiyonlarında IP başına saatlik limit, deploy edildi |
| Kur'an offline cache | ✅ sure listesi + detay UserDefaults'ta cache'leniyor |
| PrivacyInfo.xcprivacy | ✅ eklendi (konum/ses + UserDefaults API gerekçesi) |
| Yerel StoreKit test config | ✅ `Zumrut.storekit`, şemaya bağlı |
| App Store Connect — Abonelikler | ✅ Zümrüt Premium grubu, `premium.monthly` + `premium.yearly`, "Ready for Review" |
| App Store Connect — App Privacy | ✅ Precise Location + Audio Data, "App Functionality", "Data Not Linked to You" |
| App Store Connect — metadata | ✅ Description, Keywords, Support/Marketing URL, Promotional Text, Copyright |
| App Store Connect — Screenshots | ✅ 5 adet özel tasarım ekran görüntüsü yüklendi |
| App Store Connect — Age Rating | ✅ 4+ |
| Build yükleme | ✅ Build 1 (1.0.0) yüklendi |
| **Submission** | ✅ **2026-10-01'de "Add for Review" ile gönderildi** |

## Bekleyen / takip edilecek

- Apple incelemesi sonucu (genelde 24-48 saat) — onay/red bildirimini App Store Connect'ten takip et.
- Supabase projesi **Free plan**'da — ~1 hafta işlemsizlikte otomatik duraklıyor. Canlıya çıkınca trafiği izle, gerekirse **Pro'ya yükselt** (aksi halde Rehber/Tilavet/dua sesi bir anda çalışmaz hale gelebilir).
- `duas` / `info_cards` tabloları prod'da büyük ölçüde boş — Supabase Studio'dan gerçek içerik eklenmesi gerekiyor (uygulama bundled seed içerikle idare ediyor ama admin içeriği henüz girilmedi).
- Backend'de maliyet/kötüye kullanım koruması şu an sadece basit IP rate limiti — kullanıcı sayısı büyürse daha güçlü bir koruma (örn. App Attest, kullanıcı başına kota) değerlendirilmeli.

## Önemli tanımlayıcılar

- Bundle ID: `com.cagatayolmez.Zumrut`
- Supabase project ref: `agwfkynpzoaoexbytblz`
- Subscription Group ID: `22404536`
- Product ID'ler: `com.cagatayolmez.Zumrut.premium.monthly`, `com.cagatayolmez.Zumrut.premium.yearly`
