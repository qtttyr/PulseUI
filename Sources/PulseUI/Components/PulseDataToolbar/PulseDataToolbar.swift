import SwiftUI

// MARK: - PulseDataToolbar

/// Reusable search, filter, and sort surface for data-heavy screens.
public struct PulseDataToolbar<FilterContent: View, SortContent: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Binding var query: String
    let prompt: String
    let filterContent: () -> FilterContent
    let sortContent: () -> SortContent

    public init(
        query: Binding<String>,
        prompt: String = "Search",
        @ViewBuilder filters: @escaping () -> FilterContent,
        @ViewBuilder sort: @escaping () -> SortContent
    ) {
        self._query = query
        self.prompt = prompt
        self.filterContent = filters
        self.sortContent = sort
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.colors.foregroundTertiary)
                    .accessibilityHidden(true)
                TextField(prompt, text: $query)
                    .textFieldStyle(.plain)
                    .font(theme.typography.body.font)
                    .accessibilityLabel(prompt)
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(theme.colors.foregroundTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .frame(minHeight: 44)
            .background(theme.colors.backgroundSecondary.opacity(0.8))
            .clipShape(Capsule())

            Menu {
                filterContent()
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease")
            }
            .menuStyle(.button)
            .buttonStyle(.bordered)
            .tint(theme.colors.foreground)

            Menu {
                sortContent()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            .menuStyle(.button)
            .buttonStyle(.bordered)
            .tint(theme.colors.foreground)
        }
        .padding(theme.spacing.xs)
        .background(theme.colors.surfaceElevated.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .stroke(theme.colors.border.opacity(0.7), lineWidth: 1)
        )
        .pulseGlass(cornerRadius: theme.radius.xl)
    }
}
