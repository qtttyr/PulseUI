import SwiftUI

// ============================================================
// MARK: - Pulse Prestige Motion
// Shared premium motion primitives: spring entrances, breathing
// glows and a diagonal specular sheen. Respects Reduce Motion.
// ============================================================

// MARK: - Entrance

/// Spring entrance: fade + scale + rise.
public struct PulseEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.pulseReduceMotion) private var reduceMotion

    let delay: Double
    let scale: CGFloat
    let offsetY: CGFloat

    @State private var shown = false

    public func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown ? 1 : scale)
            .offset(y: shown ? 0 : offsetY)
            .onAppear {
                guard !shown else { return }
                if accessibilityReduceMotion || reduceMotion {
                    shown = true
                } else {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(delay)) {
                        shown = true
                    }
                }
            }
    }
}

public extension View {
    /// Spring entrance: fade + scale + rise.
    func pulseEntrance(delay: Double = 0, scale: CGFloat = 0.96, offsetY: CGFloat = 10) -> some View {
        modifier(PulseEntrance(delay: delay, scale: scale, offsetY: offsetY))
    }
}

// MARK: - Glow

/// Ambient breathing glow around any shape.
public struct PulseGlow: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.pulseReduceMotion) private var reduceMotion

    let color: Color
    let radius: CGFloat
    let breathes: Bool

    @State private var breathing = false

    public func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: (breathes && breathing ? radius + 14 : radius), y: 0)
            .onAppear {
                guard breathes, !accessibilityReduceMotion, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
    }
}

public extension View {
    /// Ambient glow. Pass `breathes: true` for a soft living pulse.
    func pulseGlow(color: Color, radius: CGFloat = 6, breathes: Bool = false) -> some View {
        modifier(PulseGlow(color: color, radius: radius, breathes: breathes))
    }
}

// MARK: - Sheen

/// A diagonal specular highlight that sweeps across a gradient surface.
/// `repeats` loops the sweep (like the web kit's shine); otherwise it
/// runs once shortly after the view appears.
public struct PulseSheenView: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.pulseReduceMotion) private var reduceMotion

    let cornerRadius: CGFloat
    var repeats: Bool = false

    @State private var isAnimating = false

    public init(cornerRadius: CGFloat, repeats: Bool = false) {
        self.cornerRadius = cornerRadius
        self.repeats = repeats
    }

    public var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.5), .clear, .white.opacity(0.2), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: w * 0.45)
                .blur(radius: 2)
                .rotationEffect(.degrees(-14))
                .offset(x: isAnimating ? w * 1.7 : -w * 0.9, y: isAnimating ? h * 0.5 : -h * 0.35)
                .blendMode(.overlay)
            }
            .frame(width: w, height: h)
            .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .allowsHitTesting(false)
        .onAppear {
            guard !accessibilityReduceMotion, !reduceMotion else { return }
            if repeats {
                withAnimation(.linear(duration: 3.6).repeatForever(autoreverses: false).delay(0.5)) {
                    isAnimating = true
                }
            } else {
                withAnimation(.linear(duration: 1.3).delay(0.3)) {
                    isAnimating = true
                }
            }
        }
    }
}