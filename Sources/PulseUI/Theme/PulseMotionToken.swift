import SwiftUI

// MARK: - Motion Tokens

/// Animation curves and durations. Consistent motion language across all components.
public struct MotionTokens: Sendable {
    public let instant: Animation
    public let fast: Animation
    public let normal: Animation
    public let slow: Animation
    public let spring: Animation
    public let springBouncy: Animation
    public let springSnappy: Animation
    public let springGentle: Animation

    public let durationInstant: Double
    public let durationFast: Double
    public let durationNormal: Double
    public let durationSlow: Double

    public init(
        durationInstant: Double = 0.1,
        durationFast: Double = 0.2,
        durationNormal: Double = 0.3,
        durationSlow: Double = 0.5
    ) {
        self.durationInstant = durationInstant
        self.durationFast = durationFast
        self.durationNormal = durationNormal
        self.durationSlow = durationSlow
        self.instant = .easeInOut(duration: durationInstant)
        self.fast = .easeInOut(duration: durationFast)
        self.normal = .easeInOut(duration: durationNormal)
        self.slow = .easeInOut(duration: durationSlow)
        self.spring = .spring(response: 0.5, dampingFraction: 0.8)
        self.springBouncy = .spring(response: 0.6, dampingFraction: 0.6)
        self.springSnappy = .spring(response: 0.3, dampingFraction: 0.8)
        self.springGentle = .spring(response: 0.7, dampingFraction: 0.85)
    }

    public static let `default` = MotionTokens()
}
