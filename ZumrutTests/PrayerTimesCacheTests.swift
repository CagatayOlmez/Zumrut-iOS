import CoreLocation
import XCTest
@testable import Zumrut

final class PrayerTimesCacheTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    private let istanbul = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
    private let sampleTimings = PrayerTimings(Fajr: "05:00", Dhuhr: "13:00", Asr: "16:30", Maghrib: "19:45", Isha: "21:15")

    override func setUp() {
        super.setUp()
        suiteName = "PrayerTimesCacheTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testNoCacheReturnsNil() {
        XCTAssertNil(PrayerTimesService.cachedTimings(for: .now, coordinate: istanbul, userDefaults: defaults))
    }

    func testCacheRoundTripsForSameDayAndLocation() {
        let now = Date()
        PrayerTimesService.cacheTimings(sampleTimings, for: now, coordinate: istanbul, userDefaults: defaults)
        let cached = PrayerTimesService.cachedTimings(for: now, coordinate: istanbul, userDefaults: defaults)
        XCTAssertEqual(cached?.Fajr, sampleTimings.Fajr)
        XCTAssertEqual(cached?.Isha, sampleTimings.Isha)
    }

    func testCacheMissesForADifferentDay() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        PrayerTimesService.cacheTimings(sampleTimings, for: today, coordinate: istanbul, userDefaults: defaults)
        XCTAssertNil(PrayerTimesService.cachedTimings(for: tomorrow, coordinate: istanbul, userDefaults: defaults))
    }

    func testCacheMissesForADistantLocation() {
        let now = Date()
        let farAway = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060) // New York
        PrayerTimesService.cacheTimings(sampleTimings, for: now, coordinate: istanbul, userDefaults: defaults)
        XCTAssertNil(PrayerTimesService.cachedTimings(for: now, coordinate: farAway, userDefaults: defaults))
    }

    func testCacheToleratesSmallLocationDrift() {
        let now = Date()
        let nearby = CLLocationCoordinate2D(latitude: istanbul.latitude + 0.01, longitude: istanbul.longitude - 0.01)
        PrayerTimesService.cacheTimings(sampleTimings, for: now, coordinate: istanbul, userDefaults: defaults)
        XCTAssertNotNil(PrayerTimesService.cachedTimings(for: now, coordinate: nearby, userDefaults: defaults))
    }

    func testDayKeyMatchesForSameCalendarDayDifferentTimes() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = 1
        let morning = Calendar.current.date(from: components)!
        components.hour = 23
        let night = Calendar.current.date(from: components)!
        XCTAssertEqual(PrayerTimesService.dayKey(for: morning), PrayerTimesService.dayKey(for: night))
    }
}
