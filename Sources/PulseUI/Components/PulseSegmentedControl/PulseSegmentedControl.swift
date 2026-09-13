import SwiftUI

// MARK: - PulseSegmentedControl

/// A native-feeling segmented control with keyboard and VoiceOver semantics.
public struct PulseSegmentedControl<Item: Hashable>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var selection: Item
    private let items: [Item]
    private let title: (Item) -> String

    public init(
        selection: Binding<Item>,
        items: [Item],
        title: @escaping (Item) -> String = { String(describing: $0) }
    ) {
        self._selection = selection
        self.items = items
        self.title = title
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                        selection = item
                    }
                } label: {
                    Text(title(item))
                        .font(theme.typography.caption.font.weight(.semibold))
                        .foregroundStyle(
                            selection == item
                                ? theme.colors.foreground
                                : theme.colors.foregroundSecondary
                        )
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background {
                            if selection == item {
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .fill(theme.colors.card)
                                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                                    .transition(.opacity)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == item ? [.isSelected] : [])
                .accessibilityLabel(title(item))
                .accessibilityHint("Double tap to select")
            }
        }
        .padding(3)
        .background(theme.colors.backgroundSecondary.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .pulseGlass(cornerRadius: theme.radius.lg)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Segmented control")
    }
}
