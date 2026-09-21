import Foundation

// Deliberately scoped as a word-match check, not pronunciation/tajwid analysis —
// no available API actually detects mahreç (articulation-point) errors. Claiming
// that would be dishonest; this catches skipped/misread words, which is real and useful.
enum WordMatcher {
    private static let diacritics = CharacterSet(charactersIn:
        "\u{0610}\u{0611}\u{0612}\u{0613}\u{0614}\u{0615}\u{0616}\u{0617}\u{0618}\u{0619}\u{061A}"
        + "\u{064B}\u{064C}\u{064D}\u{064E}\u{064F}\u{0650}\u{0651}\u{0652}\u{0653}\u{0654}\u{0655}"
        + "\u{0656}\u{0657}\u{0658}\u{0659}\u{065A}\u{065B}\u{065C}\u{065D}\u{065E}\u{065F}\u{0670}"
        + "\u{06D6}\u{06D7}\u{06D8}\u{06D9}\u{06DA}\u{06DB}\u{06DC}\u{06DF}\u{06E0}\u{06E1}\u{06E2}"
        + "\u{06E3}\u{06E4}\u{06E7}\u{06E8}\u{06EA}\u{06EB}\u{06EC}\u{06ED}\u{0640}"
    )

    // Strips Arabic diacritics (tashkeel) and tatweel — ASR output is typically
    // undiacritized while Qur'an text is fully vocalized, so a direct string
    // comparison without this would fail on nearly every word.
    static func normalize(_ text: String) -> String {
        let scalars = text.unicodeScalars.filter { !diacritics.contains($0) }
        return String(String.UnicodeScalarView(scalars))
    }

    // Set-based (order-independent) matching per expected word — approximate,
    // not a strict positional diff.
    static func matchFlags(expected: String, transcribed: String) -> [Bool] {
        let expectedWords = normalize(expected).split(separator: " ").map(String.init)
        let transcribedWords = Set(normalize(transcribed).split(separator: " ").map(String.init))
        return expectedWords.map { transcribedWords.contains($0) }
    }

    static func accuracy(_ flags: [Bool]) -> Double {
        guard !flags.isEmpty else { return 0 }
        return Double(flags.filter { $0 }.count) / Double(flags.count)
    }
}
