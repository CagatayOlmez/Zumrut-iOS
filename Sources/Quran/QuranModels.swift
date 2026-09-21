import Foundation

struct SurahSummary: Codable, Identifiable, Equatable {
    let number: Int
    let name: String // Arabic
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String // "Meccan" | "Medinan"

    var id: Int { number }

    // The API doesn't provide Turkish surah names, and hand-transcribing all 114
    // from memory risks getting a sacred name wrong — the Arabic name (authoritative,
    // straight from the source) plus the Latin transliteration stand in until a
    // verified Turkish list (e.g. from Diyanet's own fihrist) is sourced.
    var revelationTypeTurkish: String {
        revelationType == "Meccan" ? "Mekki" : "Medeni"
    }
}

struct Ayah: Codable, Identifiable, Equatable {
    let number: Int
    let text: String
    let numberInSurah: Int

    var id: Int { number }
}

struct SurahDetail: Codable, Equatable {
    let summary: SurahSummary
    let arabicAyahs: [Ayah]
    let turkishAyahs: [Ayah]
}
