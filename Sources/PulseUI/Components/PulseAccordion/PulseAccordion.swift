import SwiftUI

// MARK: - PulseAccordion

/// Collapsible section with smooth animation, chevron rotation, and glass option.
public struct PulseAccordion: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String?
    @Binding var isExpanded: Bool
    let style: AccordionStyle
    let content: () -> AnyView

    public init<Content: View>(
        _ title: String,
        subtitle: String? = nil,
        isExpanded: Binding<Bool>,
        style: AccordionStyle = .cards,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isExpanded = isExpanded
        self.style = style
        self.content = { AnyView(content()) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                    isExpanded.toggle()
                }
                PulseHaptic.selection()
            } label: {
                HStack(alignment: .center, spacing: theme.spacing.md) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(theme.typography.callout.font)
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.colors.foreground)
                            .lineLimit(1)

                        if let subtitle {
                            Text(subtitle)
                                .font(theme.typography.footnote.font)
                                .foregroundStyle(theme.colors.foregroundSecondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.foregroundTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(reduceMotion ? .none : theme.motion.springSnappy, value: isExpanded)
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title), \(isExpanded ? "expanded" : "collapsed")")
            .accessibilityHint("Double tap to toggle")

            if isExpanded {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.bottom, theme.spacing.md)
                    .accessibilityElement(children: .contain)
            }

            if style == .cards {
                PulseDivider()
                    .opacity(isExpanded ? 0 : 1)
            }
        }
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(overlayColor, lineWidth: 1)
        )
        .animation(reduceMotion ? .none : theme.motion.spring, value: isExpanded)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .cards:
            if isExpanded {
                theme.colors.backgroundSecondary.opacity(0.6)
            } else {
                theme.colors.card
            }
        case .glass:
            Color.clear.pulseGlass(.regular, cornerRadius: theme.radius.lg)
                .overlay(theme.colors.glassFill)
        case .transparent:
            Color.clear
        }
    }

    private var overlayColor: Color {
        switch style {
        case .cards:
            return isExpanded ? theme.colors.border.opacity(0.8) : theme.colors.border
        case .glass:
            return theme.colors.glassStroke
        case .transparent:
            return .clear
        }
    }
}

// MARK: - Types

public enum AccordionStyle: Sendable {
    case cards
    case glass
    case transparent
}

// MARK: - Multiple Accordions

public struct PulseAccordionGroup: View {
    @Environment(\.pulseTheme) private var theme

    let items: [AccordionItem]
    let allowsMultiple: Bool

    @State private var expandedIndexes: Set<Int>

    public init(
        items: [AccordionItem],
        allowsMultiple: Bool = false,
        defaultExpanded: Set<Int> = []
    ) {
        self.items = items
        self.allowsMultiple = allowsMultiple
        self._expandedIndexes = State(initialValue: defaultExpanded)
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                PulseAccordion(
                    item.title,
                    subtitle: item.subtitle,
                    isExpanded: Binding(
                        get: { expandedIndexes.contains(index) },
                        set: { expanded in
                            withAnimation(theme.motion.springSnappy) {
                                if expanded {
                                    if !allowsMultiple {
                                        expandedIndexes.removeAll()
                                    }
                                    expandedIndexes.insert(index)
                                } else {
                                    expandedIndexes.remove(index)
                                }
                            }
                        }
                    ),
                    style: item.style
                ) {
                    item.content
                }
            }
        }
    }
}

public struct AccordionItem: Identifiable, @unchecked Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let style: AccordionStyle
    public let content: AnyView

    nonisolated public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String? = nil,
        style: AccordionStyle = .cards,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.content = AnyView(content())
    }
}