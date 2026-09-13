import SwiftUI

// MARK: - PulseMetricCard

/// A compact KPI surface with animated value, semantic delta, and optional sparkline.
public struct PulseMetricCard: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let value: String
    let delta: Delta?
    let points: [Double]
    let action: (() -> Void)?

    public init(
        _ title: String,
        value: String,
        delta: Delta? = nil,
        points: [Double] = [],
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.delta = delta
        self.points = points
        self.action = action
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) { cardContent }
                    .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilityValue)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.foregroundSecondary)
                Spacer()
                if action != nil {
                    Image(systemName: "chevron.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.foregroundTertiary)
                        .accessibilityHidden(true)
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: theme.spacing.sm) {
                Text(value)
                    .font(theme.typography.title1.font)
                    .foregroundStyle(theme.colors.foreground)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? .none : theme.motion.normal, value: value)
                if let delta {
                    Text(delta.label)
                        .font(theme.typography.caption.font)
                        .fontWeight(.semibold)
                        .foregroundStyle(delta.color(theme: theme))
                }
                Spacer()
            }

            if !points.isEmpty {
                PulseSparkline(points: points, color: delta?.color(theme: theme) ?? theme.colors.accent)
                    .frame(height: 34)
                    .accessibilityHidden(true)
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.card)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .stroke(theme.colors.border.opacity(0.7), lineWidth: 1)
        )
    }

    private var accessibilityValue: String {
        guard let delta else { return value }
        return "\(value), \(delta.label)"
    }
}

public extension PulseMetricCard {
    enum Delta: Sendable {
        case positive(String)
        case negative(String)
        case neutral(String)

        var label: String {
            switch self {
            case .positive(let label), .negative(let label), .neutral(let label): return label
            }
        }

        func color(theme: PulseTheme) -> Color {
            switch self {
            case .positive: return theme.colors.success
            case .negative: return theme.colors.error
            case .neutral: return theme.colors.foregroundSecondary
            }
        }
    }
}

private struct PulseSparkline: View {
    let points: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let bounds = normalizedBounds
            Path { path in
                guard points.count > 1 else { return }
                for (index, point) in points.enumerated() {
                    let x = geometry.size.width * CGFloat(index) / CGFloat(points.count - 1)
                    let y = geometry.size.height * (1 - CGFloat((point - bounds.min) / bounds.span))
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }

    private var normalizedBounds: (min: Double, span: Double) {
        let minValue = points.min() ?? 0
        let maxValue = points.max() ?? 1
        return (minValue, max(maxValue - minValue, 0.0001))
    }
}
