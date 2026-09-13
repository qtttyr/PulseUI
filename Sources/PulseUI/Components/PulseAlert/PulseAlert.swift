import SwiftUI

// MARK: - PulseAlert

/// Premium inline notification banner. Animated, icon-driven, dismissible.
public struct PulseAlert: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let tone: PulseTone
    let title: String
    let message: String?
    let icon: String?
    let showsDismiss: Bool
    let onDismiss: (() -> Void)?

    @State private var isVisible = false

    public init(
        _ tone: PulseTone = .info,
        title: String,
        message: String? = nil,
        icon: String? = nil,
        showsDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.icon = icon
        self.showsDismiss = showsDismiss
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            iconView
                .frame(width: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.typography.callout.font)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.foreground)
                    .fixedSize(horizontal: false, vertical: true)

                if let message {
                    Text(message)
                        .font(theme.typography.subheadline.font)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsDismiss {
                Button {
                    withAnimation(theme.motion.springSnappy) {
                        onDismiss?()
                    }
                    PulseHaptic.impact(.light)
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.colors.foregroundTertiary)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PulseIconButtonStyle())
                .padding(.top, -2)
                .accessibilityLabel("Dismiss alert")
            }
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundView)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(backgroundFill, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .shadow(color: toneColor.opacity(0.08), radius: 8, y: 4)
        .offset(y: isVisible ? 0 : 12)
        .scaleEffect(isVisible ? 1 : 0.97)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            guard !reduceMotion else {
                isVisible = true
                return
            }
            withAnimation(theme.motion.spring) {
                isVisible = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(message ?? "")
    }

    @ViewBuilder
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(toneColor.opacity(0.15))
                .frame(width: 30, height: 30)

            Image(systemName: icon ?? defaultIcon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(toneColor)
        }
    }

    private var backgroundView: some View {
        backgroundFill.opacity(0.6)
    }

    private var backgroundFill: Color {
        toneColor.opacity(0.12)
    }

    private var defaultIcon: String {
        switch tone {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .accent: return "sparkles"
        case .primary: return "circle.fill"
        case .neutral: return "circle"
        }
    }

    private var toneColor: Color {
        switch tone {
        case .neutral: return theme.colors.secondary
        case .primary: return theme.colors.primary
        case .accent: return theme.colors.accent
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error: return theme.colors.error
        case .info: return theme.colors.info
        }
    }
}