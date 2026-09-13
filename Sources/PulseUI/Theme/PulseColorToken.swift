import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Adaptive Color

extension Color {
    /// An adaptive color that switches between light and dark values based on the system appearance.
    public init(light: UInt, dark: UInt) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
        #elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return NSColor(Color(hex: isDark ? dark : light))
        })
        #else
        self = Color(hex: light)
        #endif
    }

    /// A color from a hex integer (0xRRGGBB).
    public init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

// MARK: - Color Tokens

/// Semantic color tokens. Never use raw hex — always reference these.
/// Change one token, entire UI re-skins instantly.
public struct ColorTokens: Sendable {
    // MARK: Background
    public let background: Color
    public let backgroundSecondary: Color
    public let backgroundTertiary: Color
    public let surface: Color
    public let surfaceElevated: Color
    public let card: Color

    // MARK: Foreground
    public let foreground: Color
    public let foregroundSecondary: Color
    public let foregroundTertiary: Color
    public let foregroundInverse: Color

    // MARK: Primary
    public let primary: Color
    public let primaryForeground: Color
    public let primaryMuted: Color

    // MARK: Secondary
    public let secondary: Color
    public let secondaryForeground: Color
    public let secondaryMuted: Color

    // MARK: Accent
    public let accent: Color
    public let accentForeground: Color

    // MARK: Semantic
    public let success: Color
    public let successForeground: Color
    public let warning: Color
    public let warningForeground: Color
    public let error: Color
    public let errorForeground: Color
    public let info: Color
    public let infoForeground: Color

    // MARK: Border & Ring
    public let border: Color
    public let borderStrong: Color
    public let ring: Color
    public let separator: Color

    // MARK: Overlay
    public let overlay: Color
    public let scrim: Color

    // MARK: Glass
    public let glassFill: Color
    public let glassStroke: Color
    public let glassHighlight: Color

    // MARK: Gradient Presets
    public let gradientPrimary: [Color]
    public let gradientSecondary: [Color]
    public let gradientAccent: [Color]

    public init(
        background: Color = .init(light: 0xFAFAFA, dark: 0x09090B),
        backgroundSecondary: Color = .init(light: 0xF4F4F5, dark: 0x18181B),
        backgroundTertiary: Color = .init(light: 0xE4E4E7, dark: 0x27272A),
        surface: Color = .init(light: 0xFFFFFF, dark: 0x09090B),
        surfaceElevated: Color = .init(light: 0xFFFFFF, dark: 0x18181B),
        card: Color = .init(light: 0xFFFFFF, dark: 0x18181B),
        foreground: Color = .init(light: 0x09090B, dark: 0xFAFAFA),
        foregroundSecondary: Color = .init(light: 0x71717A, dark: 0xA1A1AA),
        foregroundTertiary: Color = .init(light: 0xA1A1AA, dark: 0x71717A),
        foregroundInverse: Color = .init(light: 0xFFFFFF, dark: 0x09090B),
        primary: Color = .init(light: 0x18181B, dark: 0xFAFAFA),
        primaryForeground: Color = .init(light: 0xFFFFFF, dark: 0x09090B),
        primaryMuted: Color = .init(light: 0xF4F4F5, dark: 0x27272A),
        secondary: Color = .init(light: 0xF4F4F5, dark: 0x27272A),
        secondaryForeground: Color = .init(light: 0x18181B, dark: 0xFAFAFA),
        secondaryMuted: Color = .init(light: 0xE4E4E7, dark: 0x3F3F46),
        accent: Color = .init(light: 0x2563EB, dark: 0x60A5FA),
        accentForeground: Color = .init(light: 0xFFFFFF, dark: 0xFFFFFF),
        success: Color = .init(light: 0x16A34A, dark: 0x4ADE80),
        successForeground: Color = .init(light: 0xFFFFFF, dark: 0x052E16),
        warning: Color = .init(light: 0xEA580C, dark: 0xFB923C),
        warningForeground: Color = .init(light: 0xFFFFFF, dark: 0x431407),
        error: Color = .init(light: 0xDC2626, dark: 0xF87171),
        errorForeground: Color = .init(light: 0xFFFFFF, dark: 0x450A0A),
        info: Color = .init(light: 0x2563EB, dark: 0x60A5FA),
        infoForeground: Color = .init(light: 0xFFFFFF, dark: 0xFFFFFF),
        border: Color = .init(light: 0xE4E4E7, dark: 0x27272A),
        borderStrong: Color = .init(light: 0xD4D4D8, dark: 0x3F3F46),
        ring: Color = .init(light: 0x2563EB, dark: 0x60A5FA),
        separator: Color = .init(light: 0xF4F4F5, dark: 0x27272A),
        overlay: Color = .init(light: 0x000000, dark: 0xFFFFFF).opacity(0.5),
        scrim: Color = .init(light: 0x000000, dark: 0x000000).opacity(0.6),
        glassFill: Color = .white.opacity(0.15),
        glassStroke: Color = .white.opacity(0.25),
        glassHighlight: Color = .white.opacity(0.4),
        gradientPrimary: [Color] = [
            .init(light: 0x18181B, dark: 0x27272A),
            .init(light: 0x27272A, dark: 0x18181B),
        ],
        gradientSecondary: [Color] = [
            .init(light: 0xF4F4F5, dark: 0x27272A),
            .init(light: 0xE4E4E7, dark: 0x3F3F46),
        ],
        gradientAccent: [Color] = [
            .init(light: 0x2563EB, dark: 0x3B82F6),
            .init(light: 0x7C3AED, dark: 0xA78BFA),
        ]
    ) {
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.backgroundTertiary = backgroundTertiary
        self.surface = surface
        self.surfaceElevated = surfaceElevated
        self.card = card
        self.foreground = foreground
        self.foregroundSecondary = foregroundSecondary
        self.foregroundTertiary = foregroundTertiary
        self.foregroundInverse = foregroundInverse
        self.primary = primary
        self.primaryForeground = primaryForeground
        self.primaryMuted = primaryMuted
        self.secondary = secondary
        self.secondaryForeground = secondaryForeground
        self.secondaryMuted = secondaryMuted
        self.accent = accent
        self.accentForeground = accentForeground
        self.success = success
        self.successForeground = successForeground
        self.warning = warning
        self.warningForeground = warningForeground
        self.error = error
        self.errorForeground = errorForeground
        self.info = info
        self.infoForeground = infoForeground
        self.border = border
        self.borderStrong = borderStrong
        self.ring = ring
        self.separator = separator
        self.overlay = overlay
        self.scrim = scrim
        self.glassFill = glassFill
        self.glassStroke = glassStroke
        self.glassHighlight = glassHighlight
        self.gradientPrimary = gradientPrimary
        self.gradientSecondary = gradientSecondary
        self.gradientAccent = gradientAccent
    }

    public static let `default` = ColorTokens()

    // MARK: - Brand Preset

    public static let ocean = ColorTokens(
        accent: .init(light: 0x0EA5E9, dark: 0x38BDF8),
        gradientAccent: [
            .init(light: 0x0EA5E9, dark: 0x38BDF8),
            .init(light: 0x6366F1, dark: 0x818CF8),
        ]
    )

    public static let emerald = ColorTokens(
        accent: .init(light: 0x059669, dark: 0x34D399),
        gradientAccent: [
            .init(light: 0x059669, dark: 0x34D399),
            .init(light: 0x0D9488, dark: 0x2DD4BF),
        ]
    )

    public static let sunset = ColorTokens(
        accent: .init(light: 0xEA580C, dark: 0xFB923C),
        gradientAccent: [
            .init(light: 0xEA580C, dark: 0xFB923C),
            .init(light: 0xDC2626, dark: 0xF87171),
        ]
    )

    public static let rose = ColorTokens(
        accent: .init(light: 0xE11D48, dark: 0xFB7185),
        gradientAccent: [
            .init(light: 0xE11D48, dark: 0xFB7185),
            .init(light: 0x9333EA, dark: 0xC084FC),
        ]
    )
}

extension Array where Element == Color {
    /// Apply uniform opacity to every color in a gradient.
    func opacity(_ opacity: Double) -> [Color] {
        map { $0.opacity(opacity) }
    }
}