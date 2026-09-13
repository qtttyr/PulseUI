import SwiftUI

// MARK: - PulseCommandPalette

public struct PulseCommandAction: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let systemImage: String
    public let action: () -> Void

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        systemImage: String = "command",
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.action = action
    }
}

/// A keyboard-first command surface for navigation and power-user actions.
public struct PulseCommandPalette: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var isPresented: Bool
    private let title: String
    private let actions: [PulseCommandAction]

    @State private var query = ""
    @State private var selectedIndex = 0
    @FocusState private var searchFocused: Bool

    public init(
        isPresented: Binding<Bool>,
        title: String = "Search commands",
        actions: [PulseCommandAction]
    ) {
        self._isPresented = isPresented
        self.title = title
        self.actions = actions
    }

    public var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.28)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }

                palette
                    .frame(maxWidth: 560)
                    .padding(.horizontal, theme.spacing.lg)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .scale(scale: 0.96).combined(with: .opacity)
                    )
            }
            .zIndex(100)
            .onAppear { searchFocused = true }
            #if os(macOS)
            .onMoveCommand { direction in
                switch direction {
                case .down: selectedIndex = min(selectedIndex + 1, filteredActions.count - 1)
                case .up: selectedIndex = max(selectedIndex - 1, 0)
                default: break
                }
            }
            #endif
            .animation(reduceMotion ? .none : theme.motion.springSnappy, value: isPresented)
        }
    }

    private var filteredActions: [PulseCommandAction] {
        guard !query.isEmpty else { return actions }
        return actions.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || ($0.subtitle?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    private var palette: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.colors.foregroundTertiary)
                TextField(title, text: $query)
                    .textFieldStyle(.plain)
                    .font(theme.typography.body.font)
                    .focused($searchFocused)
                    .onSubmit { runSelected() }
                Button("Close", systemImage: "xmark") { dismiss() }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.colors.foregroundSecondary)
                    .keyboardShortcut(.escape)
            }
            .padding(theme.spacing.md)

            Divider()

            if filteredActions.isEmpty {
                ContentUnavailableView("No commands", systemImage: "magnifyingglass")
                    .frame(minHeight: 120)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(filteredActions.enumerated()), id: \.element.id) { index, item in
                            Button {
                                item.action()
                                dismiss()
                            } label: {
                                HStack(spacing: theme.spacing.md) {
                                    Image(systemName: item.systemImage)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .font(theme.typography.body.font)
                                        if let subtitle = item.subtitle {
                                            Text(subtitle)
                                                .font(theme.typography.caption.font)
                                                .foregroundStyle(theme.colors.foregroundSecondary)
                                        }
                                    }
                                    Spacer()
                                    if index == selectedIndex {
                                        Image(systemName: "return")
                                            .font(.caption)
                                            .foregroundStyle(theme.colors.foregroundTertiary)
                                    }
                                }
                                .foregroundStyle(theme.colors.foreground)
                                .padding(.horizontal, theme.spacing.md)
                                .padding(.vertical, 10)
                                .background(
                                    index == selectedIndex
                                        ? theme.colors.accent.opacity(0.14)
                                        : .clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(theme.spacing.sm)
                }
                .frame(maxHeight: 360)
            }
        }
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .stroke(theme.colors.border.opacity(0.8), lineWidth: 1)
        }
        .pulseGlass(cornerRadius: theme.radius.xl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }

    private func runSelected() {
        guard filteredActions.indices.contains(selectedIndex) else { return }
        filteredActions[selectedIndex].action()
        dismiss()
    }

    private func dismiss() {
        searchFocused = false
        isPresented = false
        query = ""
        selectedIndex = 0
    }
}
