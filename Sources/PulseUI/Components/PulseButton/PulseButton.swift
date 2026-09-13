import SwiftUI

// MARK: - PulseButton

/// Premium animated button with variants, sizes, loading states, and glass support.
/// Usage: `PulseButton(.primary, size: .md) { Text("Tap me") }`
public struct PulseButton<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.pulseReduceMotion) private var pulseReduceMotion

    let variant: ButtonVariant
    let size: ButtonSize
    let iconPosition: IconPosition
    let isLoading: Bool
    let action: () -> Void
    let content: () -> Content

    @State private var isPressed = false

    public init(
        _ variant: ButtonVariant = .primary,
        size: ButtonSize = .md,
        iconPosition: IconPosition = .leading,
        isLoading: Bool = false,
        action: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.variant = variant
        self.size = size
        self.iconPosition = iconPosition
        self.isLoading = isLoading
        self.action = action
        self.content = content
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(loadingColor)
                        .transition(loadingTransition)
                }

                content()
                    .opacity(isLoading ? 0 : 1)
            }
            .font(size.font)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: size == .full ? .infinity : nil)
            .frame(minHeight: size.minHeight)
            .background(backgroundView)
            .overlay(overlayView)
            .clipShape(buttonShape)
            .shadow(color: shadowColor, radius: isPressed ? 1 : shadowRadius, y: isPressed ? 0 : shadowY)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isEnabled ? 1 : 0.5)
            .pulseEntrance(scale: 0.97, offsetY: 4)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                isPressed = pressing
            }
        }, perform: {})
        .sensoryFeedback(.selection, trigger: isPressed)
        .animation(reduceMotion ? .none : theme.motion.springSnappy, value: isLoading)
    }

    private var reduceMotion: Bool {
        accessibilityReduceMotion || pulseReduceMotion
    }

    private var loadingTransition: AnyTransition {
        reduceMotion ? .identity : .scale.combined(with: .opacity)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .primary:
            LinearGradient(
                colors: [theme.colors.primary, theme.colors.primary.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            theme.colors.secondary
        case .outline:
            Color.clear
        case .ghost, .link:
            Color.clear
        case .destructive:
            LinearGradient(
                colors: [theme.colors.error, theme.colors.error.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .glass:
            Color.clear.pulseGlass(.interactive, in: buttonShape)
                .overlay(theme.colors.glassFill)
        case .gradient:
            ZStack {
                LinearGradient(
                    colors: theme.colors.gradientAccent,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                PulseSheenView(cornerRadius: theme.radius.lg, repeats: true)
            }
        }
    }

    // MARK: - Overlay

    @ViewBuilder
    private var overlayView: some View {
        if variant == .outline {
            buttonShape.stroke(theme.colors.border, lineWidth: 1)
        } else if variant == .glass {
            buttonShape.stroke(theme.colors.glassStroke.opacity(0.6), lineWidth: 0.5)
        }
    }

    private var buttonShape: AnyShape {
        switch size {
        case .icon, .iconSm, .iconLg:
            return AnyShape(Circle())
        default:
            return AnyShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        }
    }

    // MARK: - Colors

    private var loadingColor: Color {
        switch variant {
        case .primary, .destructive, .gradient:
            return theme.colors.primaryForeground
        case .secondary:
            return theme.colors.secondaryForeground
        case .outline, .ghost, .link:
            return theme.colors.foreground
        case .glass:
            return theme.colors.foreground
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .primary:
            return theme.colors.primary.opacity(0.3)
        case .destructive:
            return theme.colors.error.opacity(0.3)
        case .gradient:
            return theme.colors.accent.opacity(0.3)
        default:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .primary, .destructive: return 4
        case .gradient: return isPressed ? 6 : 10
        default: return 0
        }
    }

    private var shadowY: CGFloat {
        switch variant {
        case .primary, .destructive, .gradient: return 2
        default: return 0
        }
    }
}

// MARK: - Variants

public enum ButtonVariant: Sendable {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
    case glass
    case gradient
    case link
}

// MARK: - Sizes

public enum ButtonSize: Sendable {
    case sm, md, lg, xl
    case iconSm, icon, iconLg
    case full

    var font: Font {
        switch self {
        case .sm: return .subheadline.weight(.medium)
        case .md: return .body.weight(.semibold)
        case .lg: return .body.weight(.bold)
        case .xl: return .title3.weight(.bold)
        case .iconSm: return .caption.weight(.semibold)
        case .icon: return .body.weight(.semibold)
        case .iconLg: return .title3.weight(.semibold)
        case .full: return .body.weight(.semibold)
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 16
        case .lg: return 20
        case .xl: return 24
        case .iconSm: return 0
        case .icon: return 0
        case .iconLg: return 0
        case .full: return 16
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .sm: return 6
        case .md: return 10
        case .lg: return 12
        case .xl: return 14
        case .iconSm: return 6
        case .icon: return 10
        case .iconLg: return 14
        case .full: return 10
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .sm: return 32
        case .md: return 40
        case .lg: return 48
        case .xl: return 56
        case .iconSm: return 28
        case .icon: return 40
        case .iconLg: return 52
        case .full: return 44
        }
    }
}

// MARK: - Icon Position

public enum IconPosition: Sendable {
    case leading, trailing
}

// MARK: - Convenience Initializers

extension PulseButton where Content == Text {
    public init(
        _ title: String,
        variant: ButtonVariant = .primary,
        size: ButtonSize = .md,
        iconPosition: IconPosition = .leading,
        isLoading: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            variant,
            size: size,
            iconPosition: iconPosition,
            isLoading: isLoading,
            action: action
        ) {
            Text(title)
        }
    }
}

extension PulseButton where Content == Label<Text, Image> {
    public init(
        _ title: String,
        systemImage: String,
        variant: ButtonVariant = .primary,
        size: ButtonSize = .md,
        iconPosition: IconPosition = .leading,
        isLoading: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            variant,
            size: size,
            iconPosition: iconPosition,
            isLoading: isLoading,
            action: action
        ) {
            Label(title, systemImage: systemImage)
        }
    }
}

extension PulseButton where Content == Image {
    public init(
        systemImage: String,
        variant: ButtonVariant = .primary,
        size: ButtonSize = .icon,
        isLoading: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.init(variant, size: size, isLoading: isLoading, action: action) {
            Image(systemName: systemImage)
        }
    }
}
