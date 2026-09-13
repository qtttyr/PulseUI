import Charts
import SwiftUI

// MARK: - PulseChart

public struct PulseChartPoint: Identifiable, Sendable, Equatable {
    public let id: String
    public let label: String
    public let value: Double

    public init(id: String, label: String, value: Double) {
        self.id = id
        self.label = label
        self.value = value
    }
}

/// Swift Charts-backed visualisation with native accessibility and state handling.
public struct PulseChart: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public enum Style: Sendable, Hashable {
        case line
        case area
        case bar
    }

    public enum State: Equatable, Sendable {
        case loaded
        case loading
        case empty(String = "No data available")
        case error(String = "Unable to load chart")
    }

    private let title: String
    private let points: [PulseChartPoint]
    private let style: Style
    private let state: State

    public init(
        _ title: String,
        points: [PulseChartPoint],
        style: Style = .area,
        state: State = .loaded
    ) {
        self.title = title
        self.points = points
        self.style = style
        self.state = state
    }

    public var body: some View {
        Group {
            switch state {
            case .loaded:
                chart
            case .loading:
                ProgressView("Loading chart")
                    .tint(theme.colors.accent)
                    .frame(maxWidth: .infinity, minHeight: 180)
            case .empty(let message), .error(let message):
                ContentUnavailableView(message, systemImage: "chart.xyaxis.line")
                    .frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .animation(reduceMotion ? .none : theme.motion.normal, value: state)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilitySummary)
    }

    private var chart: some View {
        Chart(points) { point in
            switch style {
            case .line:
                LineMark(
                    x: .value("Category", point.label),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(theme.colors.accent)
                PointMark(
                    x: .value("Category", point.label),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(theme.colors.accent)
            case .area:
                AreaMark(
                    x: .value("Category", point.label),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.accent.opacity(0.7), theme.colors.accent.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value("Category", point.label),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(theme.colors.accent)
            case .bar:
                BarMark(
                    x: .value("Category", point.label),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(theme.colors.accent.gradient)
                .cornerRadius(5)
            }
        }
        .chartXAxis { AxisMarks(values: .automatic) }
        .chartYAxis { AxisMarks(position: .leading) }
        .chartPlotStyle { plot in
            plot
                .background(theme.colors.backgroundSecondary.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        }
        .padding(theme.spacing.sm)
    }

    private var accessibilitySummary: String {
        guard let first = points.first, let last = points.last else { return "No values" }
        return "\(points.count) values, from \(first.value.formatted()) to \(last.value.formatted())"
    }
}
