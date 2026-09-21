import SwiftUI

// First-launch screen — copy ported verbatim from the "Onboarding" mockup.
// There's no login/account system in the app, so the mockup's "Zaten
// hesabım var" link is intentionally omitted (it would do nothing).
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            ZStack {
                Circle().fill(ZumrutColors.tealTint).frame(width: 84, height: 84)
                Image(systemName: "sparkles")
                    .font(.system(size: 30))
                    .foregroundColor(ZumrutColors.teal)
            }

            Text("Zümrüt'e Hoş Geldiniz")
                .font(ZumrutFont.display(24))
                .foregroundColor(ZumrutColors.ink)
                .multilineTextAlignment(.center)

            Text("Namaz, Kur'an ve daha fazlası — hep yanınızda.")
                .font(ZumrutFont.body(14))
                .foregroundColor(ZumrutColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                withAnimation { hasSeenOnboarding = true }
            } label: {
                Text("Devam Et")
                    .font(ZumrutFont.body(15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ZumrutColors.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 30)

            Text("Konum ve kullanım verileriniz yalnızca cihazınızda kalır, üçüncü taraflarla paylaşılmaz.")
                .font(ZumrutFont.mono(10))
                .foregroundColor(ZumrutColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZumrutColors.paper)
    }
}
