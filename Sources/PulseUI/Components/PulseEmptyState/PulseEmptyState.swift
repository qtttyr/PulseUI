import SwiftUI

// MARK: - PulseEmptyState

/// Beautiful empty state with icon, title, message, and action. Animated entrance.
public struct PulseEmptyState<Action: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let icon: String
    let iconTint: Color?
    let title: String
    let message: String?
    let action: Action?

    @State private var isAnimatingIn = false
    @State private var iconBounces = false

    public init(
        icon: String,
        iconTint: Color? = nil,
        title: String,
        message: String? = nil,
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.message = message
        self.action = action()
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            ZStack {
                Circle()
                    .fill((iconTint ?? theme.colors.accent).opacity(0.1))
                    .frame(width: 96, height: 96)

                Circle()
                    .strokeBorder(
                        (iconTint ?? theme.colors.accent).opacity(0.15),
                        lineWidth: 1
                    )
                    .frame(width: 110, height: 110)
                    .scaleEffect(iconBounces ? 1.05 : 1)

                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(iconTint ?? theme.colors.accent)
                    .scaleEffect(iconBounces ? 0.9 : 1)
            }
            .offset(y: isAnimatingIn ? 0 : 20)
            .opacity(isAnimatingIn ? 1 : 0)

            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .font(theme.typography.title3.font)
                    .foregroundStyle(theme.colors.foreground)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .offset(y: isAnimatingIn ? 0 : 12)
            .opacity(isAnimatingIn ? 1 : 0)

            if action != nil {
                action
                    .padding(.top, 4)
                    .opacity(isAnimatingIn ? 1 : 0)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .onAppear {
            guard !reduceMotion else {
                isAnimatingIn = true
                return
            }
            withAnimation(theme.motion.springBouncy) {
                isAnimatingIn = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(theme.motion.springBouncy.repeatForever(autoreverses: true)) {
                    iconBounces = true
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(message ?? "")
    }
}