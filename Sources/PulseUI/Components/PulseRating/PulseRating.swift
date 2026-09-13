import SwiftUI

// MARK: - PulseRating

/// Star/heart rating with haptics, animations, and configurable symbols.
public struct PulseRating: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let count: Int
    @Binding var rating: Int
    let symbol: RatingSymbol
    let tint: Color?
    let size: CGFloat
    let isReadOnly: Bool
    let showsValue: Bool

    public init(
        count: Int = 5,
        rating: Binding<Int>,
        symbol: RatingSymbol = .star,
        tint: Color? = nil,
        size: CGFloat = 24,
        isReadOnly: Bool = false,
        showsValue: Bool = false
    ) {
        self.count = max(1, count)
        self._rating = rating
        self.symbol = symbol
        self.tint = tint
        self.size = size
        self.isReadOnly = isReadOnly
        self.showsValue = showsValue
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(1...count, id: \.self) { index in
                symbolView(for: index)
            }

            if showsValue {
                Text("\(rating)/\(count)")
                    .font(theme.typography.caption.font)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.foregroundSecondary)
                    .padding(.leading, 4)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) out of \(count)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: setRating(rating + 1)
            case .decrement: setRating(rating - 1)
            @unknown default: break
            }
        }
    }

    @ViewBuilder
    private func symbolView(for index: Int) -> some View {
        let filled = index <= rating

        Button {
            if !isReadOnly {
                setRating(index)
            }
        } label: {
            symbolImage(filled: filled, index: index)
        }
        .buttonStyle(.plain)
        .disabled(isReadOnly)
        .animation(reduceMotion ? .none : theme.motion.springBouncy, value: rating)
        .accessibilityHidden(isReadOnly ? false : true)
        .accessibilityLabel("\(symbol.label) \(index)")
        .accessibilityAddTraits(index <= rating ? .isSelected : [])
    }

    @ViewBuilder
    private func symbolImage(filled: Bool, index: Int) -> some View {
        let image = Image(systemName: symbol.symbolName(filled: filled))
            .font(.system(size: size))
            .foregroundStyle(filled ? symbolColor : theme.colors.foregroundTertiary.opacity(0.4))

        if reduceMotion {
            image
        } else {
            image
                .symbolEffect(.bounce, options: .nonRepeating, value: filled)
        }
    }

    private func setRating(_ newValue: Int) {
        guard !isReadOnly else { return }
        withAnimation(reduceMotion ? .none : theme.motion.springBouncy) {
            rating = min(max(newValue, 0), count)
        }
        PulseHaptic.impact(.light)
        if rating >= count, count > 1 {
            PulseHaptic.notification(.success)
        }
    }

    private var symbolColor: Color {
        tint ?? (symbol == .heart ? theme.colors.error : theme.colors.warning)
    }
}

// MARK: - Symbols

public enum RatingSymbol: Sendable {
    case star
    case heart
    case bolt
    case circle

    func symbolName(filled: Bool) -> String {
        switch self {
        case .star: return filled ? "star.fill" : "star"
        case .heart: return filled ? "heart.fill" : "heart"
        case .bolt: return filled ? "bolt.fill" : "bolt"
        case .circle: return filled ? "circle.fill" : "circle"
        }
    }

    var label: String {
        switch self {
        case .star: return "star"
        case .heart: return "heart"
        case .bolt: return "bolt"
        case .circle: return "circle"
        }
    }
}