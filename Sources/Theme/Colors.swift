import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    // A color that swaps hex values (and optionally alpha) with the system's
    // light/dark trait, mirroring the light/dark tokens in the web mockups.
    init(light: UInt32, dark: UInt32, lightAlpha: CGFloat = 1, darkAlpha: CGFloat = 1) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkAlpha)
                : UIColor(hex: light, alpha: lightAlpha)
        })
    }
}

// Çini Yeşili palette, ported from the web mockups (light + dark tokens).
enum ZumrutColors {
    static let ground = Color(light: 0xEEF1EE, dark: 0x101514)
    static let paper = Color(light: 0xFFFFFF, dark: 0x182120)
    static let ink = Color(light: 0x172220, dark: 0xE7ECE8)
    static let muted = Color(light: 0x55605B, dark: 0x94A19C)
    static let line = Color(light: 0xD8DCD6, dark: 0x2B3532)
    static let teal = Color(light: 0x0B6E63, dark: 0x3FBBA8)
    static let tealDeep = Color(light: 0x0A5C53, dark: 0x2C9384)
    static let tealTint = Color(light: 0x0B6E63, dark: 0x3FBBA8, lightAlpha: 0.09, darkAlpha: 0.14)
    static let gold = Color(light: 0xA9822F, dark: 0xD8B368)
    static let goldTint = Color(light: 0xA9822F, dark: 0xD8B368, lightAlpha: 0.12, darkAlpha: 0.14)
}
