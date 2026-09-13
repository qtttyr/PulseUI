import SwiftUI

// MARK: - PulseToast

/// Ephemeral notification system with queue management and auto-dismiss.
/// Usage: `.pulseToast()` on the root view, then `PulseToastManager.shared.show(...)`.
public struct PulseToast: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isAnimating = false

    let entry: ToastEntry
    let onDismiss: () -> Void

    public init(
        entry: ToastEntry,
        appearImmediately: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.entry = entry
        self.onDismiss = onDismiss
        self._isAnimating = State(initialValue: appearImmediately)
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            if let icon = entry.icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(toneColor)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let title = entry.title {
                    Text(title)
                        .font(theme.typography.callout.font)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.colors.foreground)
                        .lineLimit(1)
                }
                if let message = entry.message {
                    Text(message)
                        .font(theme.typography.footnote.font)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if entry.showsCloseButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.colors.foregroundTertiary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(PulseIconButtonStyle())
                .accessibilityLabel("Dismiss notification")
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: toastRadius, style: .continuous)
                .stroke(theme.colors.border.opacity(0.4), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: toastRadius, style: .continuous))
        .shadow(color: theme.colors.foreground.opacity(0.12), radius: 16, y: 8)
        .scaleEffect(isAnimating ? 1 : 0.92)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 16)
        .onAppear {
            guard !reduceMotion else {
                isAnimating = true
                return
            }
            withAnimation(theme.motion.springBouncy) {
                isAnimating = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(entry.title ?? entry.message ?? "Notification")
    }

    private func dismiss() {
        withAnimation(theme.motion.springSnappy) {
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.25)) {
            onDismiss()
        }
    }

    private var toastRadius: CGFloat { theme.radius.lg }

    private var backgroundColor: Color {
        if let tone = entry.tone {
            return toneColor(tone).opacity(0.12)
        }
        return theme.colors.surfaceElevated
    }

    private var toneColor: Color {
        entry.tone.map { toneColor($0) } ?? theme.colors.accent
    }

    private func toneColor(_ tone: PulseTone) -> Color {
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

// MARK: - Toast Entry

public struct ToastEntry: Identifiable, Equatable {
    public let id: UUID
    public let type: ToastType
    public let title: String?
    public let message: String?
    public let icon: String?
    public let tone: PulseTone?
    public let duration: TimeInterval
    public let showsCloseButton: Bool

    public init(
        type: ToastType = .regular,
        title: String? = nil,
        message: String? = nil,
        icon: String? = nil,
        tone: PulseTone? = nil,
        duration: TimeInterval = 3.0,
        showsCloseButton: Bool = true
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.message = message
        self.icon = icon ?? Self.defaultIcon(for: tone ?? .info)
        self.tone = tone
        self.duration = duration
        self.showsCloseButton = showsCloseButton
    }

    public enum ToastType: Equatable {
        case regular
        case success
        case error
        case warning
        case info
    }

    private static func defaultIcon(for tone: PulseTone) -> String {
        switch tone {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .accent: return "sparkles"
        default: return "bell.fill"
        }
    }
}

// MARK: - Toast View Modifier

public struct PulseToastModifier: ViewModifier {
    @State private var toast: ToastEntry?
    @State private var isPresented = false

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast {
                    VStack {
                        PulseToast(entry: toast) {
                            dismissToast()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .zIndex(100)
                }
            }
            .onAppear {
                PulseToastCenter.shared.onShow = { newToast in
                    let existing = toast
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.toast = newToast
                    }
                    if let existing {
                        PulseToastCenter.shared.pending.append(existing)
                    }
                    isPresented = true
                    scheduleDismiss(for: newToast)
                }
            }
    }

    private func scheduleDismiss(for entry: ToastEntry) {
        DispatchQueue.main.asyncAfter(deadline: .now() + entry.duration) {
            if self.toast?.id == entry.id {
                dismissToast()
            }
        }
    }

    private func dismissToast() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            toast = nil
        }
        if !PulseToastCenter.shared.pending.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let next = PulseToastCenter.shared.pending.removeFirst()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.toast = next
                }
                scheduleDismiss(for: next)
            }
        }
    }
}

public extension View {
    /// Attach the toast presentation system to your root view.
    func pulseToast() -> some View {
        modifier(PulseToastModifier())
    }
}

// MARK: - Toast Center

@MainActor
public final class PulseToastCenter {
    public static let shared = PulseToastCenter()

    var pending: [ToastEntry] = []
    var onShow: ((ToastEntry) -> Void)?

    public func show(_ entry: ToastEntry) {
        onShow?(entry)
    }

    public func show(title: String?, message: String? = nil, tone: PulseTone, duration: TimeInterval = 3) {
        show(ToastEntry(title: title, message: message, tone: tone, duration: duration))
    }
}