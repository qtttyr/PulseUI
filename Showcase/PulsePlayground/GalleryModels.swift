import SwiftUI
import PulseUI

// MARK: - Gallery model

struct GalleryItem: Identifiable {
    let id = UUID()
    let name: String
    let slug: String
    let category: String
    let tagline: String
    let usage: String

    var addCommand: String { "pulse add \(slug.replacingOccurrences(of: "-", with: "_"))" }
}

enum GalleryGlassKey: EnvironmentKey {
    static let defaultValue = false
}

enum GalleryPreviewKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var galleryGlass: Bool {
        get { self[GalleryGlassKey.self] }
        set { self[GalleryGlassKey.self] = newValue }
    }

    var galleryPreview: Bool {
        get { self[GalleryPreviewKey.self] }
        set { self[GalleryPreviewKey.self] = newValue }
    }
}

// MARK: - Catalog

extension GalleryItem {
    static let categories = ["All", "Actions", "Forms", "Data Display", "Navigation & Data", "Overlays", "Feedback", "Layout"]

    static let all: [GalleryItem] = [
        .init(name: "Calendar", slug: "pulse-calendar", category: "Forms",
              tagline: "Native graphical date selection.",
              usage: "PulseCalendar(selection: $date)"),
        .init(name: "Form", slug: "pulse-form", category: "Forms",
              tagline: "Validation, focus and submit feedback.",
              usage: "PulseForm(\"Profile\", isValid: isValid, submit: save) { fields }"),
        .init(name: "Tooltip", slug: "pulse-tooltip", category: "Overlays",
              tagline: "Hover, long press and accessibility help.",
              usage: "PulseTooltip(\"More information\") { InfoButton() } tooltip: { HelpView() }"),
        .init(name: "Timeline", slug: "pulse-timeline", category: "Data Display",
              tagline: "Clear history and activity streams.",
              usage: "PulseTimeline(events)"),
        .init(name: "Kanban", slug: "pulse-kanban", category: "Data Display",
              tagline: "Adaptive columns for visual workflows.",
              usage: "PulseKanban(columns) { card, column in move(card, to: column) }"),
        .init(name: "Spotlight", slug: "pulse-spotlight", category: "Layout",
              tagline: "A focused hero surface for important moments.",
              usage: "PulseSpotlight(eyebrow: \"New\", title: \"Build momentum\") { actions }"),
        .init(name: "Table", slug: "pulse-table", category: "Data Display",
              tagline: "Responsive rows with states and selection.",
              usage: "PulseTable(rows, columns: [PulseTableColumn(\"Name\") { Text($0.name) }])"),
        .init(name: "Chart", slug: "pulse-chart", category: "Data Display",
              tagline: "Native line, area and bar visualisations.",
              usage: "PulseChart(\"Revenue\", points: points, style: .area)"),
        .init(name: "Command Palette", slug: "pulse-command-palette", category: "Navigation & Data",
              tagline: "Keyboard-first actions for power users.",
              usage: "PulseCommandPalette(isPresented: $show, actions: commands)"),
        .init(name: "Segmented Control", slug: "pulse-segmented-control", category: "Forms",
              tagline: "Native selection with quiet spring motion.",
              usage: "PulseSegmentedControl(selection: $selection, items: tabs)"),
        .init(name: "Content State", slug: "pulse-content-state", category: "Feedback",
              tagline: "Loading, empty, offline and error states.",
              usage: """
              PulseContentState(.loading) {
                  ContentView()
              }
              """),
        .init(name: "Metric Card", slug: "pulse-metric-card", category: "Data Display",
              tagline: "KPI, delta and a live trend line.",
              usage: """
              PulseMetricCard("Revenue", value: "$128K",
                  delta: .positive("+12.4%"), points: trend)
              """),
        .init(name: "Data Toolbar", slug: "pulse-data-toolbar", category: "Navigation & Data",
              tagline: "Search, filter and sort in one surface.",
              usage: """
              PulseDataToolbar(query: $query) {
                  FilterMenu()
              } sort: {
                  SortMenu()
              }
              """),
        .init(name: "Button", slug: "pulse-button", category: "Actions",
              tagline: "Nine variants, four sizes, loading state.",
              usage: """
              PulseButton("Continue", variant: .primary, size: .lg, isLoading: loading) {
                  await submit()
              }
              PulseButton("Ghost", variant: .glass) { addToCart() }
              """),
        .init(name: "Chip", slug: "pulse-chip", category: "Actions",
              tagline: "Filter chips with liquid glass.",
              usage: """
              PulseChip("iOS 26", isSelected: selected, style: .glass) {
                  toggleFilter()
              }
              """),
        .init(name: "Badge", slug: "pulse-badge", category: "Data Display",
              tagline: "Live dot, tones, glass.",
              usage: """
              PulseBadge("Live", tone: .success, style: .glass, showDot: true)
              """),
        .init(name: "Avatar", slug: "pulse-avatar", category: "Data Display",
              tagline: "Rings and status that breathe.",
              usage: """
              PulseAvatar(size: .lg, status: .online) {
                  AsyncImage(url: profileURL)
              }
              """),
        .init(name: "Toggle", slug: "pulse-toggle", category: "Forms",
              tagline: "iOS, checkbox and pill toggles.",
              usage: """
              PulseToggle("Airplane mode", isOn: $enabled, style: .ios, size: .md)
              """),
        .init(name: "Input", slug: "pulse-input", category: "Forms",
              tagline: "Secure, validated, icons.",
              usage: """
              PulseInput("Email", text: $email, prompt: "you@example.com")
              """),
        .init(name: "Slider", slug: "pulse-slider", category: "Forms",
              tagline: "Ticks, steps and drag glow.",
              usage: """
              PulseSlider("Volume", value: $level, in: 0...1, step: 0.05)
              """),
        .init(name: "Stepper", slug: "pulse-stepper", category: "Forms",
              tagline: "Count with haptic edges.",
              usage: "PulseStepper($people, in: 0...12)"),
        .init(name: "OTP", slug: "pulse-otp", category: "Forms",
              tagline: "Shake on error, glow focus.",
              usage: """
              PulseOTP(length: 6, code: $code, style: .round) { entered in
                  verify(entered)
              }
              """),
        .init(name: "Rating", slug: "pulse-rating", category: "Forms",
              tagline: "Star, heart or bolt.",
              usage: """
              PulseRating(count: 5, rating: $score, symbol: .star)
              """),
        .init(name: "Picker", slug: "pulse-picker", category: "Forms",
              tagline: "Segmented and pill pickers.",
              usage: """
              PulsePicker($shipping, items: items, style: .segmented)
              """),
        .init(name: "Progress", slug: "pulse-progress", category: "Data Display",
              tagline: "Linear, circular, indeterminate.",
              usage: "PulseProgress(.circular, value: 0.64, size: .md)"),
        .init(name: "Counter", slug: "pulse-counter", category: "Data Display",
              tagline: "Fluid number rolls.",
              usage: "PulseCounter(value: 12_340)",
        ),
        .init(name: "Skeleton", slug: "pulse-skeleton", category: "Data Display",
              tagline: "Shimmer placeholders.",
              usage: """
              PulseSkeleton(shape: .rounded, width: 200, height: 14)
              PulseSkeletonCard()
              """),
        .init(name: "Card", slug: "pulse-card", category: "Layout",
              tagline: "Elevated, glass, gradient.",
              usage: """
              PulseCard(.glass) {
                  Text("Balance")
                      .font(theme.typography.title2.font)
              }
              """),
        .init(name: "Divider", slug: "pulse-divider", category: "Layout",
              tagline: "Solid, dashed, gradient.",
              usage: """
              PulseDivider(.gradient, orientation: .horizontal)
                  .padding(.vertical, 24)
              """),
        .init(name: "Label", slug: "pulse-label", category: "Data Display",
              tagline: "Typographic scale, one API.",
              usage: "PulseLabel(\"Hello\", role: .title1)"),
        .init(name: "List", slug: "pulse-list", category: "Navigation & Data",
              tagline: "Rows with icons and chevrons.",
              usage: """
              PulseList(.rounded) {
                  PulseListRow("Design tokens", icon: "paintpalette")
              }
              """),
        .init(name: "Navigation Bar", slug: "pulse-navigation-bar", category: "Navigation & Data",
              tagline: "Weather, minimal, floating.",
              usage: """
              PulseNavigationBar(title: "Pulse", subtitle: "Liquid Glass") {
                  trailingControls
              }
              """),
        .init(name: "Tab Bar", slug: "pulse-tab-bar", category: "Navigation & Data",
              tagline: "Floating glass tab bar.",
              usage: """
              PulseTabBar(selection: $selection, tabs: tabs, style: .floating)
              """),
        .init(name: "Sidebar", slug: "pulse-sidebar", category: "Navigation & Data",
              tagline: "Rail navigation made glass.",
              usage: """
              PulseSidebar(style: .rail) {
                  PulseSidebarItem("Home", icon: "house", isSelected: selected) { onSelect() }
              }
              """),
        .init(name: "Accordion", slug: "pulse-accordion", category: "Layout",
              tagline: "Expandable content sections.",
              usage: """
              PulseAccordion("FAQ", isExpanded: $expanded, style: .glass) {
                  Text("Anything.").foregroundStyle(.secondary)
              }
              """),
        .init(name: "Carousel", slug: "pulse-carousel", category: "Layout",
              tagline: "Snappy pages and indicators.",
              usage: """
              PulseCarousel(items: slides, indicatorStyle: .bars) { slide in
                  SlideView(slide)
              }
              """),
        .init(name: "Empty State", slug: "pulse-empty-state", category: "Feedback",
              tagline: "Onboarding moments that move.",
              usage: """
              PulseEmptyState(icon: "sparkles", title: "All caught up", message: "…") {
                  PrimaryAction()
              }
              """),
        .init(name: "Search", slug: "pulse-search", category: "Forms",
              tagline: "Glassy field with clear button.",
              usage: "PulseSearch(text: $query, prompt: \"Search\", style: .glass)"),
        .init(name: "Date Range", slug: "pulse-date-range", category: "Forms",
              tagline: "Presets and a clear path.",
              usage: """
              PulseDateRange(startDate: $start, endDate: $end, presets: .standard)
              """),
        .init(name: "Sheet", slug: "pulse-sheet", category: "Overlays",
              tagline: "Bottom sheet, drag, detents.",
              usage: """
              PulseSheetView(isPresented: $show, style: .glass, detents: [.medium, .large]) {
                  yourContent
              }
              """),
        .init(name: "Modal", slug: "pulse-modal", category: "Overlays",
              tagline: "Center dialog with scrim.",
              usage: """
              PulseModal(isPresented: $show, style: .card, alignment: .center) {
                  yourContent
              }
              """),
        .init(name: "Alert", slug: "pulse-alert", category: "Overlays",
              tagline: "Augmented notifications.",
              usage: """
              PulseAlert(.success, title: "Saved", message: "Everything synced.")
              """),
        .init(name: "Toast", slug: "pulse-toast", category: "Feedback",
              tagline: "Floating feedback, one line.",
              usage: """
              PulseToastCenter.shared.show(title: "Saved", tone: .success)
              """),
    ]
}

// MARK: - Theme

extension PulsePlaygroundApp {
    var pulse: PulseTheme {
        PulseTheme(
            colors: ColorTokens(
                accent: Color(light: 0x9ACA00, dark: 0xD9FE3E)
            ),
            radius: RadiusTokens(sm: 10, md: 14, lg: 18, xl: 24, xxl: 32),
            typography: TypographyTokens(
                hero: .init(size: 34, weight: .bold, design: .rounded),
                title1: .init(size: 28, weight: .bold, design: .rounded),
                title2: .init(size: 22, weight: .semibold, design: .rounded),
                body: .init(size: 17, weight: .regular, design: .rounded),
                label: .init(size: 14, weight: .medium, design: .rounded)
            )
        )
    }
}