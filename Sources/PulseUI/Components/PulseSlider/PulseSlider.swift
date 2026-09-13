import SwiftUI

// MARK: - PulseSlider

/// Premium labeled slider with animated thumb, gradient fill, and value snapping.
public struct PulseSlider: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double?
    let label: String?
    let caption: String?
    let showsValue: Bool
    let tint: Color?
    let format: (Double) -> String

    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var lastTickStep: Int?

    public init(
        _ label: String? = nil,
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double? = nil,
        caption: String? = nil,
        showsValue: Bool = true,
        tint: Color? = nil,
        format: @escaping (Double) -> String = { String(format: "%.2f", $0) }
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.caption = caption
        self.showsValue = showsValue
        self.tint = tint
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let label {
                    Text(label)
                        .font(theme.typography.callout.font)
                        .foregroundStyle(theme.colors.foreground)
                        .accessibilityHidden(true)
                }
                Spacer()
                if showsValue {
                    Text(format(value))
                        .font(theme.typography.mono.font)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(reduceMotion ? .none : theme.motion.fast, value: value)
                        .accessibilityHidden(true)
                }
            }

            sliderBody

            if let caption {
                Text(caption)
                    .font(theme.typography.footnote.font)
                    .foregroundStyle(theme.colors.foregroundTertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label ?? "Slider")
        .accessibilityValue(format(value))
        .accessibilityAdjustableAction { direction in
            let delta = step ?? (range.upperBound - range.lowerBound) / 20
            switch direction {
            case .increment:
                value = min(value + delta, range.upperBound)
            case .decrement:
                value = max(value - delta, range.lowerBound)
            @unknown default:
                break
            }
        }
    }

    // MARK: - Slider Body

    private var sliderBody: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width
            let span = range.upperBound - range.lowerBound
            let normalized = span > 0 ? (value - range.lowerBound) / span : 0
            let thumbPosition = normalized * trackWidth

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.colors.backgroundTertiary.opacity(0.8))
                    .frame(height: 6)

                Capsule()
                    .fill(progressColor)
                    .frame(width: thumbPosition, height: 6)

                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: theme.colors.foreground.opacity(0.15), radius: 6, y: 3)
                    .overlay(
                        Circle()
                            .stroke(progressColor, lineWidth: 2)
                    )
                    .offset(x: thumbPosition - 12)
                    .scaleEffect(isDragging ? 1.15 : 1)
                    .animation(
                        (isDragging ? .linear(duration: 0) : theme.motion.springSnappy)
                            .pulseAnimation(reduceMotion: reduceMotion),
                        value: thumbPosition
                    )
                    .pulseGlow(
                        color: progressColor.opacity(0.4),
                        radius: isDragging ? 10 : 0,
                        breathes: false
                    )
            }
            .frame(height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        guard trackWidth > 0, range.upperBound > range.lowerBound else { return }
                        if !isDragging {
                            isDragging = true
                            PulseHaptic.selection()
                        }
                        let raw = gesture.location.x / trackWidth
                        var newValue = range.lowerBound + Double(raw) * (range.upperBound - range.lowerBound)
                        if let step {
                            let steps = round((newValue - range.lowerBound) / step)
                            newValue = range.lowerBound + steps * step
                            let tick = Int(steps)
                            if tick != lastTickStep {
                                PulseHaptic.selection()
                                lastTickStep = tick
                            }
                        }
                        value = min(max(newValue, range.lowerBound), range.upperBound)
                    }
                    .onEnded { _ in
                        isDragging = false
                        lastTickStep = nil
                    }
            )
        }
        .frame(height: 24)
    }

    private var progressColor: Color {
        tint ?? theme.colors.accent
    }
}