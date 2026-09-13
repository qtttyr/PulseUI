import SwiftUI

// MARK: - Elevation Tokens

/// Shadow and elevation levels. From flat to floating.
public struct ElevationTokens: Sendable {
    public let level0: ShadowStyle
    public let level1: ShadowStyle
    public let level2: ShadowStyle
    public let level3: ShadowStyle
    public let level4: ShadowStyle

    public init() {
        self.level0 = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
        self.level1 = ShadowStyle(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        self.level2 = ShadowStyle(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        self.level3 = ShadowStyle(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        self.level4 = ShadowStyle(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    public static let `default` = ElevationTokens()

    public struct ShadowStyle: Sendable {
        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat

        public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }
}

// MARK: - View Modifier

public struct PulseShadowModifier: ViewModifier {
    let shadow: ElevationTokens.ShadowStyle

    public func body(content: Content) -> some View {
        content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

public extension View {
    func pulseShadow(_ level: PulseShadowLevel) -> some View {
        modifier(PulseShadowModifier(shadow: level.shadow))
    }
}

public enum PulseShadowLevel: Sendable {
    case none, low, medium, high, floating

    var shadow: ElevationTokens.ShadowStyle {
        let tokens = ElevationTokens()
        switch self {
        case .none: return tokens.level0
        case .low: return tokens.level1
        case .medium: return tokens.level2
        case .high: return tokens.level3
        case .floating: return tokens.level4
        }
    }
}
