export type Category =
  | "Actions"
  | "Typography"
  | "Data Display"
  | "Layout"
  | "Feedback"
  | "Form"
  | "Navigation"
  | "Overlay";

export interface ComponentMeta {
  slug: string;
  name: string;
  category: Category;
  tagline: string;
  description: string;
  features: string[];
  /** usage snippet shown on the page */
  usage: string;
  /** true when the render deserves a motion preview */
  animated?: boolean;
  sourceFile: string;
}

export const CATEGORIES: Category[] = [
  "Actions",
  "Typography",
  "Data Display",
  "Layout",
  "Feedback",
  "Form",
  "Navigation",
  "Overlay",
];

export const components: ComponentMeta[] = [
  {
    slug: "table",
    name: "PulseTable",
    category: "Data Display",
    tagline: "Structured data, without the visual noise.",
    description: "A responsive table primitive with selection, horizontal overflow and explicit loading, empty and error states.",
    features: ["Responsive horizontal layout", "Selectable rows", "Loading / empty / error states", "Dynamic Type friendly"],
    usage: `PulseTable(rows, columns: [
    PulseTableColumn("Name") { row in Text(row.name) }
])`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseTable/PulseTable.swift",
  },
  {
    slug: "chart",
    name: "PulseChart",
    category: "Data Display",
    tagline: "Native charts with a quiet visual language.",
    description: "Swift Charts-backed line, area and bar visualisations with semantic accessibility summaries and predictable states.",
    features: ["Line, area and bar styles", "Native Swift Charts", "Accessible data summary", "Loading / empty / error states"],
    usage: `PulseChart("Revenue", points: points, style: .area)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseChart/PulseChart.swift",
  },
  {
    slug: "command-palette",
    name: "PulseCommandPalette",
    category: "Navigation",
    tagline: "Power-user navigation in one keystroke.",
    description: "A focused command surface for search, navigation and actions with keyboard-first behavior.",
    features: ["Searchable actions", "Escape to dismiss", "Keyboard navigation on macOS", "VoiceOver labels"],
    usage: `PulseCommandPalette(isPresented: $show, actions: commands)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseCommandPalette/PulseCommandPalette.swift",
  },
  {
    slug: "segmented-control",
    name: "PulseSegmentedControl",
    category: "Form",
    tagline: "Selection with a precise native spring.",
    description: "A themed segmented control that keeps the functional glass treatment restrained and accessible.",
    features: ["Generic Hashable selection", "Native button semantics", "Reduce Motion aware", "Adaptive labels"],
    usage: `PulseSegmentedControl(selection: $selection, items: tabs)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseSegmentedControl/PulseSegmentedControl.swift",
  },
  {
    slug: "calendar",
    name: "PulseCalendar",
    category: "Form",
    tagline: "Native date selection with a considered shell.",
    description: "A graphical DatePicker wrapper with bounds, theme tokens and accessibility preserved.",
    features: ["Native graphical DatePicker", "Optional date bounds", "Light / dark ready", "VoiceOver friendly"],
    usage: `PulseCalendar(selection: $date)`,
    sourceFile: "Sources/PulseUI/Components/PulseCalendar/PulseCalendar.swift",
  },
  {
    slug: "form",
    name: "PulseForm",
    category: "Form",
    tagline: "Validation and submit feedback, composed.",
    description: "A focused form shell for validation messaging, submission state and consistent action hierarchy.",
    features: ["Validation state", "Submit loading state", "Dynamic Type", "Accessible error announcement"],
    usage: `PulseForm("Profile", isValid: isValid, submit: save) { fields }`,
    sourceFile: "Sources/PulseUI/Components/PulseForm/PulseForm.swift",
  },
  {
    slug: "tooltip",
    name: "PulseTooltip",
    category: "Overlay",
    tagline: "Context exactly where it is needed.",
    description: "Hover, long-press and accessibility help in one small cross-platform primitive.",
    features: ["Hover / help support", "Long press on touch", "Popover content", "Reduce visual noise"],
    usage: `PulseTooltip("More information") { InfoButton() } tooltip: { HelpView() }`,
    sourceFile: "Sources/PulseUI/Components/PulseTooltip/PulseTooltip.swift",
  },
  {
    slug: "timeline",
    name: "PulseTimeline",
    category: "Data Display",
    tagline: "History with a clear visual rhythm.",
    description: "A compact activity and release timeline with semantic event content and restrained motion.",
    features: ["Activity feeds", "Changelog-ready", "Semantic event labels", "Reduce Motion aware"],
    usage: `PulseTimeline(events)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseTimeline/PulseTimeline.swift",
  },
  {
    slug: "kanban",
    name: "PulseKanban",
    category: "Data Display",
    tagline: "Visual workflows that stay calm.",
    description: "An adaptive horizontal board for tasks and workflows with drag and drop hooks owned by your model.",
    features: ["Adaptive columns", "Drag and drop hooks", "Caller-owned state", "Keyboard-compatible buttons"],
    usage: `PulseKanban(columns) { card, column in move(card, to: column) }`,
    sourceFile: "Sources/PulseUI/Components/PulseKanban/PulseKanban.swift",
  },
  {
    slug: "spotlight",
    name: "PulseSpotlight",
    category: "Layout",
    tagline: "A hero surface with restraint.",
    description: "A focused launch and product moment surface with typography first and one controlled accent glow.",
    features: ["Hero composition", "Static performance-safe glow", "Dynamic Type", "Light / dark appearance"],
    usage: `PulseSpotlight(eyebrow: "New", title: "Build momentum") { actions }`,
    sourceFile: "Sources/PulseUI/Components/PulseSpotlight/PulseSpotlight.swift",
  },
  {
    slug: "button",
    name: "PulseButton",
    category: "Actions",
    tagline: "Eight variants. Four sizes. Zero friction.",
    description:
      "The workhorse of the system. Primary, secondary, outline, ghost, destructive, glass, gradient and link — every one of them instantly re-themes from a single accent token. Loading, full-width and icon-only modes included.",
    features: [
      "8 variants that share one API",
      "Icon-only and label+icon convenience inits",
      "Loading state with built-in spinner",
      "Haptic feedback on press",
      "Respects Reduce Motion",
    ],
    usage: `PulseButton("Continue", variant: .primary, size: .lg) {
    await submit()
}

PulseButton(systemImage: "arrow.right", variant: .gradient)
PulseButton("Delete", variant: .destructive, size: .sm)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseButton/PulseButton.swift",
  },
  {
    slug: "badge",
    name: "PulseBadge",
    category: "Data Display",
    tagline: "Small labels, big signal.",
    description:
      "Status, version and pricing badges in seven semantic tones and four styles — filled, subtle, outlined and glass. One line to add, one token to re-theme.",
    features: [
      "Seven semantic tones",
      "4 styles: filled, subtle, outlined, glass",
      "Pulsing indicator dot for live status",
      "Instantly re-themes from accent tokens",
    ],
    usage: `PulseBadge("Shipped", tone: .success, showDot: true)
PulseBadge("Beta", tone: .accent, style: .subtle)
PulseBadge("New", tone: .warning, style: .outlined)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseBadge/PulseBadge.swift",
  },
  {
    slug: "avatar",
    name: "PulseAvatar",
    category: "Data Display",
    tagline: "People, at a glance.",
    description:
      "Initials, image and status rings in every size. Presence states that update in place with a soft spring — online, busy, thinking and more.",
    features: [
      "Status states: online / busy / thinking / none",
      "Image or gradient-initials profile",
      "Custom ring via trailing content",
      "Effortless sizes from sm to xl",
    ],
    usage: `PulseAvatar(size: .md, status: .online) {
    Circle().stroke(theme.colors.ring, lineWidth: 2)
}
PulseAvatarImage(initials: "JD", size: .lg)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseAvatar/PulseAvatar.swift",
  },
  {
    slug: "label",
    name: "PulseLabel",
    category: "Typography",
    tagline: "Type that holds the system together.",
    description:
      "A curated type scale from oversized hero down to mono captions — all reading from your theme's typography tokens. Semantic role, not magic numbers.",
    features: [
      "8 semantic roles, one modifier",
      "Hero through caption to mono",
      "Weight, spacing and tracking from tokens",
      "Truncation and line limit built in",
    ],
    usage: `PulseLabel("Pulse UI", role: .hero)
PulseLabel("Section title", role: .title2)
PulseLabel("Body copy keeps your rhythm.", role: .body)
PulseLabel("CAPTION", role: .caption)`,
    sourceFile: "Sources/PulseUI/Components/PulseLabel/PulseLabel.swift",
  },
  {
    slug: "card",
    name: "PulseCard",
    category: "Layout",
    tagline: "Surfaces with personality.",
    description:
      "Seven surface styles — elevated, outlined, filled, glass, gradient, gradient-border and floating. Cards carry their own corner radius and shadow, so page rhythm stays consistent.",
    features: [
      "7 surface styles",
      "Interactive press states for tappable cards",
      "Corner radius token ready",
      "Floating style with ambient shadow",
    ],
    usage: `PulseCard(.gradient) {
    VStack(alignment: .leading) {
        PulseLabel("Revenue", role: .title3)
        PulseLabel("$42,890", role: .hero)
    }
    .padding(20)
}
.frame(maxWidth: .infinity)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseCard/PulseCard.swift",
  },
  {
    slug: "divider",
    name: "PulseDivider",
    category: "Layout",
    tagline: "Structure without noise.",
    description:
      "Solid, dashed, gradient and labeled dividers. The labeled variant doubles as a stylish 'or continue with' separator for auth screens.",
    features: [
      "Solid / dashed / gradient styles",
      "Embedded label (`Or continue with`)",
      "Horizontal and vertical orientations",
      "Token-driven thickness",
    ],
    usage: `PulseDivider(.gradient)
PulseDivider(.solid, label: "Or continue with")
PulseDivider(.dashed, orientation: .vertical)`,
    sourceFile: "Sources/PulseUI/Components/PulseDivider/PulseDivider.swift",
  },
  {
    slug: "skeleton",
    name: "PulseSkeleton",
    category: "Feedback",
    tagline: "Loading, prettier.",
    description:
      "Shimmering placeholders that respect the exact shape of your content — or fill a whole card in one line with PulseSkeletonCard.",
    features: [
      "Single shape and whole-card variants",
      "Silky shimmer animation",
      "Shape-preserving corner rounding",
      "Disables shimmer under Reduce Motion",
    ],
    usage: `PulseSkeletonCard()
    .frame(maxWidth: 340)

RoundedRectSkeleton(cornerRadius: 12)
    .frame(width: 200, height: 64)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseSkeleton/PulseSkeleton.swift",
  },
  {
    slug: "toggle",
    name: "PulseToggle",
    category: "Form",
    tagline: "iOS, checkbox or pill — one API.",
    description:
      "Three switch idioms from a single binding. Tint, size and auxiliary checkmark styling included. Accessibility traits wired out of the box.",
    features: [
      "iOS, checkbox and pill styles",
      "Custom tint and sizes",
      "Scrollable description text",
      "Full accessibility traits",
    ],
    usage: `PulseToggle("Airplane Mode", isOn: $airplane, style: .ios)
PulseToggle("Agree to terms", isOn: $consent, style: .checkbox)
PulseToggle("Pill", isOn: $enabled, style: .pill)`,
    sourceFile: "Sources/PulseUI/Components/PulseToggle/PulseToggle.swift",
  },
  {
    slug: "progress",
    name: "PulseProgress",
    category: "Feedback",
    tagline: "Progress that feels alive.",
    description:
      "Linear, circular, ring and indeterminate indicators with live captions. Smooth springs, gradient fills and a big-ring mode for hero stats.",
    features: [
      "Linear, circular, ring, indeterminate",
      "Caption + percentage labels",
      "Gradient progress fills",
      "Smooth animated springs",
    ],
    usage: `PulseProgress(.linear, value: 0.68, caption: "Uploading…")
PulseProgress(.circular, value: 0.42, size: .lg)
PulseProgress(.indeterminateLinear)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseProgress/PulseProgress.swift",
  },
  {
    slug: "alert",
    name: "PulseAlert",
    category: "Feedback",
    tagline: "Say it clearly, say it kindly.",
    description:
      "Inline alerts with semantic icons, tone-colored accents and dismiss control. Info, success, warning and error in one consistent shape.",
    features: [
      "4 semantic variants",
      "Automatic tone icons",
      "Optional dismiss (with haptics)",
      "Token-driven background wash",
    ],
    usage: `PulseAlert(.info, title: "Heads up", message: "New update available.")
PulseAlert(.error, title: "Connection lost", message: "Check your network.")`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseAlert/PulseAlert.swift",
  },
  {
    slug: "toast",
    name: "PulseToast",
    category: "Feedback",
    tagline: "Transient feedback, artfully done.",
    description:
      "Sliding toasts with icons, tones and a graceful close animation. Feeds naturally into PulseToastCenter for queue management.",
    features: [
      "Success / error / warning / info entries",
      "Auto-dismiss + duration control",
      "Slide-in with spring",
      "Works inside PulseToastCenter",
    ],
    usage: `PulseToast(entry: ToastEntry(
    type: .success, title: "Saved", message: "Done.", tone: .success
))
PulseToastCenter().overlay()`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseToast/PulseToast.swift",
  },
  {
    slug: "empty-state",
    name: "PulseEmptyState",
    category: "Feedback",
    tagline: "Every drawer deserves a nice bottom.",
    description:
      "A first-class empty state — icon, headline, supporting copy and an optional call-to-action, all centered and token-aligned.",
    features: [
      "Icon + copy + CTA layout",
      "Optional action button",
      "Theme-aware artwork",
      "Fits lists, drawers and modals",
    ],
    usage: `PulseEmptyState(
    icon: "tray",
    title: "No items yet",
    message: "Items you add will appear here."
) {
    PulseButton("Add item", variant: .primary) {}
}`,
    sourceFile: "Sources/PulseUI/Components/PulseEmptyState/PulseEmptyState.swift",
  },
  {
    slug: "search",
    name: "PulseSearch",
    category: "Navigation",
    tagline: "Find anything, instantly.",
    description:
      "A polished search field with filled, glass and destructive tones, dynamic placeholder switching and submission support.",
    features: [
      "Filled / glass styles",
      "Placeholder morphing",
      "On-submit and cancel actions",
      "Theme-aware focus glow",
    ],
    usage: `PulseSearch(text: $query, prompt: "Search people", style: .filled)`,
    sourceFile: "Sources/PulseUI/Components/PulseSearch/PulseSearch.swift",
  },
  {
    slug: "chip",
    name: "PulseChip",
    category: "Data Display",
    tagline: "Filters, tags and attribute pills.",
    description:
      "Compact, selectable pills in default, select, tinted, outlined and glass styles — with an optional animated checkmark.",
    features: [
      "Single / multi select patterns",
      "5 visual styles",
      "Task-style checkmark",
      "Dead-simple onTap",
    ],
    usage: `PulseChip("Swift", isSelected: $isSwift)
PulseChip("Premium", isSelected: true, style: .tinted)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseChip/PulseChip.swift",
  },
  {
    slug: "rating",
    name: "PulseRating",
    category: "Data Display",
    tagline: "Let people rate in style.",
    description:
      "Stars, hearts or bolts with springy selection, custom tints and an optional live counter. Ideal for reviews, favorites and skill meters.",
    features: [
      "Stars / hearts / bolts",
      "Springy selection animation",
      "Live value capsule",
      "Read-only mode for stats",
    ],
    usage: `PulseRating(rating: $score, size: 30, showsValue: true)
PulseRating(rating: .constant(4), symbol: .heart, isReadOnly: true)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseRating/PulseRating.swift",
  },
  {
    slug: "counter",
    name: "PulseCounter",
    category: "Data Display",
    tagline: "Numbers that count up.",
    description:
      "An animated ticker for stats and dashboards. Spins through digits on value change — great for revenue, users and scores.",
    features: [
      "Digit-roll animation",
      "Arbitrary fonts",
      "String or number values",
      "Reduced-motion safe",
    ],
    usage: `PulseCounter(value: 1289, font: .system(size: 48, weight: .bold))`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseCounter/PulseCounter.swift",
  },
  {
    slug: "stepper",
    name: "PulseStepper",
    category: "Form",
    tagline: "Precision input, playful.",
    description:
      "A plus/minus stepper with rubbery press feedback, clamps and step customization — for quantity pickers and settings.",
    features: [
      "Range clamping",
      "Custom step size",
      "Compact inline layout",
      "Press haptics",
    ],
    usage: `PulseStepper($quantity, in: 0...100, step: 5)`,
    sourceFile: "Sources/PulseUI/Components/PulseStepper/PulseStepper.swift",
  },
  {
    slug: "slider",
    name: "PulseSlider",
    category: "Form",
    tagline: "Sliders done right.",
    description:
      "A labeled slider with live value capsule, custom formatting and tint. Round, precise and animated with the system's springs.",
    features: [
      "Live value capsule",
      "Custom formatters (e.g. \"68°\")",
      "Optional tint",
      "Discrete step mode",
    ],
    usage: `PulseSlider("Volume", value: $volume, showsValue: true)
PulseSlider("Temp", value: $temp, format: { "\(Int($0 * 100))°" })`,
    sourceFile: "Sources/PulseUI/Components/PulseSlider/PulseSlider.swift",
  },
  {
    slug: "otp",
    name: "PulseOTP",
    category: "Form",
    tagline: "Verification, frictionless.",
    description:
      "A single-hidden-field OTP that types straight into animated boxes. Six digits, paste-friendly, auto-advancing.",
    features: [
      "Hidden single TextField",
      "Animated box transitions",
      "Sensitive-content handling",
      "Auto-focus set",
    ],
    usage: `PulseOTP(length: 6, code: $code) { otp in
    await verify(otp)
}`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseOTP/PulseOTP.swift",
  },
  {
    slug: "date-range",
    name: "PulseDateRange",
    category: "Form",
    tagline: "Ranges, not dates.",
    description:
      "A date range picker with preset chips (Last 7 days, This month…), custom validation, and a fully themed inline calendar.",
    features: [
      "Preset chips for common ranges",
      "Validation with error messaging",
      "Inline themed calendar",
      "Sendable state",
    ],
    usage: `PulseDateRange(startDate: $start, endDate: $end)`,
    sourceFile: "Sources/PulseUI/Components/PulseDateRange/PulseDateRange.swift",
  },
  {
    slug: "list",
    name: "PulseList",
    category: "Layout",
    tagline: "Settings screens, perfected.",
    description:
      "Rounded and plain lists with icon chips, chevrons and rich rows — the fastest way to a home-screen-quality Settings page.",
    features: [
      "Rounded / plain containers",
      "Icon-chip rows with tints",
      "Chevron and contextual rows",
      "Section-aware styling",
    ],
    usage: `PulseList(.rounded) {
    PulseListRow("Wi-Fi", subtitle: "Connected", icon: "wifi", iconTint: .success)
    PulseListRow("Bluetooth", icon: "dot.radiowaves…", showsChevron: true)
}`,
    sourceFile: "Sources/PulseUI/Components/PulseList/PulseList.swift",
  },
  {
    slug: "input",
    name: "PulseInput",
    category: "Form",
    tagline: "Text fields that behave.",
    description:
      "Filled, glass and destructive inputs with secure entry, validation states and return-key handling — cross-platform to the core.",
    features: [
      "Filled / glass / error styles",
      "Secure text entry",
      "Validation with message",
      "On-submit + interaction state",
    ],
    usage: `PulseInput("Email", text: $email, prompt: "you@example.com")
PulseInput("Card", text: $card, validation: .error("Expired."), isSecure: true)`,
    sourceFile: "Sources/PulseUI/Components/PulseInput/PulseInput.swift",
  },
  {
    slug: "navigation-bar",
    name: "PulseNavigationBar",
    category: "Navigation",
    tagline: "A title bar with a pulse.",
    description:
      "Weather-style live tiles, health metrics, large titles and trailing actions — a nav bar that actually does something.",
    features: [
      "Weather and standard styles",
      "Subtitle + live content slot",
      "Trailing action area",
      "Glass-aware elevation",
    ],
    usage: `PulseNavigationBar(title: "Discover", subtitle: "38° Clear sky", style: .weather) {
    // live content
} trailing: {
    PulseAvatar(size: .sm, status: .online) { EmptyView() }
}`,
    sourceFile: "Sources/PulseUI/Components/PulseNavigationBar/PulseNavigationBar.swift",
  },
  {
    slug: "sidebar",
    name: "PulseSidebar",
    category: "Navigation",
    tagline: "Desktop-grade navigation.",
    description:
      "Rail and full sidebars with selected-state cards, labels and badge-friendly rows. Built for macOS and iPad multi-column apps.",
    features: [
      "Rail / full styles",
      "Selected-state visual",
      "Label toggle for rail mode",
      "Scroll-adaptive layout",
    ],
    usage: `PulseSidebar(style: .rail, showsLabels: true) {
    PulseSidebarItem("Home", icon: "house", isSelected: true) {}
    PulseSidebarItem("Search", icon: "magnifyingglass") {}
}`,
    sourceFile: "Sources/PulseUI/Components/PulseSidebar/PulseSidebar.swift",
  },
  {
    slug: "picker",
    name: "PulsePicker",
    category: "Form",
    tagline: "Segments and pills together.",
    description:
      "Segmented and pill pickers with animated selection thumbs, disabled options and haptic landings. Your material-free alternative to Picker.",
    features: [
      "Segmented / pill styles",
      "Animated selection thumb",
      "Disabled items",
      "Sendable option values",
    ],
    usage: `PulsePicker($selection, items: [
    PickerItem(value: "Tab", label: "Tab"),
    PickerItem(value: "View", label: "View"),
], style: .segmented)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulsePicker/PulsePicker.swift",
  },
  {
    slug: "accordion",
    name: "PulseAccordion",
    category: "Layout",
    tagline: "Q&A and settings, without clutter.",
    description:
      "Expandable items in cards, glass or transparent styles with smooth height transitions and multi-select policy.",
    features: [
      "Cards / glass / transparent",
      "Single or multi expand",
      "Default-expanded control",
      "Animated height content",
    ],
    usage: `PulseAccordionGroup(items: items, defaultExpanded: [0])`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseAccordion/PulseAccordion.swift",
  },
  {
    slug: "modal",
    name: "PulseModal",
    category: "Overlay",
    tagline: "Modals with intent.",
    description:
      "Themed modal sheets with alignment control, scrim opacity, tap-to-dismiss and rounded content. Cleaner than a raw .overlay.",
    features: [
      "Scrim + tap-to-dismiss",
      "Alignment and sizing control",
      "Fade-scale entry",
      "Themed surface",
    ],
    usage: `.pulseModal(isPresented: $showing) {
    PulseLabel("Upgrade to Pro", role: .title2)
    PulseButton("Upgrade", variant: .gradient) {}
}`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseModal/PulseModal.swift",
  },
  {
    slug: "carousel",
    name: "PulseCarousel",
    category: "Layout",
    tagline: "Swipe, snap, repeat.",
    description:
      "A paging carousel with dot and bar indicators, configurable spacing and per-item content — for onboarding and featured decks.",
    features: [
      "Snap-paging horizontal scroll",
      "Dots or animated bars indicator",
      "Item spacing control",
      "Identifiable Sendable items",
    ],
    usage: `PulseCarousel(items: slides, indicatorStyle: .bars) { slide in
    PulseCard(.gradient) { slide.view }
        .frame(width: 220)
}`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseCarousel/PulseCarousel.swift",
  },
  {
    slug: "tab-bar",
    name: "PulseTabBar",
    category: "Navigation",
    tagline: "The tab bar, elevated.",
    description:
      "A floating glass tab bar with selected-state pills and springy icons. Insets and solid variants for every layout.",
    features: [
      "Floating glass / solid / inset",
      "Selected-pill animation",
      "Automatic labels + traits",
      "Scroll-friendly padding",
    ],
    usage: `PulseTabBar(selection: $tab, tabs: [
    TabItem(label: "Home", icon: "house"),
    TabItem(label: "Search", icon: "magnifyingglass"),
], style: .floating)
.frame(maxHeight: .infinity, alignment: .bottom)`,
    animated: true,
    sourceFile: "Sources/PulseUI/Components/PulseTabBar/PulseTabBar.swift",
  },
  {
    slug: "sheet",
    name: "PulseSheet",
    category: "Overlay",
    tagline: "Sheets with a theme.",
    description:
      "Presentation-detent sheets with drag indicator, close affordance and background effects — the polished sibling of Modal.",
    features: [
      "Detent-driven presentation",
      "Indented drag indicator",
      "Optional close button",
      "Fire-and-forget `.pulseSheet` modifier",
    ],
    usage: `.pulseSheet(item: $draft) { draft in
    PulseSheetContent(draft: draft)
}`,
    sourceFile: "Sources/PulseUI/Components/PulseSheet/PulseSheet.swift",
  },
];

export const componentMap: Record<string, ComponentMeta> = Object.fromEntries(
  components.map((c) => [c.slug, c]),
);

export const byCategory = (cat: Category) => components.filter((c) => c.category === cat);