import SwiftUI

// MARK: - PulseNavigationBar

/// Premium navigation bar with custom styling, glass background, and scroll-aware effects.
public struct PulseNavigationBar<Trailing: View, Leading: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String?
    let subtitle: String?
    let style: PulseNavigationBarStyle
    let leading: Leading?
    let trailing: Trailing?

    @State private var isVisible = false

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        style: PulseNavigationBarStyle = .weather,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            if let leading {
                leading
                    .frame(width: leadingWidth)
            } else {
                Color.clear
                    .frame(width: leadingWidth)
            }

            if let title {
                VStack(alignment: .center, spacing: 1) {
                    Text(title)
                        .font(theme.typography.headline.font)
                        .foregroundStyle(theme.colors.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.footnote.font)
                            .foregroundStyle(theme.colors.foregroundSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .offset(y: isVisible ? 0 : 8)
                .opacity(isVisible ? 1 : 0)
                .onAppear {
                    guard !reduceMotion else {
                        isVisible = true
                        return
                    }
                    withAnimation(theme.motion.springSnappy) {
                        isVisible = true
                    }
                }
            } else {
                Spacer(minLength: leadingWidth)
            }

            if let trailing {
                trailing
                    .frame(width: leadingWidth)
            } else {
                Color.clear
                    .frame(width: leadingWidth)
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, 8)
        .background(backgroundView)
        .overlay(
            RoundedRectangle(cornerRadius: backgroundRadius, style: .continuous)
                .strokeBorder(theme.colors.border.opacity(0.3), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: backgroundRadius, style: .continuous))
        .shadow(color: theme.colors.foreground.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .contain)
    }

    private var leadingWidth: CGFloat {
        switch style {
        case .weather: return 40
        case .minimal: return 0
        case .edges: return 0
        }
    }

    private var backgroundRadius: CGFloat {
        switch style {
        case .weather: return theme.radius.xxl
        case .minimal: return theme.radius.lg
        case .edges: return 0
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .weather:
            Color.clear.pulseGlass(.regular, cornerRadius: theme.radius.xxl)
                .overlay(theme.colors.glassFill)
                .padding(.horizontal, 16)
        case .minimal:
            Color.clear.background(theme.colors.background.opacity(0.85))
        case .edges:
            Color.clear.background(theme.colors.background.opacity(0.85))
        }
    }
}

// MARK: - Types

public enum PulseNavigationBarStyle: Sendable {
    case weather
    case minimal
    case edges
}