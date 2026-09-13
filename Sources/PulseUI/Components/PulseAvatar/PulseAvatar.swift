import SwiftUI

// MARK: - PulseAvatar

/// User avatar with image, initials, status indicators, and ring styles.
public struct PulseAvatar<Ring: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let size: AvatarSize
    let status: PulseAvatarStatus
    let ring: Ring?

    @State private var isThinking = false

    public init(
        size: AvatarSize = .md,
        status: PulseAvatarStatus = .none,
        @ViewBuilder ring: () -> Ring = { EmptyView() }
    ) {
        self.size = size
        self.status = status
        self.ring = ring()
    }

    public var body: some View {
        Color.clear
            .frame(width: size.dimension, height: size.dimension)
            .overlay(ringContent)
            .clipShape(Circle())
            .overlay(statusOverlay)
            .animation(reduceMotion ? .none : theme.motion.spring, value: status)
    }

    @ViewBuilder
    private var ringContent: some View {
        if let ring {
            ring
                .frame(width: size.dimension + 4, height: size.dimension + 4)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        switch status {
        case .none:
            EmptyView()
        case .online, .offline:
            Circle()
                .fill(statusColor)
                .frame(width: size.statusDimension, height: size.statusDimension)
                .overlay(
                    Circle()
                        .stroke(theme.colors.card, lineWidth: 2)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: -size.statusOffset, y: -size.statusOffset)
        case .busy:
            Circle()
                .fill(statusColor)
                .frame(width: size.statusDimension, height: size.statusDimension)
                .overlay(
                    Circle()
                        .stroke(theme.colors.card, lineWidth: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white)
                        .frame(width: size.statusDimension * 0.5 - 2, height: 2)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: -size.statusOffset, y: -size.statusOffset)
        case .thinking:
            Circle()
                .fill(statusColor)
                .frame(width: size.statusDimension, height: size.statusDimension)
                .overlay(
                    Circle()
                        .stroke(theme.colors.card, lineWidth: 2)
                )
                .scaleEffect(isThinking ? 0.85 : 1)
                .opacity(isThinking ? 0.6 : 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: -size.statusOffset, y: -size.statusOffset)
                .onAppear {
                    guard status == .thinking, !reduceMotion else { return }
                    withAnimation(theme.motion.normal.repeatForever(autoreverses: true)) {
                        isThinking = true
                    }
                }
        }
    }

    private var statusColor: Color {
        switch status {
        case .online: return theme.colors.success
        case .busy: return theme.colors.error
        case .offline: return theme.colors.foregroundTertiary
        case .thinking: return theme.colors.accent
        case .none: return .clear
        }
    }
}

// MARK: - Image Avatar

public struct PulseAvatarImage: View {
    @Environment(\.pulseTheme) private var theme

    let image: Image?
    let initials: String?
    let size: AvatarSize

    public init(image: Image? = nil, initials: String? = nil, size: AvatarSize = .md) {
        self.image = image
        self.initials = initials
        self.size = size
    }

    public var body: some View {
        ZStack {
            content
        }
        .frame(width: size.dimension, height: size.dimension)
        .background(
            LinearGradient(colors: theme.colors.gradientAccent, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(Circle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(initials ?? "Avatar")
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let initials {
            Text(initials)
                .font(.system(size: size.dimension * 0.36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: size.dimension * 0.36, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Types

public enum PulseAvatarStatus: Sendable {
    case none
    case online
    case busy
    case offline
    case thinking
}

public enum AvatarSize: Sendable {
    case xs, sm, md, lg, xl, xxl

    var dimension: CGFloat {
        switch self {
        case .xs: return 24
        case .sm: return 32
        case .md: return 44
        case .lg: return 56
        case .xl: return 64
        case .xxl: return 88
        }
    }

    var statusDimension: CGFloat {
        switch self {
        case .xs: return 7
        case .sm: return 9
        case .md: return 12
        case .lg: return 15
        case .xl: return 17
        case .xxl: return 22
        }
    }

    var statusOffset: CGFloat {
        switch self {
        case .xs: return 2
        case .sm: return 3
        case .md: return 4
        case .lg: return 5
        case .xl: return 5
        case .xxl: return 6
        }
    }
}