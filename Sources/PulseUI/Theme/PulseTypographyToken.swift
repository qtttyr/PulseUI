import SwiftUI

// MARK: - Typography Tokens

/// Semantic typography scale. Maps to system fonts with weight and size.
public struct TypographyTokens: Sendable {
    public let hero: FontStyle
    public let title1: FontStyle
    public let title2: FontStyle
    public let title3: FontStyle
    public let headline: FontStyle
    public let body: FontStyle
    public let callout: FontStyle
    public let subheadline: FontStyle
    public let footnote: FontStyle
    public let caption: FontStyle
    public let overline: FontStyle
    public let label: FontStyle
    public let mono: FontStyle

    public init(
        hero: FontStyle = .init(size: 34, weight: .bold, design: .rounded),
        title1: FontStyle = .init(size: 28, weight: .bold, design: .default),
        title2: FontStyle = .init(size: 22, weight: .semibold, design: .default),
        title3: FontStyle = .init(size: 20, weight: .semibold, design: .default),
        headline: FontStyle = .init(size: 17, weight: .semibold, design: .default),
        body: FontStyle = .init(size: 17, weight: .regular, design: .default),
        callout: FontStyle = .init(size: 16, weight: .regular, design: .default),
        subheadline: FontStyle = .init(size: 15, weight: .regular, design: .default),
        footnote: FontStyle = .init(size: 13, weight: .regular, design: .default),
        caption: FontStyle = .init(size: 12, weight: .regular, design: .default),
        overline: FontStyle = .init(size: 11, weight: .medium, design: .default),
        label: FontStyle = .init(size: 14, weight: .medium, design: .rounded),
        mono: FontStyle = .init(size: 14, weight: .regular, design: .monospaced)
    ) {
        self.hero = hero
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption = caption
        self.overline = overline
        self.label = label
        self.mono = mono
    }

    public static let `default` = TypographyTokens()

    public struct FontStyle: Sendable {
        public let size: CGFloat
        public let weight: Font.Weight
        public let design: Font.Design
        public let tracking: CGFloat

        public init(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default, tracking: CGFloat = 0) {
            self.size = size
            self.weight = weight
            self.design = design
            self.tracking = tracking
        }

        public var font: Font {
            Font.system(size: size, weight: weight, design: design)
        }
    }
}
