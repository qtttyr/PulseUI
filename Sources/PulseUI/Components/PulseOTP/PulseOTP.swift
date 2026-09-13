import SwiftUI

// MARK: - PulseOTP

/// OTP input field with auto-advance, paste support, and completion callback.
public struct PulseOTP: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isFieldFocused: Bool

    let length: Int
    @Binding var code: String
    let style: OTPFieldStyle
    let onCompleted: ((String) -> Void)?

    @State private var fieldContent: String = ""
    @State private var focusedIndex: Int = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var hasAppeared = false

    public init(
        length: Int = 6,
        code: Binding<String>,
        style: OTPFieldStyle = .round,
        onCompleted: ((String) -> Void)? = nil
    ) {
        self.length = max(1, length)
        self._code = code
        self.style = style
        self.onCompleted = onCompleted
    }

    public var body: some View {
        ZStack {
            codes
                .allowsHitTesting(false)

            TextField("", text: $fieldContent)
                .focused($isFieldFocused)
                #if os(iOS)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                #endif
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .onChange(of: fieldContent) { _, newValue in
                    handleInput(newValue)
                }
                .onAppear {
                    isFieldFocused = true
                    guard !reduceMotion else { hasAppeared = true; return }
                    withAnimation(theme.motion.springSnappy) {
                        hasAppeared = true
                    }
                }
                .accessibilityLabel("One time password, \(length) digits")
                .accessibilityValue(code.isEmpty ? "Empty" : String(repeating: "•", count: code.count))
                .accessibilityHint("Enter \(length) digit code")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFieldFocused = true
        }
    }

    private var codes: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(0..<length, id: \.self) { index in
                codeBox(index)
                    .opacity(hasAppeared ? 1 : 0)
                    .scaleEffect(hasAppeared ? 1 : 0.7)
                    .offset(y: hasAppeared ? 0 : 10)
                    .animation(
                        reduceMotion ? .none : theme.motion.springSnappy.delay(Double(index) * 0.045),
                        value: hasAppeared
                    )
            }
        }
        .offset(x: shakeOffset)
    }

    @ViewBuilder
    private func codeBox(_ index: Int) -> some View {
        let isActive = index == focusedIndex
        let char = safeCharacter(at: index)
        let hasChar = char != nil

        ZStack {
            if isActive {
                shape
                    .fill(theme.colors.accent.opacity(0.10))
                    .frame(width: boxWidth + 10, height: boxHeight + 10)
                    .blur(radius: 14)
                    .shadow(color: theme.colors.accent.opacity(0.35), radius: 10)
            }

            shape
                .fill(fillColor(isActive: isActive, hasChar: hasChar))
                .frame(width: boxWidth, height: boxHeight)

            shape
                .stroke(borderColor(isActive: isActive, hasChar: hasChar), lineWidth: isActive ? 2 : 1)

            if let char {
                Text(String(char))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(theme.colors.foreground)
                    .monospacedDigit()
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            } else if isActive {
                Rectangle()
                    .fill(theme.colors.accent)
                    .frame(width: 2, height: 24)
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? .none : theme.motion.spring, value: focusedIndex)
        .animation(reduceMotion ? .none : theme.motion.springSnappy, value: code)
    }

    private var shape: AnyShape {
        switch style {
        case .round:
            return AnyShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        case .square:
            return AnyShape(RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous))
        case .underlined:
            return AnyShape(RoundedRectangle(cornerRadius: theme.radius.xs, style: .continuous))
        }
    }

    private var boxWidth: CGFloat { 47 }
    private var boxHeight: CGFloat { 56 }

    private func fillColor(isActive: Bool, hasChar: Bool) -> Color {
        if isActive { return theme.colors.accent.opacity(0.06) }
        return theme.colors.backgroundSecondary
    }

    private func borderColor(isActive: Bool, hasChar: Bool) -> Color {
        if isActive { return theme.colors.accent }
        if hasChar { return theme.colors.borderStrong }
        return theme.colors.border
    }

    private func safeCharacter(at index: Int) -> Character? {
        guard index < code.count else { return nil }
        return code[code.index(code.startIndex, offsetBy: index)]
    }

    private func handleInput(_ newValue: String) {
        if newValue.contains(where: { !$0.isNumber }) {
            fieldContent = ""
            PulseHaptic.impact(.soft)
            shake()
            return
        }

        let digits = newValue.filter { $0.isNumber }

        if digits.count <= length {
            code = String(digits)
            focusedIndex = max(digits.count - 1, 0)
        } else {
            code = String(digits.prefix(length))
            fieldContent = code
        }

        PulseHaptic.selection()

        if code.count >= length {
            isFieldFocused = false
            PulseHaptic.notification(.success)
            onCompleted?(code)
        }

        if digits.count > fieldContent.count && fieldContent.count == length {
            isFieldFocused = false
        }
    }

    private func shake() {
        guard !reduceMotion else { return }
        Task { @MainActor in
            for offset: CGFloat in [-7, 7, -5, 5, -2, 0] {
                withAnimation(.spring(response: 0.12, dampingFraction: 0.6)) {
                    shakeOffset = offset
                }
                try? await Task.sleep(nanoseconds: 40_000_000)
            }
        }
    }
}

// MARK: - Styles

public enum OTPFieldStyle: Sendable {
    case round
    case square
    case underlined
}