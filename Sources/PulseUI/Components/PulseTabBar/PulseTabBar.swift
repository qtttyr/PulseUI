import SwiftUI

// MARK: - PulseTabBar

/// Premium animated tab bar with floating glass background and magic morphing indicator.
public struct PulseTabBar: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selection: Int
    let tabs: [TabItem]
    let style: PulseTabBarStyle

    public init(
        selection: Binding<Int>,
        tabs: [TabItem],
        style: PulseTabBarStyle = .floating
    ) {
        self._selection = selection
        self.tabs = tabs
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                tabButton(for: index, tab: tab)
            }
        }
        .background(backgroundView)
        .overlay(overlayView)
        .clipShape(containerShape)
        .padding(.horizontal, style == .floating ? 16 : 0)
        .padding(.bottom, style == .floating ? 8 : 0)
        .shadow(
            color: theme.colors.foreground.opacity(style == .floating ? 0.08 : 0),
            radius: 18,
            y: 8
        )
        .accessibilityElement(children: .contain)
    }

    private var containerShape: AnyShape {
        AnyShape(
            RoundedRectangle(
                cornerRadius: style == .floating ? theme.radius.xxl : 0,
                style: .continuous
            )
        )
    }

    @ViewBuilder
    private func tabButton(for index: Int, tab: TabItem) -> some View {
        let isSelected = selection == index

        Button {
            withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                selection = index
            }
            PulseHaptic.selection()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? selectedFill : .clear)
                        .frame(width: 44, height: 30)

                    Image(systemName: tab.icon)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? selectedIconColor : theme.colors.foregroundTertiary)
                        .scaleEffect(isSelected && !reduceMotion ? 1.1 : 1)
                        .symbolEffect(.bounce, options: .nonRepeating, value: isSelected)
                }

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? theme.colors.foreground : theme.colors.foregroundTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "" : "Double tap to select \(tab.label)")
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .floating:
            Color.clear.pulseGlass(.regular, cornerRadius: theme.radius.xxl)
                .overlay(theme.colors.glassFill)
        case .solid, .inset:
            theme.colors.background
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if style != .floating {
            Rectangle()
                .fill(theme.colors.border.opacity(0.5))
                .frame(height: 0.5)
                .frame(maxHeight: .infinity, alignment: .top)
        } else if style == .floating {
            containerShape.stroke(theme.colors.glassStroke.opacity(0.5), lineWidth: 0.5)
        }
    }

    private var selectedFill: Color {
        theme.colors.accent.opacity(0.15)
    }

    private var selectedIconColor: Color {
        theme.colors.accent
    }
}

// MARK: - Types

public struct TabItem: Identifiable, Sendable {
    public let id: UUID
    public let label: String
    public let icon: String

    public init(label: String, icon: String) {
        self.id = UUID()
        self.label = label
        self.icon = icon
    }
}

public enum PulseTabBarStyle: Sendable {
    case floating
    case solid
    case inset
}