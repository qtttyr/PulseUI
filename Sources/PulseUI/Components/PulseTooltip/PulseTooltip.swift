import SwiftUI

// MARK: - PulseTooltip

/// Cross-platform tooltip that supports hover, long press, and VoiceOver context.
public struct PulseTooltip<Content: View, TooltipContent: View>: View {
    @Environment(\.pulseTheme) private var theme
    @State private var isPresented = false
    private let message: String
    private let content: () -> Content
    private let tooltipContent: () -> TooltipContent

    public init(
        _ message: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder tooltip: @escaping () -> TooltipContent
    ) {
        self.message = message
        self.content = content
        self.tooltipContent = tooltip
    }

    public var body: some View {
        content()
            .onLongPressGesture(minimumDuration: 0.35) {
                isPresented = true
            }
            .popover(isPresented: $isPresented) {
                tooltipContent()
                    .padding(theme.spacing.md)
                    .presentationCompactAdaptation(.popover)
            }
            .help(message)
            .accessibilityHint(message)
    }
}
