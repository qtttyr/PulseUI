import SwiftUI

// MARK: - PulseContentState

/// Consistent loading, empty, error, and offline presentation for data-driven screens.
public struct PulseContentState<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let state: State
    let retry: (() -> Void)?
    let content: () -> Content

    public init(
        _ state: State,
        retry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.state = state
        self.retry = retry
        self.content = content
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                loadingView
            case .empty(let title, let message, let systemImage):
                unavailableView(title: title, message: message, systemImage: systemImage)
            case .error(let title, let message):
                errorView(title: title, message: message)
            case .offline(let title, let message):
                unavailableView(title: title, message: message, systemImage: "wifi.slash")
            case .loaded:
                content()
            }
        }
        .animation(reduceMotion ? .none : theme.motion.normal, value: state)
    }

    private var loadingView: some View {
        VStack(spacing: theme.spacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(theme.colors.accent)
            Text("Loading")
                .font(theme.typography.callout.font)
                .foregroundStyle(theme.colors.foregroundSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading")
    }

    private func unavailableView(title: String, message: String, systemImage: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }

    private func errorView(title: String, message: String) -> some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(theme.colors.error)
                .accessibilityHidden(true)
            Text(title)
                .font(theme.typography.headline.font)
                .foregroundStyle(theme.colors.foreground)
            Text(message)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.foregroundSecondary)
                .multilineTextAlignment(.center)
            if let retry {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.accent)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity, minHeight: 180)
        .accessibilityElement(children: .combine)
    }
}

public extension PulseContentState {
    enum State: Equatable, Sendable {
        case loading
        case loaded
        case empty(title: String = "Nothing here", message: String = "There is no content to show.", systemImage: String = "tray")
        case error(title: String = "Something went wrong", message: String = "Please try again.")
        case offline(title: String = "You are offline", message: String = "Check your connection and try again.")
    }
}
