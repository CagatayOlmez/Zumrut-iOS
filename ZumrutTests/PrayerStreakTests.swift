import XCTest
@testable import Zumrut

final class PrayerStreakTests: XCTestCase {
    private let calendar = Calendar.current
    private let allKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]

    private func completedDay(_ date: Date, isKaza: Bool = false) -> [PrayerRecord] {
        allKeys.map { PrayerRecord(date: date, prayerKey: $0, isKaza: isKaza) }
    }

    func testStreakIsZeroWithNoRecords() {
        XCTAssertEqual(PrayerStreak.currentStreak(records: [], today: .now, calendar: calendar), 0)
    }

    func testStreakCountsConsecutiveCompleteDays() {
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let records = completedDay(today) + completedDay(yesterday) + completedDay(twoDaysAgo)
        XCTAssertEqual(PrayerStreak.currentStreak(records: records, today: today, calendar: calendar), 3)
    }

    func testUnfinishedTodayDoesNotBreakAnExistingStreak() {
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        // Only 2 of 5 prayers marked today — shouldn't zero out yesterday's completed streak.
        let records = Array(completedDay(today).prefix(2)) + completedDay(yesterday)
        XCTAssertEqual(PrayerStreak.currentStreak(records: records, today: today, calendar: calendar), 1)
    }

    func testGapInPastDaysBreaksStreak() {
        let today = calendar.startOfDay(for: .now)
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        // Yesterday and the day before are missing entirely -> streak stops at today.
        let records = completedDay(today) + completedDay(threeDaysAgo)
        XCTAssertEqual(PrayerStreak.currentStreak(records: records, today: today, calendar: calendar), 1)
    }

    func testKazaRecordsDoNotCountTowardTheStreak() {
        let today = calendar.startOfDay(for: .now)
        // All 5 prayers present today, but marked as kaza (makeup) rather than on-time.
        let records = completedDay(today, isKaza: true)
        XCTAssertEqual(PrayerStreak.currentStreak(records: records, today: today, calendar: calendar), 0)
    }
}
