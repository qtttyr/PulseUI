import SwiftUI

// MARK: - PulseCarousel

/// Horizontal scroll carousel with optional paging, snap behavior, and page indicators.
public struct PulseCarousel<Content: View, Item: Identifiable & Sendable>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let items: [Item]
    let showsIndicators: Bool
    let indicatorStyle: CarouselIndicatorStyle
    let spacing: CGFloat
    let content: (Item) -> Content

    @State private var currentPage: Int = 0
    @State private var visibleFrames: [Int: CGRect] = [:]

    public init(
        items: [Item],
        showsIndicators: Bool = true,
        indicatorStyle: CarouselIndicatorStyle = .dots,
        spacing: CGFloat = 16,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.showsIndicators = showsIndicators
        self.indicatorStyle = indicatorStyle
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: spacing) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            content(item)
                                .id(index)
                                .onAppear {
                                    updateCurrentPage(index, proxy: proxy)
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)

            if showsIndicators && items.count > 1 {
                indicatorView
            }
        }
    }

    private func updateCurrentPage(_ index: Int, proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(reduceMotion ? .none : theme.motion.spring) {
                currentPage = index
            }
        }
    }

    @ViewBuilder
    private var indicatorView: some View {
        HStack(spacing: 6) {
            ForEach(0..<items.count, id: \.self) { index in
                indicator(for: index)
                    .animation(reduceMotion ? .none : theme.motion.springSnappy, value: currentPage)
            }
        }
        .accessibilityLabel("Page \(currentPage + 1) of \(items.count)")
    }

    @ViewBuilder
    private func indicator(for index: Int) -> some View {
        switch indicatorStyle {
        case .dots:
            Capsule()
                .fill(index == currentPage ? theme.colors.accent : theme.colors.foregroundTertiary.opacity(0.3))
                .frame(width: index == currentPage ? 20 : 6, height: 6)
        case .bars:
            RoundedRectangle(cornerRadius: 1)
                .fill(index == currentPage ? theme.colors.accent : theme.colors.foregroundTertiary.opacity(0.3))
                .frame(width: 10, height: 3)
        case .numbers:
            if index == currentPage {
                Text("\(index + 1)")
                    .font(.caption2.bold())
                    .foregroundStyle(theme.colors.accent)
            } else {
                Text("\(index + 1)")
                    .font(.caption2)
                    .foregroundStyle(theme.colors.foregroundTertiary)
            }
        }
    }
}

// MARK: - Types

public enum CarouselIndicatorStyle: Sendable {
    case dots
    case bars
    case numbers
}