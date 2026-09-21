import Foundation

// Fetches admin-editable content (see backend/README.md) from the Supabase
// `duas`/`info_cards` tables and caches the last successful fetch, mirroring
// PrayerTimesService's fetch/cache split — same reasoning: content should
// still show if the network is down, using whatever was last fetched.
enum ContentService {
    private static let duasCacheKey = "cachedDuas"
    private static let infoCardsCacheKey = "cachedInfoCards"

    static func fetchDuas() async throws -> [StaticDua] {
        try await fetchRows(table: "duas")
    }

    static func fetchInfoCards() async throws -> [InfoCard] {
        try await fetchRows(table: "info_cards")
    }

    private static func fetchRows<T: Decodable>(table: String) async throws -> [T] {
        let request = SupabaseConfig.authorizedRequest(url: SupabaseConfig.restURL(table: table))
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([T].self, from: data)
    }

    static func cacheDuas(_ duas: [StaticDua], userDefaults: UserDefaults = .standard) {
        cache(duas, key: duasCacheKey, userDefaults: userDefaults)
    }

    static func cachedDuas(userDefaults: UserDefaults = .standard) -> [StaticDua]? {
        cached(key: duasCacheKey, userDefaults: userDefaults)
    }

    static func cacheInfoCards(_ cards: [InfoCard], userDefaults: UserDefaults = .standard) {
        cache(cards, key: infoCardsCacheKey, userDefaults: userDefaults)
    }

    static func cachedInfoCards(userDefaults: UserDefaults = .standard) -> [InfoCard]? {
        cached(key: infoCardsCacheKey, userDefaults: userDefaults)
    }

    private static func cache<T: Encodable>(_ value: [T], key: String, userDefaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        userDefaults.set(data, forKey: key)
    }

    private static func cached<T: Decodable>(key: String, userDefaults: UserDefaults) -> [T]? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)
    }

    // Bundled seed entries first, then remote/cached entries the admin has
    // added, de-duplicated by id (a remote row can override a seed row that
    // shares its id, e.g. if the admin corrects one of the bundled entries).
    static func merge<T: Identifiable>(seed: [T], remote: [T]) -> [T] where T.ID: Hashable {
        var byID: [T.ID: T] = [:]
        var order: [T.ID] = []
        for item in seed + remote {
            if byID[item.id] == nil { order.append(item.id) }
            byID[item.id] = item
        }
        return order.compactMap { byID[$0] }
    }
}
