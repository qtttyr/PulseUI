import SwiftUI

// MARK: - PulseCalendar

/// Native graphical calendar with a themed shell and optional date bounds.
public struct PulseCalendar: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var selection: Date
    private let title: String
    private let range: ClosedRange<Date>?

    public init(
        _ title: String = "Calendar",
        selection: Binding<Date>,
        in range: ClosedRange<Date>? = nil
    ) {
        self.title = title
        self._selection = selection
        self.range = range
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.headline.font)
                .foregroundStyle(theme.colors.foreground)
            if let range {
                DatePicker("", selection: $selection, in: range, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.graphical)
            } else {
                DatePicker("", selection: $selection, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.graphical)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.card)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .stroke(theme.colors.border.opacity(0.75), lineWidth: 1)
        }
        .animation(reduceMotion ? .none : theme.motion.normal, value: selection)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}
