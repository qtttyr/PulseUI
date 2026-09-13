import SwiftUI

// MARK: - PulseSheet

/// Premium bottom sheet with drag gestures, detents, and glass styling.
/// Wraps SwiftUI's native sheet with Pulse UI theming and anchored drag indicator.
@available(iOS 26.0, *)
public struct PulseSheet<Content: View, Item: Identifiable>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @Binding var item: Item?
    let style: SheetStyle
    let backgroundEffect: SheetBackgroundEffect
    let detents: Set<PresentationDetent>
    let dragIndicator: Bool
    let showsCloseButton: Bool
    let content: (Item) -> Content

    public init(
        item: Binding<Item?>,
        style: SheetStyle = .default,
        backgroundEffect: SheetBackgroundEffect = .automatic,
        detents: Set<PresentationDetent> = [.large],
        dragIndicator: Bool = true,
        showsCloseButton: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.style = style
        self.backgroundEffect = backgroundEffect
        self.detents = detents
        self.dragIndicator = dragIndicator
        self.showsCloseButton = showsCloseButton
        self.content = content
    }

    public var body: some View {
        if let item {
            content(item)
                .presentationDetents(detents)
                .presentationBackground(backgroundStyle)
                .presentationCornerRadius(theme.radius.xxl)
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .presentationDragIndicator(dragIndicator ? .visible : .hidden)
                .overlay(alignment: .topTrailing) {
                    if showsCloseButton {
                        Button {
                            dismiss()
                            self.item = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.colors.foregroundSecondary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(theme.colors.backgroundTertiary.opacity(0.8))
                                )
                                .padding(.trailing, theme.spacing.lg)
                                .padding(.top, theme.spacing.sm)
                        }
                        .buttonStyle(PulseIconButtonStyle())
                        .accessibilityLabel("Close")
                    }
                }
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .default:
            return AnyShapeStyle(
                theme.colors.surfaceElevated
            )
        case .glass:
            return AnyShapeStyle(.regularMaterial)
        }
    }
}

// MARK: - Convenience: Non-item Variant

@available(iOS 26.0, *)
public struct PulseSheetView<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @Binding var isPresented: Bool
    let style: SheetStyle
    let detents: Set<PresentationDetent>
    let dragIndicator: Bool
    let showsCloseButton: Bool
    let content: () -> Content

    public init(
        isPresented: Binding<Bool>,
        style: SheetStyle = .default,
        detents: Set<PresentationDetent> = [.large],
        dragIndicator: Bool = true,
        showsCloseButton: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.style = style
        self.detents = detents
        self.dragIndicator = dragIndicator
        self.showsCloseButton = showsCloseButton
        self.content = content
    }

    public var body: some View {
        content()
            .presentationDetents(detents)
            .presentationBackground(
                style == .glass
                    ? AnyShapeStyle(.regularMaterial)
                    : AnyShapeStyle(theme.colors.surfaceElevated)
            )
            .presentationCornerRadius(theme.radius.xxl)
            .presentationDragIndicator(dragIndicator ? .visible : .hidden)
            .overlay(alignment: .topTrailing) {
                if showsCloseButton {
                    Button {
                        isPresented = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.foregroundSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(theme.colors.backgroundTertiary.opacity(0.8))
                            )
                            .padding(.trailing, theme.spacing.lg)
                            .padding(.top, theme.spacing.sm)
                    }
                    .buttonStyle(PulseIconButtonStyle())
                    .accessibilityLabel("Close")
                }
            }
    }
}

// MARK: - Types

public enum SheetStyle: Sendable {
    case `default`
    case glass
}

public enum SheetBackgroundEffect: Sendable {
    case automatic
    case solid
    case material
}