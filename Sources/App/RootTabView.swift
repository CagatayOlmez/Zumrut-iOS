import SwiftUI

struct RootTabView: View {
    @StateObject private var store = StoreManager()
    @StateObject private var contentStore = ContentStore()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Ana Sayfa", systemImage: "house") }

            NavigationStack {
                SurahListView()
            }
            .tabItem { Label("Kur'an", systemImage: "book") }

            NavigationStack {
                TakipHubView()
            }
            .tabItem { Label("Takip", systemImage: "checklist") }

            NavigationStack {
                CemaatHubView()
            }
            .tabItem { Label("Cemaat", systemImage: "person.3") }

            SettingsView()
                .tabItem { Label("Profil", systemImage: "person.circle") }
        }
        .tint(ZumrutColors.teal)
        .environmentObject(store)
        .environmentObject(contentStore)
        .task { await store.refreshEntitlements() }
        .task { await contentStore.load() }
    }
}
