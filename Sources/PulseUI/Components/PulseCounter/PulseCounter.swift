import SwiftUI

// MARK: - PulseCounter

/// Animated counter with eased number transitions and configurable formatting.
public struct PulseCounter: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let value: Int
    let font: Font
    let fontWeight: Font.Weight
    let foreground: Color?
    let dampingFraction: Double
    let format: (Int) -> String

    @State private var displayValue: Double = 0

    public init(
        value: Int,
        font: Font = .system(size: 44, weight: .bold, design: .rounded),
        fontWeight: Font.Weight = .bold,
        foreground: Color? = nil,
        dampingFraction: Double = 0.8,
        format: @escaping (Int) -> String = { "\($0)" }
    ) {
        self.value = value
        self.font = font
        self.fontWeight = fontWeight
        self.foreground = foreground
        self.dampingFraction = dampingFraction
        self.format = format
    }

    public var body: some View {
        Text(format(Int(displayValue)))
            .font(font)
            .fontWeight(fontWeight)
            .foregroundStyle(foreground ?? theme.colors.foreground)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8), value: displayValue)
            .onAppear {
                displayValue = Double(value)
            }
            .onChange(of: value) { _, newValue in
                guard !reduceMotion else {
                    displayValue = Double(newValue)
                    return
                }
                withAnimation(.spring(response: 0.4, dampingFraction: dampingFraction)) {
                    displayValue = Double(newValue)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(format(value))
    }
}

// MARK: - Money Counter

public struct PulseMoneyCounter: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let cents: Int
    let currencyCode: String
    let font: Font
    let fontWeight: Font.Weight

    @State private var displayCents: Int = 0

    public init(
        cents: Int,
        currencyCode: String = "USD",
        font: Font = .system(size: 44, weight: .bold, design: .rounded),
        fontWeight: Font.Weight = .bold
    ) {
        self.cents = cents
        self.currencyCode = currencyCode
        self.font = font
        self.fontWeight = fontWeight
    }

    public var body: some View {
        Text(formatted)
            .font(font)
            .fontWeight(fontWeight)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.85), value: displayCents)
            .onAppear {
                displayCents = cents
            }
            .onChange(of: cents) { _, newValue in
                guard !reduceMotion else {
                    displayCents = newValue
                    return
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    displayCents = newValue
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(formatted)
    }

    private var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(displayCents) / 100)) ?? "$0.00"
    }
}