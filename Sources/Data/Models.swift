import Foundation
import SwiftData

@Model
final class PrayerRecord {
    var date: Date
    var prayerKey: String
    // True when this prayer was recorded as a makeup (kaza) rather than
    // performed on time — shown as a distinct cell state in Takip and
    // excluded from the on-time streak.
    var isKaza: Bool = false

    init(date: Date, prayerKey: String, isKaza: Bool = false) {
        self.date = date
        self.prayerKey = prayerKey
        self.isKaza = isKaza
    }
}

@Model
final class FastingRecord {
    var date: Date

    init(date: Date) {
        self.date = date
    }
}

@Model
final class DhikrCount {
    var date: Date
    var phrase: String
    var count: Int

    init(date: Date, phrase: String, count: Int = 0) {
        self.date = date
        self.phrase = phrase
        self.count = count
    }
}

@Model
final class CommunityEvent {
    var title: String
    var location: String
    var date: Date
    var category: String
    var createdAt: Date

    init(title: String, location: String, date: Date, category: String, createdAt: Date = .now) {
        self.title = title
        self.location = location
        self.date = date
        self.category = category
        self.createdAt = createdAt
    }
}

@Model
final class Donation {
    var title: String
    var amountTRY: Double
    var category: String // "Zekât" | "Sadaka" | "Fitre"
    var date: Date

    init(title: String, amountTRY: Double, category: String, date: Date = .now) {
        self.title = title
        self.amountTRY = amountTRY
        self.category = category
        self.date = date
    }
}

@Model
final class InfoCardReadRecord {
    var date: Date
    var cardId: String

    init(date: Date, cardId: String) {
        self.date = date
        self.cardId = cardId
    }
}

@Model
final class CustomDua {
    var title: String
    var text: String
    var category: String
    var createdAt: Date

    init(title: String, text: String, category: String, createdAt: Date = .now) {
        self.title = title
        self.text = text
        self.category = category
        self.createdAt = createdAt
    }
}
