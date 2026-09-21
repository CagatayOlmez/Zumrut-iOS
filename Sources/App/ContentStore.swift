import SwiftUI

// Loaded once at app launch (see RootTabView) and shared via environment so
// Dualar and Günün Bilgisi don't each independently re-fetch when the user
// switches tabs. Always starts from the bundled seed so both screens have
// something to show immediately, even before the network responds.
@MainActor
final class ContentStore: ObservableObject {
    @Published var duas: [StaticDua] = DuaLibrary.seed
    @Published var infoCards: [InfoCard] = InfoCardLibrary.seed

    func load() async {
        async let duasResult: Void = loadDuas()
        async let infoCardsResult: Void = loadInfoCards()
        _ = await (duasResult, infoCardsResult)
    }

    private func loadDuas() async {
        if let cached = ContentService.cachedDuas() {
            duas = ContentService.merge(seed: DuaLibrary.seed, remote: cached)
        }
        guard let fetched = try? await ContentService.fetchDuas() else { return }
        ContentService.cacheDuas(fetched)
        duas = ContentService.merge(seed: DuaLibrary.seed, remote: fetched)
    }

    private func loadInfoCards() async {
        if let cached = ContentService.cachedInfoCards() {
            infoCards = ContentService.merge(seed: InfoCardLibrary.seed, remote: cached)
        }
        guard let fetched = try? await ContentService.fetchInfoCards() else { return }
        ContentService.cacheInfoCards(fetched)
        infoCards = ContentService.merge(seed: InfoCardLibrary.seed, remote: fetched)
    }
}
