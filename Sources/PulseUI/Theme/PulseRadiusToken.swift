import SwiftUI

// MARK: - Radius Tokens

/// Consistent corner radii. From none to full circle.
public struct RadiusTokens: Sendable {
    public let none: CGFloat
    public let xs: CGFloat
    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat
    public let xl: CGFloat
    public let xxl: CGFloat
    public let full: CGFloat

    public init(
        none: CGFloat = 0,
        xs: CGFloat = 4,
        sm: CGFloat = 6,
        md: CGFloat = 8,
        lg: CGFloat = 12,
        xl: CGFloat = 16,
        xxl: CGFloat = 20,
        full: CGFloat = 9999
    ) {
        self.none = none
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.full = full
    }

    public static let `default` = RadiusTokens()

    public func shape(for style: PulseRadiusStyle) -> AnyShape {
        switch style {
        case .none: AnyShape(Rectangle())
        case .xs: AnyShape(RoundedRectangle(cornerRadius: xs))
        case .sm: AnyShape(RoundedRectangle(cornerRadius: sm))
        case .md: AnyShape(RoundedRectangle(cornerRadius: md))
        case .lg: AnyShape(RoundedRectangle(cornerRadius: lg))
        case .xl: AnyShape(RoundedRectangle(cornerRadius: xl))
        case .xxl: AnyShape(RoundedRectangle(cornerRadius: xxl))
        case .pill: AnyShape(Capsule())
        case .circle: AnyShape(Circle())
        }
    }
}

public enum PulseRadiusStyle: Sendable {
    case none, xs, sm, md, lg, xl, xxl, pill, circle
}
