import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        RehberView()
                    } label: {
                        Label("Rehber (AI)", systemImage: "bubble.left.and.bubble.right")
                    }
                    NavigationLink {
                        PremiumView()
                    } label: {
                        Label("Premium", systemImage: "star.circle")
                    }
                } header: {
                    Text("Hesap")
                }

                Section {
                    Link(destination: URL(string: "https://cagatayolmez.github.io/Zumrut-iOS/privacy.html")!) {
                        Label("Gizlilik Politikası", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://cagatayolmez.github.io/Zumrut-iOS/terms.html")!) {
                        Label("Kullanım Şartları", systemImage: "doc.text")
                    }
                } header: {
                    Text("Yasal")
                }
            }
            .navigationTitle("Profil")
        }
    }
}
