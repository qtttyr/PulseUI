import SwiftUI

// MARK: - PulseForm

/// A consistent form shell with validation, submit feedback, and native focus behavior.
public struct PulseForm<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    private let title: String?
    private let validationMessage: String?
    private let isValid: Bool
    private let isSubmitting: Bool
    private let submitTitle: String
    private let submit: () -> Void
    private let content: () -> Content

    public init(
        _ title: String? = nil,
        isValid: Bool = true,
        validationMessage: String? = nil,
        isSubmitting: Bool = false,
        submitTitle: String = "Continue",
        submit: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isValid = isValid
        self.validationMessage = validationMessage
        self.isSubmitting = isSubmitting
        self.submitTitle = submitTitle
        self.submit = submit
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            if let title {
                Text(title)
                    .font(theme.typography.title2.font)
                    .foregroundStyle(theme.colors.foreground)
            }
            content()
            if let validationMessage, !isValid {
                Label(validationMessage, systemImage: "exclamationmark.circle")
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.error)
                    .accessibilityLabel("Form error: \(validationMessage)")
            }
            PulseButton(.primary, size: .lg, isLoading: isSubmitting, action: submit) {
                Text(submitTitle)
            }
            .disabled(!isValid || isSubmitting)
            .frame(maxWidth: .infinity)
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.card)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .stroke(theme.colors.border.opacity(0.75), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title ?? "Form")
    }
}
