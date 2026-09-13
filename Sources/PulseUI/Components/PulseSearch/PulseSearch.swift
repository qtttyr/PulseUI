import SwiftUI

// MARK: - PulseSearch

/// Premium search bar with animated clear button, glass option, and live results.
public struct PulseSearch: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isFocused: Bool

    @Binding var text: String
    let prompt: String
    let style: SearchStyle
    let showsClearButton: Bool
    let onSearch: (() -> Void)?
    let onSubmit: (() -> Void)?

    public init(
        text: Binding<String>,
        prompt: String = "Search",
        style: SearchStyle = .filled,
        showsClearButton: Bool = true,
        onSearch: (() -> Void)? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.prompt = prompt
        self.style = style
        self.showsClearButton = showsClearButton
        self.onSearch = onSearch
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isFocused || !text.isEmpty ? theme.colors.accent : theme.colors.foregroundTertiary)
                .accessibilityHidden(true)

            TextField(prompt, text: $text)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.foreground)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
                .onChange(of: text) { _, _ in
                    onSearch?()
                }

            if showsClearButton && !text.isEmpty {
                Button {
                    withAnimation(reduceMotion ? .none : theme.motion.springSnappy) {
                        text = ""
                    }
                    PulseHaptic.selection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(theme.colors.foregroundTertiary)
                        .accessibilityLabel("Clear search")
                }
                .buttonStyle(PulseIconButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, 12)
        .background(backgroundView)
        .overlay(overlayView)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .animation(reduceMotion ? .none : theme.motion.springSnappy, value: text.isEmpty)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(prompt)
        .accessibilityValue(text)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled, .borderless:
            theme.colors.backgroundSecondary
        case .glass:
            Color.clear.pulseGlass(.regular, cornerRadius: theme.radius.lg)
                .overlay(theme.colors.glassFill)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
            .strokeBorder(
                isFocused ? theme.colors.accent : theme.colors.border,
                lineWidth: isFocused ? 1.5 : 1
            )
    }
}

// MARK: - Styles

public enum SearchStyle: Sendable {
    case filled
    case glass
    case borderless
}