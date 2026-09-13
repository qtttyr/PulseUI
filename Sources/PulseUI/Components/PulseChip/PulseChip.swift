import SwiftUI

// MARK: - PulseChip

/// Filter chip / tag with selection states, icons, and smooth animations.
public struct PulseChip<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isSelected: Bool
    let style: ChipStyle
    let showsCheckmark: Bool
    let onTap: (() -> Void)?
    let accessibilityLabel: String?
    let content: () -> Content

    @State private var isPressed = false

    public init(
        _ text: String,
        isSelected: Bool = false,
        style: ChipStyle = .default,
        showsCheckmark: Bool = true,
        accessibilityLabel: String? = nil,
        onTap: (() -> Void)? = nil
    ) where Content == Text {
        self.init(
            isSelected: isSelected,
            style: style,
            showsCheckmark: showsCheckmark,
            accessibilityLabel: accessibilityLabel ?? text,
            onTap: onTap
        ) {
            Text(text)
        }
    }

    public init(
        isSelected: Bool = false,
        style: ChipStyle = .default,
        showsCheckmark: Bool = true,
        accessibilityLabel: String? = nil,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isSelected = isSelected
        self.style = style
        self.showsCheckmark = showsCheckmark
        self.onTap = onTap
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }

    public var body: some View {
        Group {
            if let onTap {
                Button(action: {
                    PulseHaptic.selection()
                    onTap()
                }) {
                    chipSurface
                }
                .buttonStyle(.plain)
                .accessibilityLabel(accessibilityLabel ?? "Chip")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityHint("Tap to toggle")
            } else {
                chipSurface
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilityLabel ?? "Chip")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private var chipSurface: some View {
        HStack(spacing: theme.spacing.xs) {
            if isSelected && showsCheckmark {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(foregroundColor)
                    .transition(.scale.combined(with: .opacity))
            }

            content()
                .font(theme.typography.subheadline.font)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(foregroundColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(backgroundView)
        .overlay(overlayView)
        .clipShape(Capsule())
        .scaleEffect(isPressed ? 0.95 : 1)
        .contentShape(Capsule())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            if onTap != nil {
                withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                    isPressed = pressing
                }
            }
        }, perform: {})
        .animation(reduceMotion ? .none : theme.motion.springSnappy, value: isSelected)
        .pulseEntrance(scale: 0.94, offsetY: 6)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .default:
            if isSelected {
                theme.colors.primary
            } else {
                theme.colors.backgroundSecondary
            }
        case .tinted:
            if isSelected {
                theme.colors.accent.opacity(0.15)
            } else {
                theme.colors.backgroundSecondary
            }
        case .outlined:
            Color.clear
        case .glass:
            Color.clear.pulseGlassCapsule(.interactive)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .outlined:
            Capsule()
                .strokeBorder(
                    isSelected ? theme.colors.accent : theme.colors.border,
                    lineWidth: isSelected ? 1.5 : 1
                )
        case .default:
            if isSelected {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
            }
        default:
            EmptyView()
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .default:
            return isSelected ? theme.colors.primaryForeground : theme.colors.foreground
        case .tinted:
            return isSelected ? theme.colors.accent : theme.colors.foreground
        case .outlined:
            return isSelected ? theme.colors.accent : theme.colors.foreground
        case .glass:
            return theme.colors.foreground
        }
    }
}

// MARK: - Styles

public enum ChipStyle: Sendable {
    case `default`
    case tinted
    case outlined
    case glass
}