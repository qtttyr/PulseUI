import SwiftUI

// MARK: - PulseInput

/// Premium text input with floating label, validation states, icons, and smooth animations.
public struct PulseInput: View {
    @Environment(\.pulseTheme) private var theme
    @FocusState private var isFocused: Bool

    let title: String
    @Binding var text: String
    let prompt: String?
    let validation: PulseValidationState
    let leadingIcon: AnyView?
    let trailingIcon: AnyView?
    let isSecure: Bool
    let axis: Axis

    @State private var isSecureVisible = false

    public init(
        _ title: String,
        text: Binding<String>,
        prompt: String? = nil,
        validation: PulseValidationState = .none,
        isSecure: Bool = false,
        axis: Axis = .vertical
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.validation = validation
        self.leadingIcon = nil
        self.trailingIcon = nil
        self.isSecure = isSecure
        self.axis = axis
    }

    public init<Leading: View, Trailing: View>(
        _ title: String,
        text: Binding<String>,
        prompt: String? = nil,
        validation: PulseValidationState = .none,
        @ViewBuilder leadingIcon: () -> Leading,
        @ViewBuilder trailingIcon: () -> Trailing,
        isSecure: Bool = false,
        axis: Axis = .vertical
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.validation = validation
        self.leadingIcon = AnyView(leadingIcon())
        self.trailingIcon = AnyView(trailingIcon())
        self.isSecure = isSecure
        self.axis = axis
    }

    public var body: some View {
        fieldContent
            .animation(theme.motion.spring, value: validation)
            .accessibilityLabel(title)
            .accessibilityValue(text)
            .accessibilityHint(prompt ?? "")
    }

    @ViewBuilder
    private var fieldContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.subheadline.font)
                .foregroundStyle(theme.colors.foregroundSecondary)
                .accessibilityHidden(true)

            HStack(spacing: theme.spacing.sm) {
                if let leadingIcon {
                    leadingIcon
                        .font(.body.weight(.regular))
                        .foregroundStyle(iconColor)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                }

                Group {
                    secureOrPlainField
                }
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.foreground)
                .focused($isFocused)
                #if canImport(UIKit)
                .textInputAutocapitalization(.never)
                #endif
                .autocorrectionDisabled()

                if isSecure {
                    Button {
                        withAnimation(theme.motion.springSnappy) {
                            isSecureVisible.toggle()
                        }
                        PulseHaptic.selection()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .font(.footnote)
                            .foregroundStyle(theme.colors.foregroundTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSecureVisible ? "Hide password" : "Show password")
                }

                if let trailingIcon {
                    trailingIcon
                        .font(.footnote)
                        .foregroundStyle(iconColor)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, 13)
            .background(backgroundView)
            .background(borderView)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
            .scaleEffect(isFocused ? 1.0 : 0.99)
            .animation(theme.motion.springSnappy, value: isFocused)

            if isFieldFloating {
                Text(title)
                    .font(theme.typography.overline.font)
                    .foregroundStyle(theme.colors.foregroundTertiary)
                    .transition(.opacity)
            }

            if case let .error(message) = validation {
                Label(message, systemImage: "exclamationmark.circle.fill")
                    .font(theme.typography.footnote.font)
                    .foregroundStyle(theme.colors.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Field

    @ViewBuilder
    private var secureOrPlainField: some View {
        if isSecure && !isSecureVisible {
            SecureField(prompt ?? "", text: $text)
        } else {
            TextField(prompt ?? "", text: $text, axis: axis == .vertical ? .vertical : .horizontal)
        }
    }

    private var isFieldFloating: Bool {
        if case .error = validation { return true }
        return false
    }

    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
            .fill(borderColor.opacity(isFocused ? 0.06 : 0))
    }

    @ViewBuilder
    private var borderView: some View {
        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
            .strokeBorder(borderColor, lineWidth: isFocused ? 1.5 : 1)
    }

    private var borderColor: Color {
        if isFocused {
            return theme.colors.accent
        }
        switch validation {
        case .error: return theme.colors.error
        default: return theme.colors.border
        }
    }

    private var iconColor: Color {
        if case .error = validation {
            return theme.colors.error
        }
        return isFocused ? theme.colors.accent : theme.colors.foregroundTertiary
    }
}

// MARK: - Validation

public enum PulseValidationState: Equatable, Sendable {
    case none
    case error(String)
}