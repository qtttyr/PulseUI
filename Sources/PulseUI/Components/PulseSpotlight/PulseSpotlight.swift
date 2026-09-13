import SwiftUI

// MARK: - PulseSpotlight

/// A restrained hero surface for important product moments and launch screens.
public struct PulseSpotlight<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let eyebrow: String?
    private let title: String
    private let message: String?
    private let content: () -> Content

    public init(
        eyebrow: String? = nil,
        title: String,
        message: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.message = message
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(theme.typography.overline.font)
                    .tracking(1.4)
                    .foregroundStyle(theme.colors.accent)
            }
            Text(title)
                .font(theme.typography.hero.font)
                .foregroundStyle(theme.colors.foreground)
            if let message {
                Text(message)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.foregroundSecondary)
            }
            content()
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack(alignment: .topTrailing) {
                theme.colors.surfaceElevated
                Circle()
                    .fill(theme.colors.accent.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .blur(radius: reduceMotion ? 20 : 36)
                    .offset(x: 70, y: -90)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xxl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.xxl, style: .continuous)
                .stroke(theme.colors.border.opacity(0.8), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}
