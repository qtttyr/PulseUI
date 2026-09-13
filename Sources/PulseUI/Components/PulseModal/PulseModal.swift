import SwiftUI

// MARK: - PulseModal

/// Premium dialog/modal presentation with scrim backdrop, animations, and accessibility.
@available(iOS 26.0, *)
public struct PulseModal<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var isPresented: Bool
    let style: ModalStyle
    let alignment: Alignment
    let scrimOpacity: Double
    let dismissOnTap: Bool
    let content: () -> Content

    @State private var isAnimatingIn = false

    public init(
        isPresented: Binding<Bool>,
        style: ModalStyle = .card,
        alignment: Alignment = .center,
        scrimOpacity: Double = 0.6,
        dismissOnTap: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.style = style
        self.alignment = alignment
        self.scrimOpacity = scrimOpacity
        self.dismissOnTap = dismissOnTap
        self.content = content
    }

    public var body: some View {
        if isPresented {
            ZStack {
                // Scrim
                theme.colors.scrim
                    .opacity(scrimOpacity * (isAnimatingIn ? 1 : 0))
                    .ignoresSafeArea()
                    .onTapGesture {
                        if dismissOnTap {
                            dismiss()
                        }
                    }
                    .accessibilityHidden(true)

                content()
                    .padding(theme.spacing.xl)
                    .frame(
                        maxWidth: style == .card ? 400 : .infinity,
                        maxHeight: .infinity,
                        alignment: alignment
                    )
                    .background(backgroundView)
                    .overlay(overlayView)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.xxl, style: .continuous))
                    .shadow(color: theme.colors.foreground.opacity(0.16), radius: 32, y: 16)
                    .padding(theme.spacing.lg)
                    .scaleEffect(isAnimatingIn ? 1 : 0.9)
                    .opacity(isAnimatingIn ? 1 : 0)
                    .offset(y: isAnimatingIn ? 0 : 18)
                    .blur(radius: isAnimatingIn ? 0 : 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(reduceMotion ? .none : theme.motion.springBouncy) {
                    isAnimatingIn = true
                }
            }
            .accessibilityAddTraits(.isModal)
        }
    }

    private func dismiss() {
        withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
            isAnimatingIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.2)) {
            isPresented = false
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .card:
            theme.colors.card
        case .glass:
            Color.clear.pulseGlass(.regular, cornerRadius: theme.radius.xxl)
                .overlay(theme.colors.glassFill)
        case .sheet:
            theme.colors.surfaceElevated
        case .transparent:
            Color.clear
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .card, .sheet:
            RoundedRectangle(cornerRadius: theme.radius.xxl, style: .continuous)
                .strokeBorder(theme.colors.border.opacity(0.3), lineWidth: 1)
        case .glass:
            RoundedRectangle(cornerRadius: theme.radius.xxl, style: .continuous)
                .strokeBorder(theme.colors.glassStroke, lineWidth: 0.5)
        default:
            EmptyView()
        }
    }
}

// MARK: - Types

public enum ModalStyle: Sendable {
    case card
    case glass
    case sheet
    case transparent
}

// MARK: - Convenience Builder

public extension View {
    /// Presents a PulseModal overlay.
    @ViewBuilder
    func pulseModal<Content: View>(
        isPresented: Binding<Bool>,
        style: ModalStyle = .card,
        alignment: Alignment = .center,
        dismissOnTap: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay {
            PulseModal(
                isPresented: isPresented,
                style: style,
                alignment: alignment,
                dismissOnTap: dismissOnTap,
                content: content
            )
        }
    }
}