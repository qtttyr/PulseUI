import SwiftUI

// MARK: - PulseProgress

/// Progress indicators: linear, circular, and indeterminate. With animated transitions.
public struct PulseProgress: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let style: ProgressStyle
    let value: Double?
    let total: Double
    let tint: Color?
    let showsLabel: Bool
    let strokeWidth: CGFloat
    let size: CircularSize
    let caption: String?
    let format: (Double) -> String

    @State private var animatedValue: Double = 0
    @State private var isIndeterminateAnimating = false

    public init(
        _ style: ProgressStyle = .linear,
        value: Double? = nil,
        total: Double = 1.0,
        tint: Color? = nil,
        showsLabel: Bool = true,
        strokeWidth: CGFloat = 6,
        size: CircularSize = .md,
        caption: String? = nil,
        format: @escaping (Double) -> String = { "\(Int(($0 * 100).rounded()))%" }
    ) {
        self.style = style
        self.value = value
        self.total = total
        self.tint = tint
        self.showsLabel = showsLabel
        self.strokeWidth = strokeWidth
        self.size = size
        self.caption = caption
        self.format = format
    }

    public var body: some View {
        Group {
            switch style {
            case .linear: linearView
            case .circular: circularView
            case .ring: ringView
            case .indeterminateLinear: indeterminateView
            }
        }
        .onAppear {
            if let value {
                guard !reduceMotion else { animatedValue = value / total; return }
                withAnimation(theme.motion.slow) {
                    animatedValue = value / total
                }
            } else {
                guard !reduceMotion else { return }
                withAnimation(theme.motion.springGentle.repeatForever(autoreverses: true)) {
                    isIndeterminateAnimating = true
                }
            }
        }
        .onChange(of: value) { _, newValue in
            guard let newValue, !reduceMotion else {
                if let newValue { animatedValue = newValue / total }
                return
            }
            withAnimation(theme.motion.normal) {
                animatedValue = newValue / total
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(caption ?? "Progress")
        .accessibilityValue(format(currentValue))
    }

    // MARK: - Linear

    private var linearView: some View {
        VStack(spacing: theme.spacing.sm) {
            HStack {
                if let caption {
                    Text(caption)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                }
                Spacer()
                if showsLabel {
                    Text(format(currentValue))
                        .font(theme.typography.caption.font)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(reduceMotion ? .none : theme.motion.fast, value: animatedValue)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.colors.backgroundTertiary.opacity(0.7))
                        .frame(height: strokeWidth)

                    Capsule()
                        .fill(progressColor)
                        .frame(width: max(strokeWidth, geo.size.width * currentValue), height: strokeWidth)
                        .overlay(
                            Capsule()
                                .fill(.white.opacity(0.3))
                                .frame(height: strokeWidth * 0.3)
                                .padding(.top, -strokeWidth * 0.2)
                        )
                }
                .frame(height: strokeWidth)
            }
            .frame(height: strokeWidth)
        }
    }

    // MARK: - Circular

    private var circularView: some View {
        VStack(spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .stroke(theme.colors.backgroundTertiary.opacity(0.7), lineWidth: strokeWidth)

                Circle()
                    .trim(from: 0, to: currentValue)
                    .stroke(
                        AngularGradient(
                            colors: [
                                progressColor,
                                progressColor.opacity(0.6),
                                progressColor
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? .none : theme.motion.spring, value: currentValue)

                if showsLabel {
                    Text(format(currentValue))
                        .font(size.labelFont)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(reduceMotion ? .none : theme.motion.fast, value: animatedValue)
                }
            }
            .frame(width: size.dimension, height: size.dimension)

            if let caption {
                Text(caption)
                    .font(theme.typography.subheadline.font)
                    .foregroundStyle(theme.colors.foregroundSecondary)
            }
        }
    }

    // MARK: - Ring

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(theme.colors.backgroundTertiary.opacity(0.55), lineWidth: strokeWidth)

            Circle()
                .trim(from: 0, to: currentValue)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? .none : theme.motion.spring, value: currentValue)

            Image(systemName: "checkmark")
                .font(.system(size: size.dimension * 0.3, weight: .semibold))
                .foregroundStyle(progressColor)
                .opacity(currentValue >= 1 ? 1 : 0)
                .scaleEffect(currentValue >= 1 ? 1 : 0.5)
                .animation(reduceMotion ? .none : theme.motion.springBouncy, value: currentValue)
        }
        .frame(width: size.dimension, height: size.dimension)
    }

    // MARK: - Indeterminate

    private var indeterminateView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.colors.backgroundTertiary.opacity(0.7))
                    .frame(height: strokeWidth)

                Capsule()
                    .fill(progressColor)
                    .frame(width: geo.size.width * 0.4, height: strokeWidth)
                    .offset(x: isIndeterminateAnimating ? geo.size.width * 0.8 : -geo.size.width * 0.4)
            }
            .frame(height: strokeWidth)
        }
        .frame(height: strokeWidth)
        .animation(reduceMotion ? .none : theme.motion.springGentle.repeatForever(autoreverses: true), value: isIndeterminateAnimating)
    }

    // MARK: - Helpers

    private var currentValue: Double {
        if let value {
            guard total > 0, total.isFinite else { return 0 }
            return min(max(value / total, 0), 1)
        }
        return 0
    }

    private var progressColor: Color {
        tint ?? theme.colors.accent
    }
}

// MARK: - Types

public enum ProgressStyle: Sendable {
    case linear
    case circular
    case ring
    case indeterminateLinear
}

public enum CircularSize: Sendable {
    case sm, md, lg, xl

    var dimension: CGFloat {
        switch self {
        case .sm: return 52
        case .md: return 72
        case .lg: return 96
        case .xl: return 132
        }
    }

    var labelFont: Font {
        switch self {
        case .sm: return .subheadline
        case .md: return .title3
        case .lg: return .title2
        case .xl: return .largeTitle
        }
    }

    var defaultStroke: CGFloat {
        switch self {
        case .sm: return 4
        case .md: return 6
        case .lg: return 8
        case .xl: return 10
        }
    }
}