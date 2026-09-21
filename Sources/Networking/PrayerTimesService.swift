import CoreLocation
import Foundation

// Prayer times via the Aladhan API (https://aladhan.com/prayer-times-api).
// method=13 uses the Diyanet İşleri Başkanlığı (Turkey) calculation method.

struct PrayerTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

private struct AladhanResponse: Decodable {
    struct DataWrapper: Decodable {
        let timings: PrayerTimings
    }
    let data: DataWrapper
}

// Cached alongside the timings so a fetch for a different day or a
// meaningfully different location doesn't serve stale data.
struct CachedPrayerTimings: Codable {
    let timings: PrayerTimings
    let dayKey: String
    let latitude: Double
    let longitude: Double
}

enum PrayerTimesService {
    private static let cacheKey = "cachedPrayerTimings"
    // ~11km — coarse enough to tolerate GPS drift, tight enough that a
    // genuinely different city won't serve another city's cached timings.
    private static let cacheLocationToleranceDegrees = 0.1

    static func fetchTimings(latitude: Double, longitude: Double, date: Date = Date()) async throws -> PrayerTimings {
        let timestamp = Int(date.timeIntervalSince1970)
        let urlString = "https://api.aladhan.com/v1/timings/\(timestamp)?latitude=\(latitude)&longitude=\(longitude)&method=13"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AladhanResponse.self, from: data).data.timings
    }

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    static func cacheTimings(_ timings: PrayerTimings, for date: Date, coordinate: CLLocationCoordinate2D, userDefaults: UserDefaults = .standard) {
        let entry = CachedPrayerTimings(
            timings: timings,
            dayKey: dayKey(for: date),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        guard let data = try? JSONEncoder().encode(entry) else { return }
        userDefaults.set(data, forKey: cacheKey)
    }

    // Returns the cached timings only if they were cached for the same
    // calendar day and a nearby location — otherwise nil, since showing an
    // unrelated day/location's prayer times would be worse than an error.
    static func cachedTimings(for date: Date, coordinate: CLLocationCoordinate2D, userDefaults: UserDefaults = .standard) -> PrayerTimings? {
        guard let data = userDefaults.data(forKey: cacheKey),
              let entry = try? JSONDecoder().decode(CachedPrayerTimings.self, from: data),
              entry.dayKey == dayKey(for: date),
              abs(entry.latitude - coordinate.latitude) <= cacheLocationToleranceDegrees,
              abs(entry.longitude - coordinate.longitude) <= cacheLocationToleranceDegrees
        else { return nil }
        return entry.timings
    }
}

// The five daily prayers shown on the Ana Sayfa list, in order — excludes
// Sunrise/Sunset, which the API returns but which aren't prayer times.
enum PrayerKey: String, CaseIterable {
    case Fajr, Dhuhr, Asr, Maghrib, Isha

    var displayName: String {
        switch self {
        case .Fajr: return "Sabah"
        case .Dhuhr: return "Öğle"
        case .Asr: return "İkindi"
        case .Maghrib: return "Akşam"
        case .Isha: return "Yatsı"
        }
    }

    func time(from timings: PrayerTimings) -> String {
        switch self {
        case .Fajr: return timings.Fajr
        case .Dhuhr: return timings.Dhuhr
        case .Asr: return timings.Asr
        case .Maghrib: return timings.Maghrib
        case .Isha: return timings.Isha
        }
    }
}
