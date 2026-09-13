import SwiftUI

// MARK: - PulseBadge

/// Small status indicator with semantic tones, animated styles, and optional leading dot.
public struct PulseBadge: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let tone: PulseTone
    let style: BadgeStyle
    let showDot: Bool
    let accessibilityLabel: String?
    let content: () -> AnyView

    @State private var isPulsing = false

    public init<Content: View>(
        _ tone: PulseTone = .neutral,
        style: BadgeStyle = .filled,
        showDot: Bool = false,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.tone = tone
        self.style = style
        self.showDot = showDot
        self.accessibilityLabel = accessibilityLabel
        self.content = { AnyView(content()) }
    }

    public init(
        _ text: String,
        tone: PulseTone = .neutral,
        style: BadgeStyle = .filled,
        showDot: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.init(tone, style: style, showDot: showDot, accessibilityLabel: accessibilityLabel ?? text) {
            Text(text)
        }
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            if showDot {
                Circle()
                    .fill(toneColor)
                    .frame(width: 5, height: 5)
                    .scaleEffect(reduceMotion ? 1 : (isPulsing ? 1.2 : 0.9))
                    .onAppear {
                        guard !reduceMotion else { return }
                        withAnimation(theme.motion.springBouncy.repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                    .accessibilityHidden(true)
            }
            content()
                .font(theme.typography.caption.font)
                .fontWeight(.medium)
                .foregroundStyle(contentColor)
                .lineLimit(1)
        }
        .padding(.horizontal, theme.spacing.sm + 2)
        .padding(.vertical, theme.spacing.xs)
        .background(backgroundView)
        .overlay(overlayView)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? "Badge")
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            toneColor
        case .subtle:
            toneColor.opacity(0.15)
        case .outlined:
            Color.clear
        case .glass:
            Color.clear.pulseGlass(.regular, cornerRadius: theme.radius.lg)
                .overlay(theme.colors.glassFill)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if style == .outlined {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(toneColor.opacity(0.5), lineWidth: 1)
        } else if style == .subtle {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(toneColor.opacity(0.3), lineWidth: 0.5)
        }
    }

    private var contentColor: Color {
        switch (style, tone) {
        case (.filled, _):
            switch tone {
            case .neutral: return theme.colors.secondaryForeground
            case .primary: return theme.colors.primaryForeground
            case .accent: return theme.colors.accentForeground
            case .success: return theme.colors.successForeground
            case .warning: return theme.colors.warningForeground
            case .error: return theme.colors.errorForeground
            case .info: return theme.colors.infoForeground
            }
        case (_, .neutral):
            return theme.colors.foregroundSecondary
        case (_, .primary):
            return theme.colors.primary
        case (_, .accent):
            return theme.colors.accent
        default:
            return toneColor
        }
    }

    private var toneColor: Color {
        switch tone {
        case .neutral: return theme.colors.secondary
        case .primary: return theme.colors.primary
        case .accent: return theme.colors.accent
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error: return theme.colors.error
        case .info: return theme.colors.info
        }
    }
}

// MARK: - Tones

public enum PulseTone: Sendable {
    case neutral
    case primary
    case accent
    case success
    case warning
    case error
    case info
}

// MARK: - Styles

public enum BadgeStyle: Sendable {
    case filled
    case subtle
    case outlined
    case glass
}