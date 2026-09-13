import SwiftUI
import PulseUI

// MARK: - Stage

struct DemoStage<Content: View>: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.galleryPreview) private var galleryPreview
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    theme.colors.accent.opacity(0.16),
                    theme.colors.accent.opacity(0.02),
                    .clear,
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 420
            )
            if !galleryPreview {
                Circle()
                    .fill(theme.colors.gradientSecondary.first ?? theme.colors.accent)
                    .opacity(0.22)
                    .frame(width: 180, height: 180)
                    .blur(radius: 60)
                    .offset(x: 90, y: 70)
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Scene factory

enum SceneFactory {
    @ViewBuilder
    static func scene(for slug: String) -> some View {
        switch slug {
        case "pulse-calendar": CalendarScene()
        case "pulse-form": FormScene()
        case "pulse-tooltip": TooltipScene()
        case "pulse-timeline": TimelineScene()
        case "pulse-kanban": KanbanScene()
        case "pulse-spotlight": SpotlightScene()
        case "pulse-table": TableScene()
        case "pulse-chart": ChartScene()
        case "pulse-command-palette": CommandPaletteScene()
        case "pulse-segmented-control": SegmentedControlScene()
        case "pulse-content-state": ContentStateScene()
        case "pulse-metric-card": MetricCardScene()
        case "pulse-data-toolbar": DataToolbarScene()
        case "pulse-button": ButtonScene()
        case "pulse-chip": ChipScene()
        case "pulse-badge": BadgeScene()
        case "pulse-avatar": AvatarScene()
        case "pulse-toggle": ToggleScene()
        case "pulse-input": InputScene()
        case "pulse-slider": SliderScene()
        case "pulse-stepper": StepperScene()
        case "pulse-otp": OTPScene()
        case "pulse-rating": RatingScene()
        case "pulse-picker": PickerScene()
        case "pulse-progress": ProgressScene()
        case "pulse-counter": CounterScene()
        case "pulse-skeleton": SkeletonScene()
        case "pulse-card": CardScene()
        case "pulse-divider": DividerScene()
        case "pulse-label": LabelScene()
        case "pulse-list": ListScene()
        case "pulse-navigation-bar": NavigationBarScene()
        case "pulse-tab-bar": TabBarScene()
        case "pulse-sidebar": SidebarScene()
        case "pulse-accordion": AccordionScene()
        case "pulse-carousel": CarouselScene()
        case "pulse-empty-state": EmptyStateScene()
        case "pulse-search": SearchScene()
        case "pulse-date-range": DateRangeScene()
        case "pulse-sheet": SheetScene()
        case "pulse-modal": ModalScene()
        case "pulse-alert": AlertScene()
        case "pulse-toast": ToastScene()
        default: EmptyView()
        }
    }
}

// MARK: - Data foundation

struct CalendarScene: View {
    @State private var date = Date()

    var body: some View {
        PulseCalendar(selection: $date)
            .frame(maxWidth: 340)
    }
}

struct FormScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var email = ""
    @State private var submitting = false

    var body: some View {
        PulseForm(
            "Join the workspace",
            isValid: email.contains("@"),
            validationMessage: "Enter a valid email address.",
            isSubmitting: submitting,
            submit: {
                submitting = true
                Task {
                    try? await Task.sleep(for: .milliseconds(800))
                    submitting = false
                }
            }
        ) {
            PulseInput("Email", text: $email, prompt: "you@example.com")
        }
        .frame(maxWidth: 340)
    }
}

struct TooltipScene: View {
    var body: some View {
        PulseTooltip("Shows contextual help") {
            Image(systemName: "info.circle")
                .font(.title2)
        } tooltip: {
            Text("Long press or hover for more context.")
        }
    }
}

struct TimelineScene: View {
    var body: some View {
        PulseTimeline([
            PulseTimelineEvent(id: "1", title: "Published", detail: "The release is live.", date: "Now", systemImage: "checkmark"),
            PulseTimelineEvent(id: "2", title: "Reviewed", detail: "Design QA approved.", date: "2h", systemImage: "eye"),
            PulseTimelineEvent(id: "3", title: "Created", detail: "Workspace initialized.", date: "Yesterday", systemImage: "plus"),
        ])
        .frame(maxWidth: 360)
        .padding(.horizontal, 12)
    }
}

struct KanbanScene: View {
    var body: some View {
        PulseKanban([
            PulseKanbanColumn(id: "todo", title: "Todo", cards: [
                PulseKanbanCard(id: "tokens", title: "Token audit", detail: "Design"),
                PulseKanbanCard(id: "docs", title: "Write docs", detail: "Content"),
            ]),
            PulseKanbanColumn(id: "doing", title: "In progress", cards: [
                PulseKanbanCard(id: "chart", title: "Chart polish", detail: "Engineering"),
            ]),
        ])
        .frame(maxWidth: 560)
    }
}

struct SpotlightScene: View {
    var body: some View {
        PulseSpotlight(
            eyebrow: "PulseUI 1.0",
            title: "Build momentum.",
            message: "A native design language for ambitious products."
        ) {
            PulseButton(.primary, size: .md) {
                Text("Explore system")
            }
        }
        .frame(maxWidth: 380)
        .padding(.horizontal, 12)
    }
}

private struct DemoRow: Identifiable {
    let id = UUID()
    let name: String
    let status: String
    let value: String
}

struct TableScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var selected: DemoRow?

    private let rows = [
        DemoRow(name: "Design system", status: "Live", value: "98%"),
        DemoRow(name: "iOS release", status: "Review", value: "84%"),
        DemoRow(name: "Marketing site", status: "Draft", value: "62%"),
    ]

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.sm) {
                PulseTable(rows, columns: [
                    PulseTableColumn("Project", width: 150) { row in Text(row.name) },
                    PulseTableColumn("Status", width: 90) { row in
                        PulseBadge(row.status, tone: row.status == "Live" ? .success : .accent, style: .subtle)
                    },
                    PulseTableColumn("Progress", width: 90) { row in Text(row.value).monospacedDigit() },
                ]) { row in
                    PulseHaptic.selection()
                    selected = row
                }
                .frame(maxWidth: 360)

                PulseLabel(selected.map { "Selected: \($0.name)" } ?? "Select a row", role: .caption)
                    .foregroundStyle(theme.colors.foregroundSecondary)
            }
            .padding(.horizontal, 12)
        }
    }
}

struct ChartScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var style: PulseChart.Style = .area

    private let points = [
        PulseChartPoint(id: "m", label: "May", value: 42),
        PulseChartPoint(id: "j", label: "Jun", value: 58),
        PulseChartPoint(id: "j2", label: "Jul", value: 49),
        PulseChartPoint(id: "a", label: "Aug", value: 76),
        PulseChartPoint(id: "s", label: "Sep", value: 91),
    ]

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.sm) {
                PulseChart("Monthly revenue", points: points, style: style)
                    .frame(maxWidth: 360, minHeight: 180)
                Picker("Chart style", selection: $style) {
                    Text("Area").tag(PulseChart.Style.area)
                    Text("Line").tag(PulseChart.Style.line)
                    Text("Bar").tag(PulseChart.Style.bar)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
            }
            .padding(.horizontal, 12)
        }
    }
}

struct CommandPaletteScene: View {
    @State private var showPalette = false

    var body: some View {
        DemoStage {
            PulseButton(.primary, size: .md, action: { showPalette = true }) {
                Label("Open commands", systemImage: "command")
            }
            .frame(maxWidth: 190)
            .overlay {
                PulseCommandPalette(
                    isPresented: $showPalette,
                    actions: [
                        PulseCommandAction(id: "new", title: "New project", systemImage: "plus") {},
                        PulseCommandAction(id: "settings", title: "Open settings", systemImage: "gear") {},
                        PulseCommandAction(id: "share", title: "Share workspace", systemImage: "square.and.arrow.up") {},
                    ]
                )
            }
        }
    }
}

struct SegmentedControlScene: View {
    @State private var selection = "Overview"

    var body: some View {
        PulseSegmentedControl(
            selection: $selection,
            items: ["Overview", "Activity", "Insights"]
        )
        .frame(maxWidth: 320)
        .padding(.horizontal, 12)
    }
}

struct ContentStateScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var state: PulseContentState<AnyView>.State = .loaded

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.md) {
                PulseContentState<AnyView>(state, retry: { state = .loaded }) {
                    AnyView(PulseLabel("Your workspace is ready.", role: .callout))
                }
                .frame(maxWidth: 260, minHeight: 100)

                HStack(spacing: 8) {
                    ForEach(["Ready", "Loading", "Empty", "Error"], id: \.self) { title in
                        Button(title) {
                            withAnimation(theme.motion.springSnappy) {
                                switch title {
                                case "Loading": state = .loading
                                case "Empty": state = .empty()
                                case "Error": state = .error()
                                default: state = .loaded
                                }
                            }
                        }
                        .font(theme.typography.caption.font)
                        .buttonStyle(.bordered)
                        .tint(theme.colors.accent)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MetricCardScene: View {
            @Environment(\.pulseTheme) private var theme
            @State private var value = "$128K"
            @State private var points = [0.35, 0.42, 0.39, 0.56, 0.62, 0.74, 0.68, 0.9]

            var body: some View {
                DemoStage {
                    VStack(spacing: theme.spacing.sm) {
                        PulseMetricCard(
                            "Revenue",
                            value: value,
                            delta: .positive("+12.4%"),
                            points: points,
                            action: {
                            PulseHaptic.selection()
                            withAnimation(theme.motion.spring) {
                                value = value == "$128K" ? "$142K" : "$128K"
                                points = points.map { min(1, max(0, $0 + Double.random(in: -0.08...0.08))) }
                            }
                            }
                        )
                        .frame(maxWidth: 280)

                        PulseLabel("Tap the metric to animate its trend.", role: .caption)
                            .foregroundStyle(theme.colors.foregroundSecondary)
                    }
                }
            }
        }

struct DataToolbarScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var query = ""
    @State private var filter = "All"
    @State private var sort = "Latest"

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.md) {
                PulseDataToolbar(query: $query) {
                    Picker("Status", selection: $filter) {
                        Text("All").tag("All")
                        Text("Active").tag("Active")
                        Text("Archived").tag("Archived")
                    }
                } sort: {
                    Picker("Order", selection: $sort) {
                        Text("Latest").tag("Latest")
                        Text("Oldest").tag("Oldest")
                        }
                    }
                    .frame(maxWidth: 360)

                    PulseLabel("\(filter) · \(sort)", role: .caption)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                }
                .padding(.horizontal, 12)
            }
        }
}

// MARK: - Actions

struct ButtonScene: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.galleryGlass) private var glassOn
    @State private var loading = false

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.md) {
                PulseButton(.primary, size: .lg, isLoading: loading) {
                    PulseLabel("Continue", role: .title3)
                }
                .frame(maxWidth: 200)

                HStack(spacing: theme.spacing.sm) {
                    PulseButton(.glass, size: .md) {
                        PulseLabel("Ghost", role: .callout)
                    }
                    PulseButton(systemImage: "arrow.right", variant: glassOn ? .glass : .outline, size: .icon)
                }
            }
            .task(id: loading) {
                guard loading else { return }
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(theme.motion.spring) { loading = false }
            }
            .onTapGesture {
                withAnimation(theme.motion.spring) { loading = true }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct ChipScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var picked = "iOS 26"

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.sm) {
                HStack(spacing: 8) {
                    PulseChip("iOS 26", isSelected: picked == "iOS 26", style: .glass) { picked = "iOS 26" }
                    PulseChip("Pulse", isSelected: picked == "Pulse", style: .glass) { picked = "Pulse" }
                }
                HStack(spacing: 8) {
                    PulseChip("Liquid", isSelected: picked == "Liquid", style: .tinted) { picked = "Liquid" }
                    PulseChip("Glass", isSelected: picked == "Glass", style: .tinted) { picked = "Glass" }
                }
            }
        }
    }
}

// MARK: - Data Display

struct BadgeScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.sm) {
                HStack(spacing: 8) {
                    PulseBadge("LIVE", tone: .error, style: .filled, showDot: true)
                    PulseBadge("New", tone: .success, style: .glass, showDot: true)
                }
                HStack(spacing: 8) {
                    PulseBadge("Beta", tone: .accent, style: .subtle)
                    PulseBadge(.warning, style: .outlined) {
                        Image(systemName: "bolt.fill")
                    }
                }
            }
        }
    }
}

struct AvatarScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            HStack(spacing: theme.spacing.xl) {
                PulseAvatar(size: .lg, status: .online) {
                    PulseAvatarImage(initials: "AM", size: .lg)
                }
                PulseAvatar(size: .lg, status: .thinking) {
                    PulseAvatarImage(initials: "PQ", size: .lg)
                }
                PulseAvatar(size: .lg, status: .offline) {
                    PulseAvatarImage(initials: "T", size: .lg)
                }
            }
        }
    }
}

struct LabelScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                PulseLabel("Design system", role: .title1)
                PulseLabel("Liquid Glass, native tokens, one tap away.", role: .body)
                PulseLabel("OVERLINE · iOS 26", role: .overline)
                    .foregroundStyle(theme.colors.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
    }
}

struct ProgressScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var value = 0.68

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.lg) {
                PulseProgress(.linear, value: value, size: .lg)
                    .frame(maxWidth: 220)
                HStack(spacing: theme.spacing.xl) {
                    PulseProgress(.circular, value: value, size: .md, caption: "Upload")
                    PulseProgress(.ring, value: value, size: .md, caption: "Render")
                }
                PulseProgress(.indeterminateLinear, value: nil, showsLabel: false)
                    .frame(maxWidth: 220)
            }
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1.6))
                    withAnimation(theme.motion.spring) { value = value > 0.82 ? 0.2 : value + 0.16 }
                }
            }
        }
    }
}

struct CounterScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var likes = 1_284

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.md) {
                PulseCounter(value: likes, dampingFraction: 0.65)
                    .foregroundStyle(theme.colors.foreground)
                PulseButton(.glass, size: .iconLg) {
                Image(systemName: "heart.fill")
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    PulseHaptic.selection()
                    withAnimation(theme.motion.springBouncy) { likes += 7 }
                }
            )
            }
        }
    }
}

struct SkeletonScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var shimmer = true

    var body: some View {
        DemoStage {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(spacing: theme.spacing.sm) {
                    PulseSkeleton(shape: .circle, width: 40, height: 40, shimmer: shimmer)
                    VStack(alignment: .leading, spacing: 6) {
                        PulseSkeleton(shape: .rounded, width: 150, height: 12, shimmer: shimmer)
                        PulseSkeleton(shape: .rounded, width: 90, height: 9, shimmer: shimmer)
                    }
                }
                PulseSkeleton(shape: .rounded, width: nil, height: 72, shimmer: shimmer)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Forms

struct ToggleScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var wifi = true
    @State private var focus = false
    @State private var speed = true

    var body: some View {
        DemoStage {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                PulseToggle("Wi-Fi", isOn: $wifi, style: .ios, size: .md)
                PulseToggle("Focus", isOn: $focus, style: .pill, size: .sm)
                PulseToggle("Turbo", isOn: $speed, style: .checkbox, size: .md)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
    }
}

struct InputScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var email = ""

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.sm) {
                PulseInput("Email", text: $email, prompt: "you@example.com")
                    .onChange(of: email) {
                        email = String(email.filter { $0.isLetter || $0.isNumber || "@._".contains($0) })
                        if email.count >= 24 { email = String(email.prefix(24)) }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
    }
}

struct SliderScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var volume = 0.6

    var body: some View {
        DemoStage {
            PulseSlider("Volume", value: $volume, in: 0...1, step: 0.05, caption: "Feel the ticks", tint: theme.colors.accent)
                .padding(.horizontal, 20)
        }
    }
}

struct StepperScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var people = 3

    var body: some View {
        DemoStage {
            PulseStepper($people, in: 0...12, format: { String(format: "%02d", $0) })
                .padding(.horizontal, 20)
        }
    }
}

struct OTPScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var code = ""

    var body: some View {
        DemoStage {
            PulseOTP(length: 4, code: $code, style: .round) { _ in }
                .frame(maxWidth: 280)
        }
    }
}

struct RatingScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var score = 4

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.sm) {
                PulseRating(count: 5, rating: $score, symbol: .star, tint: theme.colors.accent)
            }
        }
    }
}

struct PickerScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var shipping = "Standard"
    private let items: [PickerItem<String>] = [
        .init(value: "Standard", label: "Standard"),
        .init(value: "Express", label: "Express"),
        .init(value: "Next day", label: "Next day"),
    ]

    var body: some View {
        DemoStage {
            PulsePicker($shipping, items: items, style: .segmented, size: .md)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - Nav & Data

struct ListScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            PulseList(.rounded) {
                PulseListRow("Design tokens", subtitle: "60+ semantic values", icon: "paintpalette.fill", iconTint: theme.colors.accent)
                PulseListRow("Motion", subtitle: "Springs, not awaits", icon: "waveform.path.ecg", iconTint: theme.colors.info)
                PulseListRow("Glass", subtitle: "Liquid, native", icon: "drop.degreesign.fill", iconTint: theme.colors.accent, showsChevron: true) {}
            }
            .padding(.horizontal, 14)
        }
    }
}

struct NavigationBarScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var isVisible = false

    var body: some View {
        DemoStage {
            PulseNavigationBar(title: "Pulse", subtitle: "Liquid Glass", style: .weather) {
                PulseAvatarImage(initials: "P", size: .sm)
            } trailing: {
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.colors.foreground)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(theme.colors.surfaceElevated))
                        .overlay(Circle().strokeBorder(theme.colors.border, lineWidth: 1))
                }
                .buttonStyle(PulseIconButtonStyle())
            }
            .padding(.horizontal, 16)
        }
    }
}

struct TabBarScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var selection = 0
    private let tabs: [TabItem] = [
        .init(label: "Home", icon: "house.fill"),
        .init(label: "Search", icon: "magnifyingglass"),
        .init(label: "Favorites", icon: "heart.fill"),
        .init(label: "Profile", icon: "person.fill"),
    ]

    var body: some View {
        DemoStage {
            TabView(selection: $selection) {
                Color.clear.tag(0)
                Color.clear.tag(1)
                Color.clear.tag(2)
                Color.clear.tag(3)
            }
            .overlay(alignment: .bottom) {
                PulseTabBar(selection: $selection, tabs: tabs, style: .floating)
                    .padding(.horizontal, 16)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct SidebarScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var selection = 0

    var body: some View {
        DemoStage {
            PulseSidebar(style: .rail, showsLabels: true) {
                PulseSidebarItem("Home", icon: "house", isSelected: selection == 0, action: { selection = 0 })
                PulseSidebarItem("Search", icon: "magnifyingglass", isSelected: selection == 1, action: { selection = 1 })
                PulseSidebarItem("Library", icon: "square.stack", isSelected: selection == 2, action: { selection = 2 })
            }
            .frame(maxWidth: 260)
        }
    }
}

// MARK: - Layout

struct CardScene: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.galleryGlass) private var glassOn

    var body: some View {
        DemoStage {
            PulseCard(glassOn ? .glass : .gradient) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        PulseBadge("Wallet", tone: .accent, style: .subtle)
                        Spacer()
                        Image(systemName: "apple.logo")
                            .foregroundStyle(theme.colors.foreground)
                    }
                    PulseLabel("$12,430.00", role: .title2)
                    PulseLabel("Available balance", role: .caption)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                }
            }
            .frame(maxWidth: 240)
        }
    }
}

struct DividerScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            VStack(spacing: 0) {
                PulseDivider(.solid)
                .padding(.vertical, 8)
                PulseDivider(.gradient, label: "or continue with")
                .padding(.vertical, 8)
                PulseDivider(.dashed)
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct AccordionScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var opened = Set<Int>([0])

    var body: some View {
        DemoStage {
            PulseAccordionGroup(
                items: [
                    AccordionItem(title: "What is Liquid Glass?") {
                        PulseLabel("A material that blurs, refracts and reacts.", role: .callout)
                    },
                    AccordionItem(title: "Is PulseUI native?") {
                        HStack(spacing: 8) {
                            PulseBadge("Yes", tone: .success, style: .glass, showDot: true)
                            PulseLabel("Pure SwiftUI.", role: .callout)
                        }
                    },
                ],
                allowsMultiple: false,
                defaultExpanded: [0]
            )
            .padding(.horizontal, 10)
        }
    }
}

struct CarouselScene: View {
    @Environment(\.pulseTheme) private var theme
    private let slides: [Slide] = [
        .init(label: "Actions"),
        .init(label: "Forms"),
        .init(label: "Overlays"),
    ]

    var body: some View {
        DemoStage {
            PulseCarousel(items: slides, indicatorStyle: .bars, spacing: 14) { slide in
                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    .fill(Color(light: 0x9ACA00, dark: 0xD9FE3E).opacity(0.9))
                    .overlay(alignment: .center) {
                        PulseLabel(slide.label, role: .title3)
                            .foregroundStyle(.black.opacity(0.6))
                    }
            }
            .frame(maxWidth: 260)
            .frame(height: 130)
        }
    }

    private struct Slide: Identifiable, Sendable {
        let id = UUID()
        let label: String
    }
}

// MARK: - Feedback

struct EmptyStateScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            PulseEmptyState(
                icon: "sparkles",
                iconTint: theme.colors.accent,
                title: "All caught up",
                message: "You watched everything. Really."
            )
            .frame(maxWidth: 260)
        }
    }
}

struct ToastScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var counter = 0

    var body: some View {
        DemoStage {
            VStack(spacing: theme.spacing.md) {
                PulseButton("Show toast", variant: .glass, size: .md)
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    counter += 1
                    PulseToastCenter.shared.show(
                        title: "Saved",
                        message: "Change \(counter) synced.",
                        tone: .success
                    )
                    PulseHaptic.selection()
                }
            )
        }
    }
}

// MARK: - Overlays

struct SheetScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var isPresented = false

    var body: some View {
        DemoStage {
            Button {
                isPresented = true
                PulseHaptic.impact(.soft)
            } label: {
                PulseLabel("Open sheet", role: .callout)
            }
            .buttonStyle(PulseIconButtonStyle())
            .pulseGlassCapsule(.interactive)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)

            if isPresented {
                PulseSheetView(isPresented: $isPresented, style: .glass, detents: [.medium, .large]) {
                    VStack(spacing: theme.spacing.sm) {
                        PulseLabel("Sheet, but Liquid", role: .title2)
                        PulseLabel("Drag between detents. Everything native.", role: .body)
                            .foregroundStyle(theme.colors.foregroundSecondary)
                        PulseButton("Done", variant: .primary, size: .md)
                            .frame(maxWidth: 200)
                    }
                    .padding(center: 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

struct ModalScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var isPresented = false

    var body: some View {
        DemoStage {
            Button {
                isPresented = true
                PulseHaptic.impact(.soft)
            } label: {
                PulseLabel("Open modal", role: .callout)
            }
            .buttonStyle(PulseIconButtonStyle())
            .pulseGlassCapsule(.interactive)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)

            PulseModal(isPresented: $isPresented, style: .card, alignment: .center) {
                VStack(spacing: theme.spacing.md) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundStyle(theme.colors.accent)
                    PulseLabel("Ready to fly", role: .title2)
                    PulseLabel("Glass. Motion. Zero boilerplate.", role: .body)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                    PulseButton("Continue", variant: .primary, size: .md)
                    .frame(maxWidth: 200)
                }
                .padding(24)
            }
        }
    }
}

struct AlertScene: View {
    @Environment(\.pulseTheme) private var theme

    var body: some View {
        DemoStage {
            PulseAlert(
                .success,
                title: "Saved",
                message: "Your design tokens are on every device.",
                icon: "checkmark.circle.fill",
                showsDismiss: true
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Remaining Forms

struct SearchScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var query = ""

    var body: some View {
        DemoStage {
            PulseSearch(text: $query, prompt: "Search components", style: .glass)
                .padding(.horizontal, 20)
        }
    }
}

struct DateRangeScene: View {
    @Environment(\.pulseTheme) private var theme
    @State private var start: Date? = Calendar.current.date(byAdding: .day, value: -7, to: .now)
    @State private var end: Date? = .now

    var body: some View {
        DemoStage {
            PulseDateRange(startDate: $start, endDate: $end)
                .padding(.horizontal, 14)
        }
    }
}

// MARK: - Small helpers

private extension View {
    func padding(center: CGFloat) -> some View {
        self.padding(.horizontal, center).padding(.vertical, center)
    }
}