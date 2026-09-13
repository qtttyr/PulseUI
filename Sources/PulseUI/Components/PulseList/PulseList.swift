import SwiftUI

// MARK: - PulseList

/// Styled list container with rows, separators, icons, and optional swipe actions.
public struct PulseList<Content: View>: View {
    @Environment(\.pulseTheme) private var theme

    let style: ListStyle
    let content: () -> Content

    public init(
        _ style: ListStyle = .rounded,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.content = content
    }

    public var body: some View {
        Group {
            switch style {
            case .rounded:
                content()
                    .background(theme.colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                            .strokeBorder(theme.colors.border, lineWidth: 1)
                    )
            case .plain:
                content()
            case .inset:
                content()
                    .padding(.horizontal, theme.spacing.md)
                    .background(theme.colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
            }
        }
    }
}

// MARK: - PulseListRow

public struct PulseListRow: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String?
    let icon: String?
    let iconTint: Color?
    let showsChevron: Bool
    let action: (() -> Void)?

    @State private var isPressed = false

    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconTint: Color? = nil,
        showsChevron: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconTint = iconTint
        self.showsChevron = showsChevron
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
            if action != nil {
                PulseHaptic.selection()
            }
        } label: {
            HStack(spacing: theme.spacing.md) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(iconTint ?? theme.colors.accent)
                        .frame(width: 34, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill((iconTint ?? theme.colors.accent).opacity(0.12))
                        )
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.foreground)
                        .lineLimit(1)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.footnote.font)
                            .foregroundStyle(theme.colors.foregroundSecondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.foregroundTertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed && action != nil ? 0.98 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            if action != nil {
                withAnimation(theme.motion.springSnappy) {
                    isPressed = pressing
                }
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityHint(subtitle ?? title)
        .accessibilityAddTraits(showsChevron ? .isButton : [])
    }
}

// MARK: - Types

public enum PulseListStyle: Sendable {
    case rounded
    case plain
    case inset
}

public typealias ListStyle = PulseListStyle