import SwiftUI

// MARK: - PulseStepper

/// Premium increment/decrement control with smooth number transitions and haptics.
public struct PulseStepper: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let range: ClosedRange<Int>
    @Binding var value: Int
    let step: Int
    let showsLabel: Bool
    let format: (Int) -> String
    let onChanged: ((Int) -> Void)?

    public init(
        _ value: Binding<Int>,
        in range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        showsLabel: Bool = true,
        format: @escaping (Int) -> String = { "\($0)" },
        onChanged: ((Int) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = max(1, step)
        self.showsLabel = showsLabel
        self.format = format
        self.onChanged = onChanged
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button {
                decrement()
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(canDecrement ? theme.colors.foreground : theme.colors.foregroundTertiary.opacity(0.4))
                    .frame(width: 44, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PulseStepperButtonStyle())
            .disabled(!canDecrement)
            .accessibilityLabel("Decrease")

            if showsLabel {
                Text(format(value))
                    .font(theme.typography.body.font)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.foreground)
                    .monospacedDigit()
                    .frame(minWidth: 60)
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? .none : theme.motion.fast, value: value)
                    .accessibilityHidden(true)
            }

            Button {
                increment()
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(canIncrement ? theme.colors.foreground : theme.colors.foregroundTertiary.opacity(0.4))
                    .frame(width: 44, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PulseStepperButtonStyle())
            .disabled(!canIncrement)
            .accessibilityLabel("Increase")
        }
        .background(
            Capsule()
                .fill(theme.colors.backgroundSecondary)
        )
        .overlay(
            Capsule()
                .strokeBorder(theme.colors.border, lineWidth: 1)
        )
        .clipShape(Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Stepper")
        .accessibilityValue(format(value))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: increment()
            case .decrement: decrement()
            @unknown default: break
            }
        }
    }

    private var canIncrement: Bool {
        value + step <= range.upperBound
    }

    private var canDecrement: Bool {
        value - step >= range.lowerBound
    }

    private func increment() {
        guard canIncrement else {
            PulseHaptic.impact(.soft)
            return
        }
        withAnimation(theme.motion.springSnappy) {
            value += step
        }
        PulseHaptic.selection()
        onChanged?(value)
    }

    private func decrement() {
        guard canDecrement else {
            PulseHaptic.impact(.soft)
            return
        }
        withAnimation(theme.motion.springSnappy) {
            value -= step
        }
        PulseHaptic.selection()
        onChanged?(value)
    }
}

// MARK: - Press feedback

/// Quick spring-down press for the stepper buttons, paired with the capsule body.
private struct PulseStepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.82 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}