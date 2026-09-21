import Foundation

struct StaticDua: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let arabic: String
    let source: String
    let category: String
}

enum DuaLibrary {
    // Kept intentionally small: only duas whose Arabic text is short and
    // well-established enough to be confident about verbatim, sourced from
    // widely-cited hadith. This is the bundled fallback shown even before
    // the network responds or when offline — ContentStore adds whatever the
    // admin has since added via Supabase Studio (see backend/README.md) on
    // top of this. Expanding this further should draw from a verified
    // reference (e.g. Diyanet's dua book), not recalled from memory.
    //
    // The two "Genel" entries and their citations below were added by
    // Claude on 2026-08-25 at the user's request; both are Qur'an-sourced
    // (verifiable against the Qur'an text/numbering, not recalled hadith
    // detail) but still deserve a human review pass before being treated
    // as final, per the same caution as the rest of this file.
    static let seed: [StaticDua] = [
        StaticDua(
            id: "sabah-duasi",
            title: "Sabah Duası",
            arabic: "اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
            source: "Tirmizî, Da'avât, 79",
            category: "Sabah-Akşam"
        ),
        StaticDua(
            id: "aksam-duasi",
            title: "Akşam Duası",
            arabic: "اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ",
            source: "Tirmizî, Da'avât, 79",
            category: "Sabah-Akşam"
        ),
        StaticDua(
            id: "yolculuk-duasi",
            title: "Yolculuk Duası",
            arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ",
            source: "Müslim, Hac, 425",
            category: "Yolculuk"
        ),
        StaticDua(
            id: "yemekten-once-duasi",
            title: "Yemekten Önce",
            arabic: "بِسْمِ اللَّهِ",
            source: "Ebû Davûd, Et'ime, 15",
            category: "Yemek"
        ),
        StaticDua(
            id: "rabbena-duasi",
            title: "Rabbena Duası",
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            source: "Bakara Suresi, 201",
            category: "Genel"
        ),
        StaticDua(
            id: "sikinti-duasi",
            title: "Sıkıntı Anında Duası",
            arabic: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
            source: "Âl-i İmrân Suresi, 173",
            category: "Genel"
        ),
    ]

    static var categories: [String] {
        var seen: [String] = []
        for dua in seed where !seen.contains(dua.category) {
            seen.append(dua.category)
        }
        return seen
    }
}
