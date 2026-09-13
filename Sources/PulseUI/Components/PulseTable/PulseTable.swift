import SwiftUI

// MARK: - PulseTable

/// A responsive data table that keeps the content layer clean and reserves
/// glass for the toolbar or surrounding controls.
public struct PulseTableColumn<Row>: Identifiable {
    public let id = UUID()
    public let title: String
    public let width: CGFloat
    fileprivate let content: (Row) -> AnyView

    public init<Content: View>(
        _ title: String,
        width: CGFloat = 140,
        @ViewBuilder content: @escaping (Row) -> Content
    ) {
        self.title = title
        self.width = width
        self.content = { AnyView(content($0)) }
    }
}

public struct PulseTable<Row: Identifiable>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public enum State: Equatable, Sendable {
        case loaded
        case loading
        case empty(String = "No results")
        case error(String = "Unable to load this table")
    }

    private let rows: [Row]
    private let columns: [PulseTableColumn<Row>]
    private let state: State
    private let onSelect: ((Row) -> Void)?

    public init(
        _ rows: [Row],
        columns: [PulseTableColumn<Row>],
        state: State = .loaded,
        onSelect: ((Row) -> Void)? = nil
    ) {
        self.rows = rows
        self.columns = columns
        self.state = state
        self.onSelect = onSelect
    }

    public var body: some View {
        Group {
            switch state {
            case .loaded:
                tableContent
            case .loading:
                ProgressView("Loading")
                    .tint(theme.colors.accent)
                    .frame(maxWidth: .infinity, minHeight: 160)
            case .empty(let message):
                ContentUnavailableView(message, systemImage: "tray")
                    .frame(maxWidth: .infinity, minHeight: 160)
            case .error(let message):
                ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
                    .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
        .animation(reduceMotion ? .none : theme.motion.normal, value: state)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Data table")
    }

    private var tableContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                ForEach(rows) { row in
                    rowView(row)
                }
            }
            .frame(minWidth: columns.reduce(0) { $0 + $1.width })
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.border.opacity(0.75), lineWidth: 1)
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                Text(column.title)
                    .font(theme.typography.overline.font)
                    .foregroundStyle(theme.colors.foregroundSecondary)
                    .textCase(.uppercase)
                    .frame(width: column.width, alignment: .leading)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .frame(height: 38)
        .background(theme.colors.backgroundSecondary.opacity(0.65))
    }

    @ViewBuilder
    private func rowView(_ row: Row) -> some View {
        let content = HStack(spacing: 0) {
            ForEach(columns) { column in
                column.content(row)
                    .frame(width: column.width, alignment: .leading)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .frame(minHeight: 52)
        .background(theme.colors.card)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.border.opacity(0.5))
                .frame(height: 1)
        }

        if let onSelect {
            Button { onSelect(row) } label: { content }
                .buttonStyle(.plain)
                .accessibilityHint("Double tap to select row")
        } else {
            content
        }
    }
}
