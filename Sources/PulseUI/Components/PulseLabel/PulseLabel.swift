import SwiftUI

// MARK: - PulseLabel

/// Semantic typography component. Maps roles to theme tokens with Dynamic Type support.
public struct PulseLabel: View {
    @Environment(\.pulseTheme) private var theme

    let role: PulseLabelRole
    let content: () -> AnyView

    public init<Content: View>(_ role: PulseLabelRole = .body, @ViewBuilder content: @escaping () -> Content) {
        self.role = role
        self.content = { AnyView(content()) }
    }

    public init(_ text: String, role: PulseLabelRole = .body) {
        self.init(role) { Text(text) }
    }

    public var body: some View {
        content()
            .font(role.style.font)
            .foregroundStyle(roleColor)
            .tracking(role.style.tracking)
            .lineLimit(role.lineLimit)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
    }

    private var roleColor: Color {
        switch role {
        case .hero, .title1, .title2, .title3, .headline:
            return theme.colors.foreground
        case .body, .callout, .subheadline:
            return theme.colors.foreground
        case .caption, .footnote:
            return theme.colors.foregroundSecondary
        case .overline:
            return theme.colors.foregroundSecondary
        case .label:
            return theme.colors.foreground
        case .mono:
            return theme.colors.foreground
        case .secondary:
            return theme.colors.foregroundSecondary
        case .tertiary:
            return theme.colors.foregroundTertiary
        }
    }
}

public enum PulseLabelRole: Sendable {
    case hero
    case title1
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case overline
    case label
    case mono
    case secondary
    case tertiary

    var style: TypographyTokens.FontStyle {
        switch self {
        case .hero: return TypographyTokens.default.hero
        case .title1: return TypographyTokens.default.title1
        case .title2: return TypographyTokens.default.title2
        case .title3: return TypographyTokens.default.title3
        case .headline: return TypographyTokens.default.headline
        case .body: return TypographyTokens.default.body
        case .callout: return TypographyTokens.default.callout
        case .subheadline: return TypographyTokens.default.subheadline
        case .footnote: return TypographyTokens.default.footnote
        case .caption: return TypographyTokens.default.caption
        case .overline: return TypographyTokens.default.overline
        case .label: return TypographyTokens.default.label
        case .mono: return TypographyTokens.default.mono
        case .secondary, .tertiary: return TypographyTokens.default.body
        }
    }

    var lineLimit: Int? {
        switch self {
        case .hero: return 3
        default: return nil
        }
    }
}