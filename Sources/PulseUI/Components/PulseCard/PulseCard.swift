import SwiftUI

// MARK: - PulseCard

/// Premium surface container. Elevated, outlined, filled, glass, and gradient-border variants.
/// Interactive mode adds a press scale effect.
public struct PulseCard<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let style: CardStyle
    let cornerRadius: CGFloat?
    let isInteractive: Bool
    let action: (() -> Void)?
    let accessibilityLabel: String?
    let content: () -> Content

    @State private var isPressed = false

    public init(
        _ style: CardStyle = .elevated,
        cornerRadius: CGFloat? = nil,
        isInteractive: Bool = false,
        action: (() -> Void)? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.action = action
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    cardSurface
                }
                .buttonStyle(.plain)
                .accessibilityLabel(accessibilityLabel ?? "Card")
            } else {
                cardSurface
            }
        }
    }

    private var cardSurface: some View {
        content()
            .padding(theme.spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundView)
            .clipShape(shape)
            .overlay(overlayView)
            .pulseGlow(color: shadowColor, radius: shadowRadius, breathes: breathesGlow)
            .scaleEffect(isInteractive && isPressed ? 0.98 : 1.0)
            .pulseEntrance(delay: entranceDelay, scale: 0.98, offsetY: 8)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                if isInteractive {
                    withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                        isPressed = pressing
                    }
                }
            }, perform: {})
    }

    private var breathesGlow: Bool {
        switch style {
        case .glass, .gradient, .gradientBorder, .floating: return isInteractive
        default: return false
        }
    }

    private var entranceDelay: Double {
        switch style {
        case .gradient, .gradientBorder: return 0.15
        default: return 0
        }
    }

    private var shape: AnyShape {
        AnyShape(RoundedRectangle(cornerRadius: cornerRadius ?? theme.radius.xl, style: .continuous))
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .elevated:
            theme.colors.card
        case .outlined:
            theme.colors.card
        case .filled:
            theme.colors.backgroundSecondary
        case .glass:
            Color.clear.pulseGlass(.regular, in: shape)
        case .gradient:
            ZStack {
                LinearGradient(
                    colors: theme.colors.gradientAccent.opacity(0.12),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                PulseSheenView(cornerRadius: cornerRadius ?? theme.radius.xl, repeats: true)
            }
        case .gradientBorder:
            theme.colors.card
        case .floating:
            theme.colors.surfaceElevated
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .outlined:
            shape.stroke(theme.colors.border, lineWidth: 1)
        case .gradientBorder:
            shape.stroke(
                LinearGradient(
                    colors: theme.colors.gradientAccent,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
        case .glass:
            shape.stroke(theme.colors.glassStroke.opacity(0.5), lineWidth: 0.5)
        default:
            EmptyView()
        }
    }

    private var shadowColor: Color {
        switch style {
        case .elevated, .floating: return theme.colors.foreground.opacity(0.08)
        case .glass, .gradient, .gradientBorder: return theme.colors.accent.opacity(0.1)
        default: return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .elevated: return 8
        case .floating: return 16
        case .glass, .gradient, .gradientBorder: return 12
        default: return 0
        }
    }

    private var shadowY: CGFloat {
        switch style {
        case .elevated: return 4
        case .floating: return 8
        case .glass, .gradient, .gradientBorder: return 6
        default: return 0
        }
    }
}

// MARK: - Card Styles

public enum CardStyle: Sendable {
    case elevated
    case outlined
    case filled
    case glass
    case gradient
    case gradientBorder
    case floating
}