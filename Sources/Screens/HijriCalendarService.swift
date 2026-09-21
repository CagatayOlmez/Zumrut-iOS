import Foundation

enum HijriCalendarService {
    // Umm al-Qura is the calculated calendar most commonly used for everyday
    // Hijri dates (also the basis for Mecca/Hajj scheduling).
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .islamicUmmAlQura)
        cal.locale = Locale(identifier: "tr_TR")
        return cal
    }()

    static func hijriDateString(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM y"
        return formatter.string(from: date)
    }

    struct ImportantDay {
        let hijriMonth: Int
        let hijriDay: Int
        let name: String
    }

    // Fixed Hijri calendar positions. The real, observed date can shift by a
    // day depending on regional moon sighting — these are Umm al-Qura estimates.
    static let importantDays: [ImportantDay] = [
        ImportantDay(hijriMonth: 1, hijriDay: 1, name: "Hicri Yılbaşı"),
        ImportantDay(hijriMonth: 1, hijriDay: 10, name: "Aşure Günü"),
        ImportantDay(hijriMonth: 3, hijriDay: 12, name: "Mevlid Kandili"),
        ImportantDay(hijriMonth: 7, hijriDay: 27, name: "Miraç Kandili"),
        ImportantDay(hijriMonth: 8, hijriDay: 15, name: "Berat Kandili"),
        ImportantDay(hijriMonth: 9, hijriDay: 1, name: "Ramazan Başlangıcı"),
        ImportantDay(hijriMonth: 9, hijriDay: 27, name: "Kadir Gecesi"),
        ImportantDay(hijriMonth: 10, hijriDay: 1, name: "Ramazan Bayramı"),
        ImportantDay(hijriMonth: 12, hijriDay: 9, name: "Arefe Günü"),
        ImportantDay(hijriMonth: 12, hijriDay: 10, name: "Kurban Bayramı"),
    ]

    struct UpcomingDay {
        let name: String
        let gregorianDate: Date
        let daysUntil: Int
    }

    static func nextImportantDay(from now: Date = Date()) -> UpcomingDay? {
        guard let currentHijriYear = calendar.dateComponents([.year], from: now).year else { return nil }

        var candidates: [UpcomingDay] = []
        for yearOffset in 0...1 {
            for day in importantDays {
                var comps = DateComponents()
                comps.year = currentHijriYear + yearOffset
                comps.month = day.hijriMonth
                comps.day = day.hijriDay
                guard let candidateDate = calendar.date(from: comps), candidateDate > now else { continue }
                let daysUntil = calendar.dateComponents([.day], from: now, to: candidateDate).day ?? 0
                candidates.append(UpcomingDay(name: day.name, gregorianDate: candidateDate, daysUntil: daysUntil))
            }
        }
        return candidates.min(by: { $0.gregorianDate < $1.gregorianDate })
    }
}
