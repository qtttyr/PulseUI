import SwiftUI

// MARK: - PulseTimeline

public struct PulseTimelineEvent: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String?
    public let date: String
    public let systemImage: String

    public init(
        id: String,
        title: String,
        detail: String? = nil,
        date: String,
        systemImage: String = "circle.fill"
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.date = date
        self.systemImage = systemImage
    }
}

public struct PulseTimeline: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let events: [PulseTimelineEvent]

    public init(_ events: [PulseTimelineEvent]) {
        self.events = events
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    VStack(spacing: 0) {
                        Image(systemName: event.systemImage)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.colors.accent)
                            .frame(width: 24, height: 24)
                            .background(theme.colors.accent.opacity(0.14), in: Circle())
                        if index < events.count - 1 {
                            Rectangle()
                                .fill(theme.colors.border)
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(event.title)
                                .font(theme.typography.headline.font)
                                .foregroundStyle(theme.colors.foreground)
                            Spacer()
                            Text(event.date)
                                .font(theme.typography.caption.font)
                                .foregroundStyle(theme.colors.foregroundTertiary)
                        }
                        if let detail = event.detail {
                            Text(detail)
                                .font(theme.typography.body.font)
                                .foregroundStyle(theme.colors.foregroundSecondary)
                        }
                    }
                    .padding(.bottom, theme.spacing.lg)
                }
            }
        }
        .animation(reduceMotion ? .none : theme.motion.normal, value: events.map(\.id))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Timeline")
    }
}
