import SwiftUI

// MARK: - Pulse Theme

/// The core theme engine for Pulse UI.
/// Inject via `.pulseTheme()` at app root. Every component reads from environment.
@Observable
public final class PulseTheme: Sendable {
    public let colors: ColorTokens
    public let spacing: SpacingTokens
    public let radius: RadiusTokens
    public let typography: TypographyTokens
    public let motion: MotionTokens
    public let elevation: ElevationTokens

    public init(
        colors: ColorTokens = .default,
        spacing: SpacingTokens = .default,
        radius: RadiusTokens = .default,
        typography: TypographyTokens = .default,
        motion: MotionTokens = .default,
        elevation: ElevationTokens = .default
    ) {
        self.colors = colors
        self.spacing = spacing
        self.radius = radius
        self.typography = typography
        self.motion = motion
        self.elevation = elevation
    }

    public static let `default` = PulseTheme()
}

// MARK: - Environment

private struct PulseThemeKey: EnvironmentKey {
    static let defaultValue = PulseTheme.default
}

public extension EnvironmentValues {
    var pulseTheme: PulseTheme {
        get { self[PulseThemeKey.self] }
        set { self[PulseThemeKey.self] = newValue }
    }
}

public extension View {
    /// Inject PulseTheme into the environment. Call at app root.
    func pulseTheme(_ theme: PulseTheme = .default) -> some View {
        environment(\.pulseTheme, theme)
    }
}
