import SwiftUI

// MARK: - PulseSkeleton

/// Shimmer loading placeholder with GradientSkeleton styles.
public struct PulseSkeleton: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let shape: SkeletonShape
    let width: CGFloat?
    let height: CGFloat
    let shimmer: Bool
    let baseColor: Color?
    let highlightColor: Color?

    @State private var phase: CGFloat = -1

    public init(
        shape: SkeletonShape = .rectangle,
        width: CGFloat? = nil,
        height: CGFloat = 16,
        shimmer: Bool = true,
        baseColor: Color? = nil,
        highlightColor: Color? = nil
    ) {
        self.shape = shape
        self.width = width
        self.height = height
        self.shimmer = shimmer
        self.baseColor = baseColor
        self.highlightColor = highlightColor
    }

    public var body: some View {
        shapeView
            .overlay(shimmerOverlay)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .onAppear {
                guard shimmer && !reduceMotion else { return }
                withAnimation(theme.motion.springGentle.repeatForever(autoreverses: true)) {
                    phase = 1.5
                }
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var shapeView: some View {
        switch shape {
        case .rectangle:
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(baseColor ?? theme.colors.backgroundTertiary.opacity(0.6))
        case .circle:
            Circle()
                .fill(baseColor ?? theme.colors.backgroundTertiary.opacity(0.6))
        case .rounded:
            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                .fill(baseColor ?? theme.colors.backgroundTertiary.opacity(0.6))
        }
    }

    private var clippingShape: AnyShape {
        switch shape {
        case .rectangle:
            AnyShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        case .circle:
            AnyShape(Circle())
        case .rounded:
            AnyShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
        }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if shimmer && !reduceMotion {
            GeometryReader { geo in
                LinearGradient(
                    colors: [
                        .clear,
                        (highlightColor ?? theme.colors.foreground.opacity(0.08)),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geo.size.width * 0.7)
                .offset(x: phase * geo.size.width * 1.2)
            }
            .clipShape(clippingShape)
            .blendMode(.plusLighter)
        }
    }
}

// MARK: - Shapes

public enum SkeletonShape: Sendable {
    case rectangle
    case circle
    case rounded
}

// MARK: - Skeleton Containers

public struct PulseSkeletonText: View {
    @Environment(\.pulseTheme) private var theme

    let lines: Int
    let spacing: CGFloat

    public init(lines: Int = 3, spacing: CGFloat = 8) {
        self.lines = lines
        self.spacing = spacing
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<lines, id: \.self) { index in
                PulseSkeleton(height: 14)
                    .frame(width: index == lines - 1 ? 0.6 : 1.0)
            }
        }
        .accessibilityLabel("Loading")
    }
}

public struct PulseSkeletonCard: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                PulseSkeleton(shape: .circle, width: 44, height: 44)
                VStack(alignment: .leading, spacing: 6) {
                    PulseSkeleton(width: 120, height: 14)
                    PulseSkeleton(width: 80, height: 10)
                }
            }
            PulseSkeleton(height: 10)
            PulseSkeleton(width: 200, height: 10)
            PulseSkeleton(width: 170, height: 10)
            HStack {
                PulseSkeleton(shape: .rounded, width: 80, height: 32)
                Spacer()
                PulseSkeleton(shape: .rounded, width: 60, height: 32)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.clear.background(.ultraThinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading content")
    }
}