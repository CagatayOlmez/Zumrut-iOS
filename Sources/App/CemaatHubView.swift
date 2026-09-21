import SwiftUI

// Root of the Cemaat tab: a simple menu into the community-facing screens
// that previously each had their own top-level tab.
struct CemaatHubView: View {
    var body: some View {
        List {
            hubLink(title: "Camiler", subtitle: "Yakınındaki camileri bul", systemImage: "building.columns") { MosqueFinderView() }
            hubLink(title: "Etkinlikler", subtitle: "İftar, sohbet ve diğer etkinlikler", systemImage: "calendar") { EtkinliklerView() }
            hubLink(title: "Günün Bilgisi", subtitle: "Günlük hadis ve ayet", systemImage: "sparkles") { InfoCardView() }
            hubLink(title: "Kurumsal", subtitle: "Cami, vakıf ve kurumlar için Zümrüt", systemImage: "building.2") { KurumsalView() }
        }
        .listStyle(.plain)
        .navigationTitle("Cemaat")
        .background(ZumrutColors.paper)
    }

    private func hubLink<Destination: View>(title: String, subtitle: String, systemImage: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(ZumrutColors.teal)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(ZumrutFont.body(15, weight: .semibold))
                        .foregroundColor(ZumrutColors.ink)
                    Text(subtitle)
                        .font(ZumrutFont.mono(11))
                        .foregroundColor(ZumrutColors.muted)
                }
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(ZumrutColors.paper)
    }
}
