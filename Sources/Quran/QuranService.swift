import Foundation

// Qur'an text via alquran.cloud (https://alquran.cloud/api). Arabic uses the
// Uthmani-script edition; the Turkish meal uses the Diyanet İşleri edition,
// matching the app's Diyanet-sourced positioning.

private struct SurahListResponse: Decodable {
    let data: [SurahSummary]
}

private struct SurahDetailResponse: Decodable {
    struct DataWrapper: Decodable {
        let number: Int
        let name: String
        let englishName: String
        let englishNameTranslation: String
        let numberOfAyahs: Int
        let revelationType: String
        let ayahs: [Ayah]
    }
    let data: DataWrapper
}

enum QuranService {
    private static let surahListCacheKey = "cachedSurahList"
    private static func surahDetailCacheKey(_ number: Int) -> String { "cachedSurah-\(number)" }

    static func fetchSurahList() async throws -> [SurahSummary] {
        let url = URL(string: "https://api.alquran.cloud/v1/surah")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let surahs = try JSONDecoder().decode(SurahListResponse.self, from: data).data
        cacheSurahList(surahs)
        return surahs
    }

    static func fetchSurah(number: Int) async throws -> SurahDetail {
        async let arabic = fetchEdition(number: number, edition: "quran-uthmani")
        async let turkish = fetchEdition(number: number, edition: "tr.diyanet")
        let (arabicResult, turkishResult) = try await (arabic, turkish)
        let summary = SurahSummary(
            number: arabicResult.number,
            name: arabicResult.name,
            englishName: arabicResult.englishName,
            englishNameTranslation: arabicResult.englishNameTranslation,
            numberOfAyahs: arabicResult.numberOfAyahs,
            revelationType: arabicResult.revelationType
        )
        let detail = SurahDetail(summary: summary, arabicAyahs: arabicResult.ayahs, turkishAyahs: turkishResult.ayahs)
        cacheSurah(detail, number: number)
        return detail
    }

    private static func fetchEdition(number: Int, edition: String) async throws -> SurahDetailResponse.DataWrapper {
        let url = URL(string: "https://api.alquran.cloud/v1/surah/\(number)/\(edition)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SurahDetailResponse.self, from: data).data
    }

    // Network fails often enough offline (airplane mode, weak signal at a
    // mosque) that the last successfully fetched surah list/detail should
    // still be readable, mirroring ContentService/PrayerTimesService's
    // fetch/cache split.
    static func cacheSurahList(_ surahs: [SurahSummary], userDefaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(surahs) else { return }
        userDefaults.set(data, forKey: surahListCacheKey)
    }

    static func cachedSurahList(userDefaults: UserDefaults = .standard) -> [SurahSummary]? {
        guard let data = userDefaults.data(forKey: surahListCacheKey) else { return nil }
        return try? JSONDecoder().decode([SurahSummary].self, from: data)
    }

    static func cacheSurah(_ detail: SurahDetail, number: Int, userDefaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(detail) else { return }
        userDefaults.set(data, forKey: surahDetailCacheKey(number))
    }

    static func cachedSurah(number: Int, userDefaults: UserDefaults = .standard) -> SurahDetail? {
        guard let data = userDefaults.data(forKey: surahDetailCacheKey(number)) else { return nil }
        return try? JSONDecoder().decode(SurahDetail.self, from: data)
    }
}
