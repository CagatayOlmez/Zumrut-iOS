import Foundation

struct InfoCard: Identifiable, Codable, Hashable {
    let id: String
    let category: String // "HADİS" | "AYET"
    let text: String
    let source: String
}

enum InfoCardLibrary {
    // Kept small and deliberately conservative: only short, extremely
    // well-known texts included with their standard citation. This is the
    // bundled fallback shown before the network responds or when offline —
    // ContentStore adds whatever the admin has since added via Supabase
    // Studio (see backend/README.md) on top of this. Expanding this further
    // should draw from a verified reference, not recalled from memory.
    //
    // The four entries below were added by Claude on 2026-08-25 at the
    // user's request; the AYET entries are Qur'an-sourced (verifiable
    // against the Qur'an text/numbering) and the HADİS entries are two of
    // the most widely and consistently cited hadith in Turkish Islamic
    // literature, but all four still deserve a human review pass before
    // being treated as final, per the same caution as the rest of this file.
    static let seed: [InfoCard] = [
        InfoCard(
            id: "iman-ahlak",
            category: "HADİS",
            text: "Mü'minlerin iman bakımından en olgunu, ahlâkı en güzel olanıdır.",
            source: "Tirmizî, Radâ, 11"
        ),
        InfoCard(
            id: "komsu",
            category: "HADİS",
            text: "Komşusu açken tok yatan bizden değildir.",
            source: "Buhârî, el-Edebü'l-Müfred, 112"
        ),
        InfoCard(
            id: "kolaylik",
            category: "AYET",
            text: "Şüphesiz güçlükle beraber bir kolaylık vardır.",
            source: "İnşirâh Suresi, 6"
        ),
        InfoCard(
            id: "guzel-soz",
            category: "HADİS",
            text: "Güzel söz sadakadır.",
            source: "Buhârî, Sulh, 11"
        ),
        InfoCard(
            id: "sabir",
            category: "AYET",
            text: "Sabredenlere mükafatları hesapsız verilir.",
            source: "Zümer Suresi, 10"
        ),
        InfoCard(
            id: "sabir-beraberlik",
            category: "AYET",
            text: "Şüphesiz Allah, sabredenlerle beraberdir.",
            source: "Bakara Suresi, 153"
        ),
        InfoCard(
            id: "guc-yetirebilecegi",
            category: "AYET",
            text: "Allah hiçbir kimseye gücünün yeteceğinden fazla yük yüklemez.",
            source: "Bakara Suresi, 286"
        ),
        InfoCard(
            id: "niyet",
            category: "HADİS",
            text: "Ameller niyetlere göredir.",
            source: "Buhârî, Bed'ü'l-vahy, 1"
        ),
        InfoCard(
            id: "muslüman-guven",
            category: "HADİS",
            text: "Müslüman, elinden ve dilinden diğer Müslümanların güvende olduğu kimsedir.",
            source: "Buhârî, İman, 4-5"
        ),
    ]

    // Deterministic "today's card" — the same card shows all day, and the
    // sequence repeats predictably rather than being random each launch.
    static func card(for date: Date, in cards: [InfoCard]) -> InfoCard {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        let index = dayOfYear % cards.count
        return cards[index]
    }
}
