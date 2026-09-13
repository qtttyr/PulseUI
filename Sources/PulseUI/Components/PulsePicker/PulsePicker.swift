import SwiftUI

// MARK: - PulsePicker

/// Custom segmented control with animated indicator, and menu picker.
public struct PulsePicker<T: Hashable & Sendable>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selection: T
    let items: [PickerItem<T>]
    let style: PulsePickerStyle
    let size: PulsePickerSize

    public init(
        _ selection: Binding<T>,
        items: [PickerItem<T>],
        style: PulsePickerStyle = .segmented,
        size: PulsePickerSize = .md
    ) {
        self._selection = selection
        self.items = items
        self.style = style
        self.size = size
    }

    public var body: some View {
        switch style {
        case .segmented: segmentedView
        case .pill: pillView
        }
    }

    // MARK: - Segmented

    private var segmentedView: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                            selection = item.value
                        }
                        PulseHaptic.selection()
                    } label: {
                        Text(item.label)
                            .font(size.font)
                            .fontWeight(selection == item.value ? .semibold : .medium)
                            .foregroundStyle(selection == item.value ? theme.colors.foreground : theme.colors.foregroundSecondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.label)
                    .accessibilityAddTraits(selection == item.value ? .isSelected : [])
                }
            }
            .background(
                GeometryReader { geo in
                    let selectedIndex = selectedIndex
                    let itemWidth = geo.size.width / CGFloat(items.count)
                    let xPosition = CGFloat(selectedIndex) * itemWidth

                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .fill(theme.colors.background)
                        .frame(width: itemWidth)
                        .offset(x: xPosition)
                        .shadow(color: theme.colors.foreground.opacity(0.08), radius: 4, y: 2)
                }
                .animation(reduceMotion ? .none : theme.motion.springSnappy, value: selection)
            )
        }
        .frame(height: size.segmentHeight)
        .background(theme.colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }

    // MARK: - Pill

    private var pillView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                            selection = item.value
                        }
                        PulseHaptic.selection()
                    } label: {
                        Text(item.label)
                            .font(size.font)
                            .padding(.horizontal, size.pillHorizontalPadding)
                            .padding(.vertical, size.pillVerticalPadding)
                            .background(pillBackground(for: item.value))
                            .overlay(pillOverlay(for: item.value))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.label)
                    .accessibilityAddTraits(selection == item.value ? .isSelected : [])
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func pillBackground(for value: T) -> some View {
        Group {
            if selection == value {
                theme.colors.primary
            } else {
                Color.clear
            }
        }
    }

    private func pillOverlay(for value: T) -> some View {
        Group {
            if selection != value {
                Capsule()
                    .strokeBorder(theme.colors.border, lineWidth: 1)
            }
        }
    }

    private var selectedIndex: Int {
        items.firstIndex { $0.value == selection } ?? 0
    }
}

// MARK: - Types

public struct PickerItem<T: Hashable & Sendable>: Identifiable, Sendable {
    public let id: String
    public let value: T
    public let label: String

    public init(value: T, label: String) {
        self.id = "\(value.hashValue)"
        self.value = value
        self.label = label
    }
}

public enum PulsePickerStyle: Sendable {
    case segmented
    case pill
}

public enum PulsePickerSize: Sendable {
    case sm, md, lg

    var font: Font {
        switch self {
        case .sm: return .subheadline
        case .md: return .subheadline
        case .lg: return .callout
        }
    }

    var segmentHeight: CGFloat {
        switch self {
        case .sm: return 32
        case .md: return 36
        case .lg: return 44
        }
    }

    var pillHorizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 16
        case .lg: return 20
        }
    }

    var pillVerticalPadding: CGFloat {
        switch self {
        case .sm: return 4
        case .md: return 6
        case .lg: return 8
        }
    }
}