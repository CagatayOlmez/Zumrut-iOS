import StoreKit
import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var store: StoreManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Zümrüt Premium")
                        .font(ZumrutFont.display(20))
                        .foregroundColor(ZumrutColors.gold)
                    Text("Daha derin bir deneyim.")
                        .font(ZumrutFont.body(12))
                        .foregroundColor(ZumrutColors.muted)
                }
                .padding(.top, 16)

                if store.isPremium {
                    Text("Premium aktif ✓")
                        .font(ZumrutFont.body(13, weight: .semibold))
                        .foregroundColor(ZumrutColors.teal)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(ZumrutColors.tealTint)
                        .clipShape(Capsule())
                }

                compareList

                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(ZumrutFont.body(12))
                        .foregroundColor(ZumrutColors.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                } else if store.products.isEmpty {
                    ProgressView().tint(ZumrutColors.teal)
                } else {
                    ForEach(store.products) { product in
                        Button {
                            Task { await store.purchase(product) }
                        } label: {
                            HStack {
                                Text(product.displayName).font(ZumrutFont.body(14, weight: .semibold))
                                Spacer()
                                Text(product.displayPrice).font(ZumrutFont.mono(13))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(ZumrutColors.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Text("İstediğin zaman iptal et.")
                    .font(ZumrutFont.mono(10))
                    .foregroundColor(ZumrutColors.muted)
                    .padding(.bottom, 20)
            }
        }
        .background(ZumrutColors.paper)
        .task { await store.loadProducts() }
    }

    private var compareList: some View {
        VStack(spacing: 0) {
            compareRow("Namaz vakitleri", free: true, premium: true)
            compareRow("Temel Kur'an", free: true, premium: true)
            compareRow("Rehber & Tilavet (AI)", free: false, premium: true)
            compareRow("Aile Hesabı (çoklu profil)", free: false, premium: true)
        }
        .padding(.horizontal, 20)
    }

    private func compareRow(_ title: String, free: Bool, premium: Bool) -> some View {
        HStack {
            Text(title).font(ZumrutFont.body(12)).foregroundColor(ZumrutColors.ink)
            Spacer()
            Text(free ? "✓" : "–").frame(width: 20).foregroundColor(ZumrutColors.muted)
            Text(premium ? "✓" : "–").frame(width: 20).foregroundColor(ZumrutColors.gold)
        }
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) { Rectangle().fill(ZumrutColors.line).frame(height: 1) }
    }
}
