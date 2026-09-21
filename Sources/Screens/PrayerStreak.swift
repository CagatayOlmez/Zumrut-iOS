import Foundation

enum PrayerStreak {
    // Consecutive days (ending today) with all 5 daily prayers recorded.
    // Today doesn't break the streak if it's simply not finished yet —
    // it just isn't counted until all 5 are marked.
    static func currentStreak(records: [PrayerRecord], today: Date, calendar: Calendar = .current) -> Int {
        // Kaza (makeup) prayers don't count toward an on-time streak.
        let onTime = records.filter { !$0.isKaza }
        let grouped = Dictionary(grouping: onTime) { calendar.startOfDay(for: $0.date) }
        var streak = 0
        var day = calendar.startOfDay(for: today)
        var isFirstDay = true

        while true {
            let completedCount = grouped[day]?.count ?? 0
            if completedCount >= DAILY_PRAYER_COUNT {
                streak += 1
            } else if !isFirstDay {
                break
            }
            isFirstDay = false
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
            if streak > 3650 { break } // sanity cap
        }
        return streak
    }

    private static let DAILY_PRAYER_COUNT = 5
}
