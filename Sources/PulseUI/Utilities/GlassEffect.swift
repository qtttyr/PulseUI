import SwiftUI

// MARK: - Pulse Glass (native Liquid Glass, iOS/macOS/visionOS 26+)

/// Liquid Glass variants for `pulseGlass`.
public enum PulseGlassStyle: Sendable {
    case regular
    case clear
    case interactive
    case clearInteractive
}

extension PulseGlassStyle {
    var glassValue: Glass {
        switch self {
        case .regular: .regular
        case .clear: .clear
        case .interactive: .regular.interactive()
        case .clearInteractive: .clear.interactive()
        }
    }
}

extension View {
    /// Native Liquid Glass behind a view.
    ///
    /// ```swift
    /// Button("Continue") { }
    ///     .pulseGlass(.regular, cornerRadius: 16)
    /// Button(...) { }
    ///     .pulseGlass(.clear, in: Capsule(), tint: .accent)
    /// ```
    public func pulseGlass(
        _ style: PulseGlassStyle = .regular,
        in shape: some Shape = Capsule(),
        tint: Color? = nil
    ) -> some View {
        background { Color.clear.glassEffect(glass(style, tint: tint), in: shape) }
    }

    /// Liquid Glass in a continuous rounded rectangle with a corner radius.
    @ViewBuilder
    public func pulseGlass(
        _ style: PulseGlassStyle = .regular,
        cornerRadius: CGFloat,
        tint: Color? = nil
    ) -> some View {
        background {
            Color.clear.glassEffect(
                glass(style, tint: tint),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        }
    }

    /// Liquid Glass as a capsule (chips, pill buttons, floating bars).
    public func pulseGlassCapsule(
        _ style: PulseGlassStyle = .regular,
        tint: Color? = nil
    ) -> some View {
        pulseGlass(style, in: Capsule(), tint: tint)
    }

    private func glass(_ style: PulseGlassStyle, tint: Color?) -> Glass {
        guard let tint else { return style.glassValue }
        return style.glassValue.tint(tint)
    }
}

// MARK: - Unified Glass Container

/// Groups Liquid Glass surfaces so they sample one backdrop and can
/// morph into one another (functional layer: toolbars, control strips).
public struct PulseGlassContainer<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        GlassEffectContainer(spacing: spacing) { content }
    }
}