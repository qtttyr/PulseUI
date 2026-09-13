import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Haptic Feedback

public enum PulseHapticStyle: Sendable {
    case light, soft, medium, rigid, heavy
}

public enum PulseHapticNotification: Sendable {
    case success, warning, error
}

public enum PulseHaptic {
    public static func impact(_ style: PulseHapticStyle = .light) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: Self.uiStyle(for: style)).impactOccurred()
        #endif
    }

    public static func selection() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    public static func notification(_ type: PulseHapticNotification) {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(Self.uiType(for: type))
        #endif
    }

    #if canImport(UIKit)
    private static func uiStyle(for style: PulseHapticStyle) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch style {
        case .light: return .light
        case .soft: return .soft
        case .medium: return .medium
        case .rigid: return .rigid
        case .heavy: return .heavy
        }
    }

    private static func uiType(for type: PulseHapticNotification) -> UINotificationFeedbackGenerator.FeedbackType {
        switch type {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }
    #endif
}

// MARK: - Conditional View

public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Reduce Motion Aware Animation

public extension Animation {
    func pulseAnimation(reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0) : self
    }
}

// MARK: - Icon Button Press Style

/// Spring-down press for small icon buttons (close chips, dismiss controls).
public struct PulseIconButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.82 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Pulse Reduce Motion Environment

public struct PulseReduceMotion: EnvironmentKey {
    public static let defaultValue = false
}

public extension EnvironmentValues {
    var pulseReduceMotion: Bool {
        get { self[PulseReduceMotion.self] }
        set { self[PulseReduceMotion.self] = newValue }
    }
}