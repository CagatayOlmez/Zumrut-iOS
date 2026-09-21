import XCTest
@testable import Zumrut

final class ContentServiceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "ContentServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testDuaCacheRoundTrips() {
        let duas = [StaticDua(id: "a", title: "A", arabic: "ا", source: "S", category: "C")]
        XCTAssertNil(ContentService.cachedDuas(userDefaults: defaults))
        ContentService.cacheDuas(duas, userDefaults: defaults)
        XCTAssertEqual(ContentService.cachedDuas(userDefaults: defaults), duas)
    }

    func testInfoCardCacheRoundTrips() {
        let cards = [InfoCard(id: "a", category: "AYET", text: "T", source: "S")]
        XCTAssertNil(ContentService.cachedInfoCards(userDefaults: defaults))
        ContentService.cacheInfoCards(cards, userDefaults: defaults)
        XCTAssertEqual(ContentService.cachedInfoCards(userDefaults: defaults), cards)
    }

    func testMergeKeepsSeedOrderThenAddsNewRemoteEntries() {
        let seed = [
            StaticDua(id: "seed-1", title: "Seed 1", arabic: "ا", source: "S", category: "C"),
            StaticDua(id: "seed-2", title: "Seed 2", arabic: "ا", source: "S", category: "C"),
        ]
        let remote = [
            StaticDua(id: "admin-1", title: "Admin 1", arabic: "ا", source: "S", category: "C"),
        ]
        let merged = ContentService.merge(seed: seed, remote: remote)
        XCTAssertEqual(merged.map(\.id), ["seed-1", "seed-2", "admin-1"])
    }

    func testMergeLetsRemoteOverrideASeedEntryWithTheSameID() {
        let seed = [StaticDua(id: "seed-1", title: "Old Title", arabic: "ا", source: "S", category: "C")]
        let remote = [StaticDua(id: "seed-1", title: "Corrected Title", arabic: "ا", source: "S", category: "C")]
        let merged = ContentService.merge(seed: seed, remote: remote)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.title, "Corrected Title")
    }

    func testMergeWithEmptyRemoteReturnsSeedUnchanged() {
        let seed = [StaticDua(id: "seed-1", title: "Seed 1", arabic: "ا", source: "S", category: "C")]
        XCTAssertEqual(ContentService.merge(seed: seed, remote: []), seed)
    }
}
