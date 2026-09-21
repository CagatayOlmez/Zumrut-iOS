import SwiftUI

// System serif/monospaced designs stand in for the brand faces (Lora/Inter/Amiri)
// until those are bundled as embedded fonts — a follow-up task, not required to ship this slice.
enum ZumrutFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}
