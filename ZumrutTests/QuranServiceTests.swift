import XCTest
@testable import Zumrut

final class QuranServiceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "QuranServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testSurahListCacheRoundTrips() {
        let surahs = [
            SurahSummary(number: 1, name: "الفاتحة", englishName: "Al-Fatiha", englishNameTranslation: "The Opening", numberOfAyahs: 7, revelationType: "Meccan"),
        ]
        XCTAssertNil(QuranService.cachedSurahList(userDefaults: defaults))
        QuranService.cacheSurahList(surahs, userDefaults: defaults)
        XCTAssertEqual(QuranService.cachedSurahList(userDefaults: defaults), surahs)
    }

    func testSurahDetailCacheRoundTrips() {
        let summary = SurahSummary(number: 1, name: "الفاتحة", englishName: "Al-Fatiha", englishNameTranslation: "The Opening", numberOfAyahs: 7, revelationType: "Meccan")
        let detail = SurahDetail(
            summary: summary,
            arabicAyahs: [Ayah(number: 1, text: "بسم الله", numberInSurah: 1)],
            turkishAyahs: [Ayah(number: 1, text: "Rahman ve Rahim olan Allah'ın adıyla", numberInSurah: 1)]
        )
        XCTAssertNil(QuranService.cachedSurah(number: 1, userDefaults: defaults))
        QuranService.cacheSurah(detail, number: 1, userDefaults: defaults)
        XCTAssertEqual(QuranService.cachedSurah(number: 1, userDefaults: defaults), detail)
    }

    func testDifferentSurahNumbersAreCachedIndependently() {
        let detail1 = SurahDetail(
            summary: SurahSummary(number: 1, name: "١", englishName: "One", englishNameTranslation: "One", numberOfAyahs: 7, revelationType: "Meccan"),
            arabicAyahs: [], turkishAyahs: []
        )
        let detail2 = SurahDetail(
            summary: SurahSummary(number: 2, name: "٢", englishName: "Two", englishNameTranslation: "Two", numberOfAyahs: 286, revelationType: "Medinan"),
            arabicAyahs: [], turkishAyahs: []
        )
        QuranService.cacheSurah(detail1, number: 1, userDefaults: defaults)
        QuranService.cacheSurah(detail2, number: 2, userDefaults: defaults)
        XCTAssertEqual(QuranService.cachedSurah(number: 1, userDefaults: defaults), detail1)
        XCTAssertEqual(QuranService.cachedSurah(number: 2, userDefaults: defaults), detail2)
    }
}
