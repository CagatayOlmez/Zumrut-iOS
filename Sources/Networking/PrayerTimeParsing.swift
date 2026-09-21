import Foundation

func parseHHMM(_ hhmm: String, on referenceDate: Date, calendar: Calendar = .current) -> Date? {
    let parts = hhmm.split(separator: ":").compactMap { Int($0) }
    guard parts.count == 2 else { return nil }
    var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
    components.hour = parts[0]
    components.minute = parts[1]
    return calendar.date(from: components)
}
