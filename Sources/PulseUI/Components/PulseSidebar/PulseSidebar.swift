import SwiftUI

// MARK: - PulseSidebar

/// Premium sidebar/rail navigation with animated indicators and glass option.
public struct PulseSidebar<Content: View>: View {
    @Environment(\.pulseTheme) private var theme

    let style: PulseSidebarStyle
    let showsLabels: Bool
    let content: () -> Content

    public init(
        style: PulseSidebarStyle = .rail,
        showsLabels: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.showsLabels = showsLabels
        self.content = content
    }

    public var body: some View {
        content()
            .padding(.vertical, theme.spacing.md)
            .padding(.horizontal, showsLabels ? theme.spacing.md : theme.spacing.xs)
            .frame(width: showsLabels ? 260 : 64, alignment: .top)
            .background(backgroundView)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(theme.colors.border.opacity(0.3), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .rail:
            Color.clear.pulseGlass(.regular, cornerRadius: 24)
                .overlay(theme.colors.glassFill)
        case .solid:
            theme.colors.background
        }
    }
}

// MARK: - PulseSidebarItem

public struct PulseSidebarItem: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    let showsLabel: Bool

    @State private var isPressed = false

    public init(
        _ title: String,
        icon: String,
        isSelected: Bool = false,
        showsLabel: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
        self.showsLabel = showsLabel
    }

    public var body: some View {
        Button {
            PulseHaptic.selection()
            action()
        } label: {
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? theme.colors.accent.opacity(0.15) : .clear)
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? theme.colors.accent : theme.colors.foregroundSecondary)
                        .symbolEffect(.bounce, options: .nonRepeating, value: isSelected)
                }

                if showsLabel {
                    Text(title)
                        .font(theme.typography.subheadline.font)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(isSelected ? theme.colors.foreground : theme.colors.foregroundSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, theme.spacing.xs > 0 ? 4 : 4)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(theme.motion.springSnappy) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Types

public enum PulseSidebarStyle: Sendable {
    case rail
    case solid
}