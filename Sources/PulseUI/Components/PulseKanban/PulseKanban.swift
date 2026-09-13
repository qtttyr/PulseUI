import SwiftUI

// MARK: - PulseKanban

public struct PulseKanbanCard: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String?

    public init(id: String, title: String, detail: String? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}

public struct PulseKanbanColumn: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let cards: [PulseKanbanCard]

    public init(id: String, title: String, cards: [PulseKanbanCard]) {
        self.id = id
        self.title = title
        self.cards = cards
    }
}

/// Adaptive horizontal board. Data ownership stays with the caller through `onMove`.
public struct PulseKanban: View {
    @Environment(\.pulseTheme) private var theme
    private let columns: [PulseKanbanColumn]
    private let onMove: ((PulseKanbanCard, PulseKanbanColumn) -> Void)?

    public init(
        _ columns: [PulseKanbanColumn],
        onMove: ((PulseKanbanCard, PulseKanbanColumn) -> Void)? = nil
    ) {
        self.columns = columns
        self.onMove = onMove
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                ForEach(columns) { column in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        HStack {
                            Text(column.title)
                                .font(theme.typography.headline.font)
                            Spacer()
                            Text("\(column.cards.count)")
                                .font(theme.typography.caption.font)
                                .foregroundStyle(theme.colors.foregroundSecondary)
                        }
                        ForEach(column.cards) { card in
                            Button { } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(card.title)
                                        .font(theme.typography.body.font.weight(.semibold))
                                    if let detail = card.detail {
                                        Text(detail)
                                            .font(theme.typography.caption.font)
                                            .foregroundStyle(theme.colors.foregroundSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(theme.spacing.md)
                                .background(theme.colors.card)
                                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .onDrag { NSItemProvider(object: card.id as NSString) }
                            .onDrop(of: [.text], isTargeted: nil) { _ in
                                onMove?(card, column)
                                return true
                            }
                        }
                    }
                    .padding(theme.spacing.md)
                    .frame(width: 260, alignment: .top)
                    .background(theme.colors.backgroundSecondary.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
                }
            }
            .padding(.vertical, theme.spacing.xs)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Kanban board")
    }
}
