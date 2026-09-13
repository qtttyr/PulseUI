import SwiftUI

// MARK: - PulseToggle

/// Premium animated toggle switch with custom styling, haptic feedback, and accessibility.
public struct PulseToggle: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var isOn: Bool
    let style: ToggleStyle
    let size: ToggleSize
    let tint: Color?
    let label: String?
    let description: String?

    @State private var knobOffset: CGFloat = 0

    public init(
        _ label: String? = nil,
        isOn: Binding<Bool>,
        description: String? = nil,
        style: ToggleStyle = .ios,
        size: ToggleSize = .md,
        tint: Color? = nil
    ) {
        self.label = label
        self._isOn = isOn
        self.description = description
        self.style = style
        self.size = size
        self.tint = tint
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            if let label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(theme.typography.callout.font)
                        .foregroundStyle(theme.colors.foreground)
                    if let description {
                        Text(description)
                            .font(theme.typography.footnote.font)
                            .foregroundStyle(theme.colors.foregroundSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
            }

            toggleView
                .onTapGesture {
                    toggle()
                }
                .accessibilityLabel(label ?? "Toggle")
                .accessibilityValue(isOn ? "On" : "Off")
                .accessibilityAddTraits(isOn ? .isSelected : [])
                .accessibilityHint(description ?? "")
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label ?? "Toggle")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityActions {
            Button(isOn ? "Turn off" : "Turn on") { toggle() }
        }
    }

    @ViewBuilder
    private var toggleView: some View {
        switch style {
        case .ios:
            iosToggle
        case .checkbox:
            checkboxToggle
        case .pill:
            pillToggle
        }
    }

    // MARK: - iOS Style

    private var iosToggle: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(backgroundFill)
                .frame(width: size.toggleWidth, height: size.toggleHeight)
                .overlay(
                    Capsule()
                        .strokeBorder(theme.colors.border.opacity(0.3), lineWidth: 0.5)
                )

            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                .frame(width: size.knobDimension, height: size.knobDimension)
                .padding(size.padding)
                .scaleEffect(isOn ? 1.0 : 0.9)
        }
        .frame(width: size.toggleWidth, height: size.toggleHeight)
        .animation(reduceMotion ? .none : theme.motion.springBouncy, value: isOn)
        .contentShape(Capsule())
    }

    private var backgroundFill: Color {
        if isOn {
            return tint ?? theme.colors.accent
        }
        return theme.colors.backgroundTertiary.opacity(0.8)
    }

    // MARK: - Checkbox Style

    private var checkboxToggle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.knobDimension / 4, style: .continuous)
                .fill(isOn ? (tint ?? theme.colors.accent) : theme.colors.backgroundTertiary)
                .frame(width: size.checkboxSize, height: size.checkboxSize)
                .overlay(
                    RoundedRectangle(cornerRadius: size.knobDimension / 4, style: .continuous)
                        .strokeBorder(theme.colors.borderStrong, lineWidth: 1)
                )

            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: size.checkboxSize * 0.55, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: size.checkboxSize, height: size.checkboxSize)
        .contentShape(Rectangle())
        .animation(reduceMotion ? .none : theme.motion.springBouncy, value: isOn)
    }

    // MARK: - Pill Style

    private var pillToggle: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isOn ? .white : theme.colors.foregroundTertiary.opacity(0.5))
                .frame(width: 14, height: 14)

            Text(isOn ? "On" : "Off")
                .font(theme.typography.caption.font)
                .fontWeight(.semibold)
                .foregroundStyle(isOn ? .white : theme.colors.foregroundSecondary)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(
            Capsule()
                .fill(isOn ? (tint ?? theme.colors.accent) : theme.colors.backgroundTertiary)
        )
        .overlay(
            Capsule()
                .strokeBorder(isOn ? Color.clear : theme.colors.border, lineWidth: 1)
        )
        .contentShape(Capsule())
        .animation(reduceMotion ? .none : theme.motion.spring, value: isOn)
    }

    // MARK: - Actions

    private func toggle() {
        withAnimation(reduceMotion ? .none : theme.motion.springBouncy) {
            isOn.toggle()
        }
        PulseHaptic.impact(isOn ? .medium : .light)
    }
}

// MARK: - Styles

public enum ToggleStyle: Sendable {
    case ios
    case checkbox
    case pill
}

// MARK: - Sizes

public enum ToggleSize: Sendable {
    case sm
    case md
    case lg

    var toggleWidth: CGFloat {
        switch self {
        case .sm: return 34
        case .md: return 50
        case .lg: return 60
        }
    }

    var toggleHeight: CGFloat {
        switch self {
        case .sm: return 21
        case .md: return 30
        case .lg: return 36
        }
    }

    var knobDimension: CGFloat {
        switch self {
        case .sm: return 17
        case .md: return 26
        case .lg: return 32
        }
    }

    var padding: CGFloat {
        switch self {
        case .sm: return 2
        case .md: return 2
        case .lg: return 2
        }
    }

    var checkboxSize: CGFloat {
        switch self {
        case .sm: return 18
        case .md: return 22
        case .lg: return 28
        }
    }
}