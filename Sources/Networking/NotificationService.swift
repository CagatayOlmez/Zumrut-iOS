import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // Schedules ezan notifications for every remaining prayer today and every
    // prayer tomorrow — a rolling ~48h window, since local notifications can't
    // be refreshed silently once the times shift the day after tomorrow.
    static func scheduleForNext48Hours(todayTimings: PrayerTimings, tomorrowTimings: PrayerTimings) {
        let center = UNUserNotificationCenter.current()
        let allIdentifiers = PrayerKey.allCases.flatMap { key in
            ["ezan-\(key.rawValue)-today", "ezan-\(key.rawValue)-tomorrow"]
        }
        center.removePendingNotificationRequests(withIdentifiers: allIdentifiers)

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        schedule(timings: todayTimings, referenceDate: Date(), suffix: "today")
        schedule(timings: tomorrowTimings, referenceDate: tomorrow, suffix: "tomorrow")
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func scheduleWeeklyReminder(weekday: Int, hour: Int, identifier: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        var components = DateComponents()
        components.weekday = weekday // 1 = Sunday ... 6 = Friday ... 7 = Saturday
        components.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: identifier, content: content, trigger: trigger),
            withCompletionHandler: nil
        )
    }

    static func scheduleMonthlyReminder(day: Int, hour: Int, identifier: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        var components = DateComponents()
        components.day = day
        components.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: identifier, content: content, trigger: trigger),
            withCompletionHandler: nil
        )
    }

    static func cancelReminder(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private static func schedule(timings: PrayerTimings, referenceDate: Date, suffix: String) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        for key in PrayerKey.allCases {
            guard let time = parseHHMM(key.time(from: timings), on: referenceDate), time > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Zümrüt"
            content.body = "\(key.displayName) vakti girdi."
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "ezan-\(key.rawValue)-\(suffix)", content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
    }
}
