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
            }
            .navigationTitle("Profil")
        }
    }
}
