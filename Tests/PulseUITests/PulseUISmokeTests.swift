import SwiftUI
import Testing
@testable import PulseUI

// MARK: - Theme tokens

@Suite("Theme tokens")
struct ThemeTokenTests {
    @Test("ColorTokens exposes core + gradient palettes")
    func colorTokensExposePalette() {
        let tokens = ColorTokens()
        #expect(tokens.background != .clear)
        #expect(tokens.gradientAccent.count >= 2)
        #expect(tokens.gradientPrimary.count >= 2)
    }

    @Test("MotionTokens expose animation language")
    func motionTokensExposeAnimationLanguage() {
        let m = MotionTokens()
        #expect(m.durationInstant == 0.1)
        #expect(m.durationNormal == 0.3)
        #expect(m.durationSlow == 0.5)
    }

    @Test("PulseTheme default injects defaults")
    func themeDefaults() {
        let theme = PulseTheme()
        #expect(theme.radius.md >= 6)
        #expect(theme.spacing.md > theme.spacing.sm)
    }

    @Test("Gradient opacity scales color array")
    func gradientOpacityHelper() {
        let colors: [Color] = [.red, .blue]
        let faded = colors.opacity(0.5)
        #expect(faded.count == 2)
    }
}

// MARK: - Motion helpers

@Suite("Motion helpers")
struct MotionHelperTests {
    @Test("pulseAnimation flattens to zero duration under reduce motion")
    func reduceMotionYieldsInstant() {
        let animated = MotionTokens.default.spring.pulseAnimation(reduceMotion: true)
        #expect(animatedID(for: animated).contains("duration: 0.0"))
    }

    @Test("pulseAnimation keeps spring when motion allowed")
    func fullMotionKeepsSpring() {
        let animated = MotionTokens.default.spring.pulseAnimation(reduceMotion: false)
        #expect(animatedID(for: animated).contains("FluidSpringAnimation"))
    }

    private func animatedID(for animation: Animation) -> String {
        String(describing: animation)
    }
}

// MARK: - Components

@Suite("Components", .serialized)
@MainActor
struct ComponentTests {
    @Test("Button variants construct")
    func buttonVariants() {
        let variants: [ButtonVariant] = [
            .primary, .secondary, .outline, .ghost, .link, .destructive, .glass, .gradient,
        ]
        let built = variants.map { PulseButton("Label", variant: $0, action: {}) }
        #expect(built.count == variants.count)
        _ = PulseButton(
            "Label",
            systemImage: "trash",
            variant: .gradient,
            iconPosition: .trailing,
            action: {}
        )
        _ = PulseButton(.primary, isLoading: true, action: {}) {
            Text("Loading")
        }
    }

    @Test("Button supports an explicit action")
    func buttonActionAPI() {
        _ = PulseButton("Continue", action: {})
    }

    @Test("Search supports live and submit callbacks")
    func searchCallbackAPI() {
        _ = PulseSearch(
            text: .constant(""),
            onSearch: {},
            onSubmit: {}
        )
    }

    @Test("Progress styles map to sizes")
    func circularSizes() {
        #expect(CircularSize.sm.dimension == 52)
        #expect(CircularSize.xl.dimension > CircularSize.lg.dimension)
    }

    @Test("Status colors cover semantic tones")
    func statusTones() {
        let color = ColorTokens().accent
        #expect(color != .clear)
    }

    @Test("Card, chip, and badge APIs preserve content and interaction call sites")
    func componentInteractionAPIs() {
        _ = PulseCard(.outlined, isInteractive: true, action: {}, accessibilityLabel: "Details") {
            Text("Details")
        }
        _ = PulseChip(
            "Selected",
            isSelected: true,
            accessibilityLabel: "Selected filter",
            onTap: {}
        )
        _ = PulseChip(
            isSelected: false,
            accessibilityLabel: "Custom filter",
            onTap: {}
        ) {
            Label("Custom", systemImage: "line.3.horizontal.decrease")
        }
        _ = PulseBadge(
            "Ready",
            tone: .success,
            accessibilityLabel: "Ready status"
        )
        _ = PulseBadge(
            .warning,
            accessibilityLabel: "Warning status"
        ) {
            Label("Warning", systemImage: "exclamationmark.triangle")
        }
        _ = PulseContentState(.loading) {
            Text("Loaded")
        }
        _ = PulseMetricCard(
            "Revenue",
            value: "$128K",
            delta: .positive("+12.4%"),
            points: [1, 2, 1.5, 3],
            action: {}
        )
        _ = PulseDataToolbar(
            query: .constant(""),
            filters: { Text("All") },
            sort: { Text("Newest") }
        )
    }
}