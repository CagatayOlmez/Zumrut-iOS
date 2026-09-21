import SwiftUI

// Shown in place of a premium-only feature's content until the user has an
// active subscription — replaces the previous behavior where Rehber and
// Tilavet were fully usable despite being listed as premium-only.
struct PremiumLockedView: View {
    let title: String
    let message: String

    @State private var showingPremium = false

    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 34))
                .foregroundColor(ZumrutColors.gold)
            Text(title)
                .font(ZumrutFont.display(18))
                .foregroundColor(ZumrutColors.ink)
            Text(message)
                .font(ZumrutFont.body(13))
                .foregroundColor(ZumrutColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button {
                showingPremium = true
            } label: {
                Text("Premium'a Geç")
                    .font(ZumrutFont.body(14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(ZumrutColors.teal)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZumrutColors.paper)
        .sheet(isPresented: $showingPremium) { PremiumView() }
    }
}
