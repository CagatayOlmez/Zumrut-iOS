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
    static func fetchSurahList() async throws -> [SurahSummary] {
        let url = URL(string: "https://api.alquran.cloud/v1/surah")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SurahListResponse.self, from: data).data
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
        return SurahDetail(summary: summary, arabicAyahs: arabicResult.ayahs, turkishAyahs: turkishResult.ayahs)
    }

    private static func fetchEdition(number: Int, edition: String) async throws -> SurahDetailResponse.DataWrapper {
        let url = URL(string: "https://api.alquran.cloud/v1/surah/\(number)/\(edition)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SurahDetailResponse.self, from: data).data
    }
}
