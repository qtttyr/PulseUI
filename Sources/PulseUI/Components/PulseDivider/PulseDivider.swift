import SwiftUI

// MARK: - PulseDivider

/// Horizontal or vertical separator. Solid, dashed, or gradient. Optional label.
public struct PulseDivider: View {
    @Environment(\.pulseTheme) private var theme

    let style: DividerStyle
    let orientation: Orientation
    let thickness: CGFloat
    let label: String?

    public init(
        _ style: DividerStyle = .solid,
        orientation: Orientation = .horizontal,
        thickness: CGFloat = 1,
        label: String? = nil
    ) {
        self.style = style
        self.orientation = orientation
        self.thickness = thickness
        self.label = label
    }

    public var body: some View {
        if orientation == .horizontal {
            horizontalLine
        } else {
            lineView
        }
    }

    @ViewBuilder
    private var horizontalLine: some View {
        HStack(spacing: theme.spacing.md) {
            lineView
            if let label {
                Text(label.uppercased())
                    .font(theme.typography.overline.font)
                    .foregroundStyle(theme.colors.foregroundTertiary)
                    .tracking(1)
            }
            if label != nil {
                lineView
            }
        }
    }

    @ViewBuilder
    private var lineView: some View {
        switch style {
        case .solid:
            rectangle
        case .dashed:
            rectangle.mask(Rectangle().strokeBorder(
                style: StrokeStyle(lineWidth: thickness, lineCap: .round, dash: [6, 4]),
                antialiased: true
            ))
        case .dotted:
            rectangle.mask(Rectangle().strokeBorder(
                style: StrokeStyle(lineWidth: thickness, lineCap: .round, dash: [0.1, 6]),
                antialiased: true
            ))
        case .gradient:
            gradientView
        }
    }

    private var rectangle: some View {
        Rectangle()
            .fill(theme.colors.separator)
            .frame(width: orientation == .horizontal ? nil : thickness,
                   height: orientation == .horizontal ? thickness : nil)
    }

    @ViewBuilder
    private var gradientView: some View {
        if orientation == .horizontal {
            LinearGradient(
                colors: [.clear, theme.colors.borderStrong, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: thickness)
        } else {
            LinearGradient(
                colors: [.clear, theme.colors.borderStrong, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: thickness)
        }
    }
}

// MARK: - Types

public enum DividerStyle: Sendable {
    case solid
    case dashed
    case dotted
    case gradient
}

public enum DividerOrientation: Sendable {
    case horizontal
    case vertical
}

public typealias Orientation = DividerOrientation