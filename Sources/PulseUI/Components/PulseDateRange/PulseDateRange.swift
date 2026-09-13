import SwiftUI

// MARK: - PulseDateRange

/// Beautiful date range picker with a calendar wheel, chip presets, and glass styling.
public struct PulseDateRange: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var startDate: Date?
    @Binding var endDate: Date?

    let presets: [DateRangePreset]
    let showsClearButton: Bool

    public init(
        startDate: Binding<Date?>,
        endDate: Binding<Date?>,
        presets: [DateRangePreset] = DateRangePreset.standard,
        showsClearButton: Bool = true
    ) {
        self._startDate = startDate
        self._endDate = endDate
        self.presets = presets
        self.showsClearButton = showsClearButton
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            if !presets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ForEach(presets) { preset in
                            presetChip(preset)
                        }
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(theme.typography.overline.font)
                        .foregroundStyle(theme.colors.foregroundTertiary)
                    Text(formatDate(startDate))
                        .font(theme.typography.subheadline.font)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.colors.foreground)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.foregroundTertiary)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("End")
                        .font(theme.typography.overline.font)
                        .foregroundStyle(theme.colors.foregroundTertiary)
                    Text(formatDate(endDate))
                        .font(theme.typography.subheadline.font)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.colors.foreground)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(theme.spacing.md)
            .background(theme.colors.backgroundSecondary.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))

            if showsClearButton && (startDate != nil || endDate != nil) {
                Button("Clear dates") {
                    withAnimation(theme.motion.springSnappy) {
                        startDate = nil
                        endDate = nil
                    }
                    PulseHaptic.selection()
                }
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.accent)
                .buttonStyle(.plain)
                .accessibilityLabel("Clear selected dates")
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func presetChip(_ preset: DateRangePreset) -> some View {
        let isActive = preset.isActive(startDate: startDate, endDate: endDate)

        Button {
            withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                startDate = preset.start
                endDate = preset.end
            }
            PulseHaptic.selection()
        } label: {
            Text(preset.label)
                .font(theme.typography.caption.font)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundStyle(isActive ? .white : theme.colors.foregroundSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isActive ? theme.colors.accent : theme.colors.backgroundSecondary)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isActive ? Color.clear : theme.colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.label)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "Not set" }
        return date.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
        )
    }
}

// MARK: - Presets

public struct DateRangePreset: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let start: Date
    public let end: Date

    public init(id: String, label: String, start: Date, end: Date) {
        self.id = id
        self.label = label
        self.start = start
        self.end = end
    }

    public static let standard: [DateRangePreset] = [
        DateRangePreset(
            id: "today",
            label: "Today",
            start: Calendar.current.startOfDay(for: Date()),
            end: Date()
        ),
        DateRangePreset(
            id: "week",
            label: "This Week",
            start: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            end: Date()
        ),
        DateRangePreset(
            id: "month",
            label: "This Month",
            start: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            end: Date()
        ),
        DateRangePreset(
            id: "quarter",
            label: "Quarter",
            start: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            end: Date()
        ),
    ]

    func isActive(startDate: Date?, endDate: Date?) -> Bool {
        guard let startDate, let endDate else { return false }
        let dayInterval: TimeInterval = 24 * 60 * 60
        return fabs(startDate.timeIntervalSince(start)) < dayInterval
            && fabs(endDate.timeIntervalSince(end)) < dayInterval
    }
}