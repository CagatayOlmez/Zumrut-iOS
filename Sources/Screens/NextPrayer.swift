import Foundation

struct NextPrayer {
    let key: PrayerKey
    let minutesUntil: Int

    var countdownText: String {
        let h = minutesUntil / 60
        let m = minutesUntil % 60
        return h > 0 ? "\(h) sa \(m) dk" : "\(m) dk"
    }
}

// Returns the next upcoming prayer from `timings`, or tomorrow's Fajr if
// every prayer for today has already passed.
func nextPrayer(timings: PrayerTimings, now: Date) -> NextPrayer {
    let calendar = Calendar.current
    for key in PrayerKey.allCases {
        if let time = parseHHMM(key.time(from: timings), on: now), time > now {
            let minutes = calendar.dateComponents([.minute], from: now, to: time).minute ?? 0
            return NextPrayer(key: key, minutesUntil: minutes)
        }
    }
    let fajr = PrayerKey.Fajr
    if let fajrTime = parseHHMM(fajr.time(from: timings), on: now),
       let tomorrowFajr = calendar.date(byAdding: .day, value: 1, to: fajrTime) {
        let minutes = calendar.dateComponents([.minute], from: now, to: tomorrowFajr).minute ?? 0
        return NextPrayer(key: fajr, minutesUntil: minutes)
    }
    return NextPrayer(key: fajr, minutesUntil: 0)
}
