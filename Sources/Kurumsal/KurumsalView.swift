import SwiftUI

struct KurumsalView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kurumunuz için Zümrüt")
                        .font(ZumrutFont.display(18))
                        .foregroundColor(ZumrutColors.ink)
                    Text("Camiiniz, vakfınız veya okulunuz için kendi markanızla Zümrüt.")
                        .font(ZumrutFont.body(13))
                        .foregroundColor(ZumrutColors.muted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 10) {
                    featureRow("Kendi logo ve renkleriniz")
                    featureRow("Cemaate özel bildirimler")
                    featureRow("Etkinlik ve bağış yönetim paneli")
                    featureRow("Aylık kurumsal lisans")
                }
                .padding(.horizontal, 20)

                Button { requestOffer() } label: {
                    Text("Teklif İste")
                        .font(ZumrutFont.body(14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ZumrutColors.teal)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 20)

                Text("E-posta uygulamanız, önceden doldurulmuş bir talep e-postasıyla açılır.")
                    .font(ZumrutFont.mono(10))
                    .foregroundColor(ZumrutColors.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 24)
        }
        .background(ZumrutColors.paper)
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(ZumrutColors.teal)
                .font(.system(size: 14))
            Text(text).font(ZumrutFont.body(13)).foregroundColor(ZumrutColors.ink)
        }
    }

    private func requestOffer() {
        let subject = "Zümrüt Kurumsal Paket Talebi"
        let body = "Merhaba,\n\nKurumumuz için Zümrüt kurumsal paketi hakkında bilgi almak istiyoruz."
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "mailto:?subject=\(encodedSubject)&body=\(encodedBody)")
        else { return }
        openURL(url)
    }
}
