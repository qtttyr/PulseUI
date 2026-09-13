import SwiftUI

// MARK: - Spacing Tokens

/// Consistent spacing scale. Never use magic numbers.
public struct SpacingTokens: Sendable {
    public let xxs: CGFloat
    public let xs: CGFloat
    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat
    public let xl: CGFloat
    public let xxl: CGFloat
    public let xxxl: CGFloat

    // Semantic aliases
    public var space0: CGFloat { 0 }
    public var space1: CGFloat { xxs }
    public var space2: CGFloat { xs }
    public var space3: CGFloat { sm }
    public var space4: CGFloat { md }
    public var space5: CGFloat { lg }
    public var space6: CGFloat { xl }
    public var space8: CGFloat { xxl }
    public var space10: CGFloat { xxxl }

    // Component-specific
    public var buttonHorizontal: CGFloat { md * 2.5 }
    public var buttonVertical: CGFloat { sm }
    public var cardPadding: CGFloat { lg }
    public var inputPadding: CGFloat { md }
    public var sectionGap: CGFloat { xxl }

    public init(
        xxs: CGFloat = 2,
        xs: CGFloat = 4,
        sm: CGFloat = 8,
        md: CGFloat = 12,
        lg: CGFloat = 16,
        xl: CGFloat = 20,
        xxl: CGFloat = 24,
        xxxl: CGFloat = 32
    ) {
        self.xxs = xxs
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
    }

    public static let `default` = SpacingTokens()

    public static let compact = SpacingTokens(
        xxs: 1, xs: 2, sm: 6, md: 10, lg: 14, xl: 18, xxl: 20, xxxl: 28
    )

    public static let spacious = SpacingTokens(
        xxs: 4, xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 40, xxxl: 48
    )
}
