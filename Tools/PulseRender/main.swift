import Foundation
import AppKit
import SwiftUI
import PulseUI

// MARK: - Render metadata

struct RenderEntry: Codable {
    let component: String
    let variant: String
    let category: String
    let light: String
    let dark: String
    let width: Int
    let height: Int
    let scale: Int
}

struct Spec {
    let component: String
    let variant: String
    let category: String
    let size: CGSize
    let view: AnyView
}

// MARK: - Canvas

struct PulseCanvas<Content: View>: View {
    @Environment(\.pulseTheme) @MainActor private var theme
    let size: CGSize
    let content: Content

    var body: some View {
        ZStack {
            theme.colors.background
            content.padding(24)
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Samples

// ImageRenderer resolves adaptive NSColor(name:) providers to the app appearance
// even when rendering offscreen, so light/dark would look identical. Bake the
// palette per scheme and inject a theme with static colors instead.
@MainActor private let themeLight = PulseTheme(colors: staticColors(light: true))
@MainActor private let themeDark = PulseTheme(colors: staticColors(light: false))
@MainActor private let gold = Color(hex: 0x2563EB)

private func staticColors(light: Bool) -> ColorTokens {
    func c(_ l: UInt, _ d: UInt) -> Color {
        Color(hex: light ? l : d)
    }
    func ca(_ l: [UInt], _ d: [UInt]) -> [Color] {
        (light ? l : d).map { Color(hex: $0) }
    }
    return ColorTokens(
        background: c(0xFAFAFA, 0x09090B),
        backgroundSecondary: c(0xF4F4F5, 0x18181B),
        backgroundTertiary: c(0xE4E4E7, 0x27272A),
        surface: c(0xFFFFFF, 0x09090B),
        surfaceElevated: c(0xFFFFFF, 0x18181B),
        card: c(0xFFFFFF, 0x18181B),
        foreground: c(0x09090B, 0xFAFAFA),
        foregroundSecondary: c(0x71717A, 0xA1A1AA),
        foregroundTertiary: c(0xA1A1AA, 0x71717A),
        foregroundInverse: c(0xFFFFFF, 0x09090B),
        primary: c(0x18181B, 0xFAFAFA),
        primaryForeground: c(0xFFFFFF, 0x09090B),
        primaryMuted: c(0xF4F4F5, 0x27272A),
        secondary: c(0xF4F4F5, 0x27272A),
        secondaryForeground: c(0x18181B, 0xFAFAFA),
        secondaryMuted: c(0xE4E4E7, 0x3F3F46),
        accent: c(0x2563EB, 0x60A5FA),
        accentForeground: c(0xFFFFFF, 0xFFFFFF),
        success: c(0x16A34A, 0x4ADE80),
        successForeground: c(0xFFFFFF, 0x052E16),
        warning: c(0xEA580C, 0xFB923C),
        warningForeground: c(0xFFFFFF, 0x431407),
        error: c(0xDC2626, 0xF87171),
        errorForeground: c(0xFFFFFF, 0x450A0A),
        info: c(0x2563EB, 0x60A5FA),
        infoForeground: c(0xFFFFFF, 0xFFFFFF),
        border: c(0xE4E4E7, 0x27272A),
        borderStrong: c(0xD4D4D8, 0x3F3F46),
        ring: c(0x2563EB, 0x60A5FA),
        separator: c(0xF4F4F5, 0x27272A),
        overlay: (light ? Color.black : Color.white).opacity(0.5),
        scrim: Color.black.opacity(0.6),
        glassFill: Color.white.opacity(0.15),
        glassStroke: Color.white.opacity(0.25),
        glassHighlight: Color.white.opacity(0.4),
        gradientPrimary: ca([0x18181B, 0x27272A], [0x27272A, 0x18181B]),
        gradientSecondary: ca([0xF4F4F5, 0xE4E4E7], [0x27272A, 0x3F3F46]),
        gradientAccent: ca([0x2563EB, 0x7C3AED], [0x3B82F6, 0xA78BFA])
    )
}

@MainActor private func sample(_ component: String, _ variant: String, _ category: String, _ size: CGSize, @ViewBuilder _ build: @escaping () -> some View) -> Spec {
    Spec(
        component: component,
        variant: variant,
        category: category,
        size: size,
        view: AnyView(build())
    )
}

// MARK: - Spec collection

@MainActor private var buttonSamples: [Spec] {
    [
        sample("PulseButton", "showcase", "Actions", CGSize(width: 640, height: 340)) {
            VStack(spacing: 18) {
                PulseButton("Continue", variant: .primary, size: .lg)
                HStack(spacing: 12) {
                    PulseButton("Secondary", variant: .secondary, size: .md)
                    PulseButton("Outline", variant: .outline, size: .md)
                    PulseButton("Ghost", variant: .ghost, size: .md)
                }
                HStack(spacing: 12) {
                    PulseButton("Delete", variant: .destructive, size: .sm)
                    PulseButton("Glass", variant: .glass, size: .md)
                    PulseButton("Shine", variant: .gradient, size: .md)
                }
            }
            .frame(maxWidth: 480, alignment: .center)
        },
        sample("PulseButton", "icon", "Actions", CGSize(width: 400, height: 260)) {
            HStack(spacing: 16) {
                PulseButton(systemImage: "arrow.right", variant: .primary)
                PulseButton(systemImage: "heart", variant: .outline)
                PulseButton(systemImage: "paperplane", variant: .gradient)
                PulseButton(systemImage: "trash", variant: .destructive)
            }
        },
    ]
}

@MainActor private var cardSamples: [Spec] {
    [
        sample("PulseCard", "showcase", "Layout", CGSize(width: 720, height: 400)) {
            HStack(spacing: 20) {
                PulseCard(.elevated) {
                    cardBody("Elevated", "Default surface")
                }
                .frame(maxWidth: .infinity)

                PulseCard(.outlined) {
                    cardBody("Outlined", "Border only")
                }
                .frame(maxWidth: .infinity)

                PulseCard(.gradient) {
                    cardBody("Gradient", "Soft accent wash")
                }
                .frame(maxWidth: .infinity)
            }
        },
    ]
}

@ViewBuilder
@MainActor private func cardBody(_ title: String, _ subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        PulseLabel(title, role: .title3)
        PulseLabel(subtitle, role: .caption)
            .opacity(0.6)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
}

@MainActor private var badgeSamples: [Spec] {
    [
        sample("PulseBadge", "showcase", "Data Display", CGSize(width: 680, height: 300)) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    PulseBadge("Shipped", tone: .success, showDot: true)
                    PulseBadge("Beta", tone: .accent, style: .subtle, showDot: true)
                    PulseBadge("New", tone: .warning, style: .outlined, showDot: true)
                    PulseBadge("Archived", tone: .neutral, style: .filled)
                }
                HStack(spacing: 12) {
                    PulseBadge("Info", tone: .info, style: .glass, showDot: true)
                    PulseBadge("Inline", tone: .error, style: .subtle)
                    PulseBadge("$24.99", tone: .primary, style: .filled)
                    PulseBadge("Pro", tone: .accent, style: .glass)
                }
            }
        },
    ]
}

@MainActor private var avatarSamples: [Spec] {
    [
        sample("PulseAvatar", "showcase", "Data Display", CGSize(width: 480, height: 320)) {
            VStack(spacing: 24) {
                HStack(spacing: 18) {
                    PulseAvatar(size: .sm, status: .none) { EmptyView() }
                    PulseAvatar(size: .md, status: .online) { EmptyView() }
                    PulseAvatar(size: .lg, status: .busy) { EmptyView() }
                    PulseAvatar(size: .xl, status: .thinking) { EmptyView() }
                }
                HStack(spacing: 18) {
                    PulseAvatarImage(initials: "JD", size: .md)
                    PulseAvatarImage(initials: "AK", size: .lg)
                    PulseAvatarImage(initials: "MR", size: .xl)
                }
            }
        },
    ]
}

@MainActor private var labelSamples: [Spec] {
    [
        sample("PulseLabel", "showcase", "Typography", CGSize(width: 560, height: 420)) {
            VStack(alignment: .leading, spacing: 14) {
                PulseLabel("Pulse UI", role: .hero)
                PulseLabel("Component library for SwiftUI", role: .title2)
                PulseLabel("Body text keeps the rhythm of your design system consistent.", role: .body)
                PulseLabel("CAPTION — small but readable", role: .caption)
                PulseLabel("OVERLINE — the tiny label", role: .overline)
                PulseLabel("Mono 12 / 84", role: .mono)
            }
        },
    ]
}

@MainActor private var dividerSamples: [Spec] {
    [
        sample("PulseDivider", "showcase", "Layout", CGSize(width: 560, height: 320)) {
            VStack(spacing: 24) {
                PulseLabel("Solid", role: .caption)
                PulseDivider(.solid)
                PulseLabel("Dashed", role: .caption)
                PulseDivider(.dashed)
                PulseLabel("Gradient", role: .caption)
                PulseDivider(.gradient)
                PulseDivider(.solid, label: "Or continue with")
            }
        },
    ]
}

@MainActor private var skeletonSamples: [Spec] {
    [
        sample("PulseSkeleton", "showcase", "Feedback", CGSize(width: 560, height: 400)) {
            PulseSkeletonCard()
                .frame(maxWidth: 340)
        },
    ]
}

@MainActor private var toggleSamples: [Spec] {
    [
        sample("PulseToggle", "showcase", "Form", CGSize(width: 560, height: 360)) {
            VStack(spacing: 18) {
                PulseToggle("Airplane Mode", isOn: .constant(true), style: .ios)
                PulseToggle("Bluetooth", isOn: .constant(false), style: .ios)
                PulseToggle("Notifications", isOn: .constant(true), style: .ios, tint: gold)
                PulseToggle("Checkbox", isOn: .constant(true), style: .checkbox)
                PulseToggle("Pill", isOn: .constant(true), style: .pill, size: .lg)
            }
        },
    ]
}

@MainActor private var progressSamples: [Spec] {
    [
        sample("PulseProgress", "showcase", "Feedback", CGSize(width: 620, height: 340)) {
            VStack(spacing: 22) {
                PulseProgress(.linear, value: 0.68, caption: "Uploading files…")
                PulseProgress(.indeterminateLinear)
                HStack(spacing: 30) {
                    PulseProgress(.circular, value: 0.68, size: .lg)
                    PulseProgress(.ring, value: 0.42, size: .lg)
                }
            }
        },
    ]
}

@MainActor private var alertSamples: [Spec] {
    [
        sample("PulseAlert", "showcase", "Feedback", CGSize(width: 640, height: 360)) {
            VStack(spacing: 14) {
                PulseAlert(.info, title: "Heads up", message: "A new update is available.")
                PulseAlert(.success, title: "Payment received", message: "Your invoice has been paid in full.")
                PulseAlert(.error, title: "Connection lost", message: "Check your internet connection and try again.")
            }
        },
    ]
}

@MainActor private var toastSamples: [Spec] {
    [
        sample("PulseToast", "showcase", "Feedback", CGSize(width: 560, height: 360)) {
            VStack(spacing: 16) {
                PulseToast(
                    entry: ToastEntry(type: .success, title: "Saved", message: "Your changes were saved successfully.", tone: .success),
                    appearImmediately: true
                )
                PulseToast(
                    entry: ToastEntry(type: .error, title: "Upload failed", message: "The file is too large.", tone: .error),
                    appearImmediately: true
                )
            }
        },
    ]
}

@MainActor private var emptySamples: [Spec] {
    [
        sample("PulseEmptyState", "showcase", "Feedback", CGSize(width: 560, height: 400)) {
            PulseEmptyState(
                icon: "tray",
                title: "No items yet",
                message: "When you add items, they will show up here."
            ) {
                PulseButton("Add an item", variant: .primary, size: .md)
            }
            .frame(maxWidth: 360)
        },
    ]
}

@MainActor private var searchSamples: [Spec] {
    [
        sample("PulseSearch", "showcase", "Navigation", CGSize(width: 620, height: 320)) {
            VStack(spacing: 20) {
                PulseSearch(text: .constant("Design"), style: .filled)
                PulseSearch(text: .constant(""), style: .filled)
                PulseSearch(text: .constant("Glass"), style: .glass)
            }
        },
    ]
}

@MainActor private var chipSamples: [Spec] {
    [
        sample("PulseChip", "showcase", "Data Display", CGSize(width: 620, height: 300)) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    PulseChip("Swift", isSelected: true)
                    PulseChip("SwiftUI", isSelected: false)
                    PulseChip("UIKit", isSelected: false)
                }
                HStack(spacing: 12) {
                    PulseChip("Premium", isSelected: true, style: .tinted)
                    PulseChip("Outline", isSelected: false, style: .outlined)
                    PulseChip("Glass", isSelected: true, style: .glass)
                }
            }
        },
    ]
}

@MainActor private var ratingSamples: [Spec] {
    [
        sample("PulseRating", "showcase", "Data Display", CGSize(width: 560, height: 320)) {
            VStack(spacing: 24) {
                PulseRating(rating: .constant(4), size: 30, showsValue: true)
                HStack(spacing: 28) {
                    PulseRating(rating: .constant(3), symbol: .heart, size: 24)
                    PulseRating(rating: .constant(5), symbol: .bolt, size: 22)
                }
            }
        },
    ]
}

@MainActor private var counterSamples: [Spec] {
    [
        sample("PulseCounter", "showcase", "Data Display", CGSize(width: 480, height: 280)) {
            PulseCounter(value: 1289, font: .system(size: 60, weight: .bold, design: .rounded))
        },
    ]
}

@MainActor private var stepperSamples: [Spec] {
    [
        sample("PulseStepper", "showcase", "Form", CGSize(width: 480, height: 280)) {
            PulseStepper(.constant(8), in: 0...100)
        },
    ]
}

@MainActor private var sliderSamples: [Spec] {
    [
        sample("PulseSlider", "showcase", "Form", CGSize(width: 560, height: 320)) {
            VStack(spacing: 22) {
                PulseSlider("Volume", value: .constant(0.68), showsValue: true)
                PulseSlider("Temperature", value: .constant(0.32), tint: Color(hex: 0xEA580C), format: { String(format: "%.0f°", $0 * 100) })
            }
        },
    ]
}

@MainActor private var otpSamples: [Spec] {
    [
        sample("PulseOTP", "showcase", "Form", CGSize(width: 480, height: 300)) {
            PulseOTP(length: 6, code: .constant("1234"))
        },
    ]
}

@MainActor private var dateSamples: [Spec] {
    [
        sample("PulseDateRange", "showcase", "Form", CGSize(width: 640, height: 340)) {
            PulseDateRange(
                startDate: .constant(Calendar.current.date(byAdding: .day, value: -7, to: Date())),
                endDate: .constant(Date())
            )
        },
    ]
}

@MainActor private var listSamples: [Spec] {
    [
        sample("PulseList", "showcase", "Layout", CGSize(width: 560, height: 380)) {
            PulseList(.rounded) {
                PulseListRow("Wifi", subtitle: "Connected to HomeNetwork", icon: "wifi", iconTint: Color(hex: 0x2563EB))
                PulseListRow("Bluetooth", subtitle: "On", icon: "dot.radiowaves.left.and.right", iconTint: Color(hex: 0x16A34A))
                PulseListRow("AirDrop", subtitle: "Contacts Only", icon: "airplane", iconTint: Color(hex: 0xEA580C))
                PulseListRow("Storage", subtitle: "23.4 GB used", icon: "internaldrive", iconTint: Color(hex: 0x7C3AED), showsChevron: true)
            }
            .frame(maxWidth: 420)
        },
    ]
}

@MainActor private var inputSamples: [Spec] {
    [
        sample("PulseInput", "showcase", "Form", CGSize(width: 560, height: 360)) {
            VStack(spacing: 18) {
                PulseInput("Email", text: .constant("alex@design.app"), prompt: "you@example.com")
                PulseInput("Password", text: .constant(""), prompt: "••••••••", isSecure: true)
                PulseInput("Card number", text: .constant("4242 4242"), validation: .error("Card has expired."))
            }
        },
    ]
}

@MainActor private var navSamples: [Spec] {
    [
        sample("PulseNavigationBar", "showcase", "Navigation", CGSize(width: 720, height: 240)) {
            PulseNavigationBar(title: "Discover", subtitle: "38° Clear sky in San Francisco", style: .weather) {
                EmptyView()
            } trailing: {
                PulseAvatar(size: .sm, status: .offline) { EmptyView() }
            }
        },
    ]
}

@MainActor private var sidebarSamples: [Spec] {
    [
        sample("PulseSidebar", "showcase", "Navigation", CGSize(width: 560, height: 400)) {
            HStack {
                PulseSidebar(style: .rail, showsLabels: true) {
                    VStack(spacing: 6) {
                        PulseSidebarItem("Home", icon: "house", isSelected: true) {}
                        PulseSidebarItem("Search", icon: "magnifyingglass") {}
                        PulseSidebarItem("Library", icon: "square.stack.3d.up") {}
                        PulseSidebarItem("Settings", icon: "gearshape") {}
                    }
                    Spacer()
                    PulseSidebarItem("Profile", icon: "person.crop.circle") {}
                }
                Spacer()
            }
        },
    ]
}

private struct SegmentItem: Hashable, Sendable {
    let id: String
    init(_ id: String) { self.id = id }
}

@MainActor private var pickerSamples: [Spec] {
    [
        sample("PulsePicker", "showcase", "Form", CGSize(width: 620, height: 320)) {
            VStack(spacing: 28) {
                PulsePicker(.constant(SegmentItem("Segments")), items: [
                    PickerItem(value: SegmentItem("Segments"), label: "Segments"),
                    PickerItem(value: SegmentItem("Manual"), label: "Manual"),
                ], style: .segmented)

                PulsePicker(.constant(SegmentItem("All")), items: [
                    PickerItem(value: SegmentItem("All"), label: "All"),
                    PickerItem(value: SegmentItem("Active"), label: "Active"),
                    PickerItem(value: SegmentItem("Archived"), label: "Archived"),
                ], style: .pill)
            }
        },
    ]
}

@MainActor private var accordionSamples: [Spec] {
    [
        sample("PulseAccordion", "showcase", "Layout", CGSize(width: 560, height: 400)) {
            PulseAccordionGroup(
                items: [
                    AccordionItem(title: "What is Pulse UI?", content: {
                        PulseLabel("A premium copy-paste component library for SwiftUI.", role: .body)
                    }),
                    AccordionItem(title: "How do I install it?", content: {
                        PulseLabel("Run `pulse add button` in your project.", role: .body)
                    }),
                    AccordionItem(title: "Is it free?", content: {
                        PulseLabel("Yes — open source, forever.", role: .body)
                    }),
                ],
                defaultExpanded: [0]
            )
            .frame(maxWidth: 420)
        },
    ]
}

@MainActor private var modalSamples: [Spec] {
    [
        sample("PulseModal", "showcase", "Overlay", CGSize(width: 560, height: 420)) {
            PulseModal(isPresented: .constant(true)) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundStyle(Color(hex: 0x7C3AED))
                    PulseLabel("Upgrade to Pro", role: .title2)
                    PulseLabel("Unlock unlimited components and advanced theming.", role: .body)
                        .multilineTextAlignment(.center)
                    PulseButton("Upgrade", variant: .gradient, size: .md)
                        .padding(.top, 8)
                }
                .frame(maxWidth: 320)
            }
        },
    ]
}

private struct DemoCard: Identifiable, Sendable {
    let id: Int
    let title: String
    let emoji: String
}

@MainActor private var carouselSamples: [Spec] {
    [
        sample("PulseCarousel", "showcase", "Layout", CGSize(width: 620, height: 360)) {
            PulseCarousel(items: [
                DemoCard(id: 1, title: "Buttons", emoji: "🟣"),
                DemoCard(id: 2, title: "Cards", emoji: "🔷"),
                DemoCard(id: 3, title: "Toasts", emoji: "🟢"),
                DemoCard(id: 4, title: "Avatar", emoji: "🟠"),
            ], indicatorStyle: .bars) { card in
                PulseCard(.gradient) {
                    VStack(spacing: 10) {
                        Text(card.emoji).font(.system(size: 40))
                        PulseLabel(card.title, role: .title3)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
                }
                .frame(width: 200)
            }
        },
    ]
}

@MainActor private var tabSamples: [Spec] {
    [
        sample("PulseTabBar", "showcase", "Navigation", CGSize(width: 560, height: 320)) {
            VStack {
                Spacer()
                PulseTabBar(selection: .constant(1), tabs: [
                    TabItem(label: "Home", icon: "house"),
                    TabItem(label: "Search", icon: "magnifyingglass"),
                    TabItem(label: "Profile", icon: "person"),
                ], style: .floating)
            }
        },
    ]
}

// MARK: - Runner

@main
struct PulseRenderCommand {
    @MainActor
    static func main() throws {
        let args = Array(CommandLine.arguments.dropFirst())
        let outRoot = args.first ?? "website/public/render"

        let fm = FileManager.default
        try fm.createDirectory(atPath: outRoot, withIntermediateDirectories: true)

        var index: [RenderEntry] = []

        for spec in allSpecs {
            var files: [String: String] = [:]
            for scheme in [ColorScheme.light, .dark] {
                let name = scheme == .light ? "light" : "dark"
                let fileName = "\(spec.component)-\(spec.variant)-\(name).png"

                let injected = scheme == .dark ? themeDark : themeLight
                let canvas = PulseCanvas(size: spec.size, content: spec.view)
                    .pulseTheme(injected)
                    .preferredColorScheme(scheme)

                let renderer = ImageRenderer(content: canvas)
                renderer.scale = 2

                guard let cgImage = renderer.cgImage else {
                    print("FAILED \(fileName)")
                    continue
                }

                let rep = NSBitmapImageRep(cgImage: cgImage)
                guard let data = rep.representation(using: .png, properties: [:]) else {
                    print("FAILED encode \(fileName)")
                    continue
                }

                let url = URL(fileURLWithPath: outRoot).appendingPathComponent(fileName)
                try data.write(to: url)
                files[name] = fileName
                print("OK \(fileName) (\(data.count) bytes)")
            }

            guard let light = files["light"], let dark = files["dark"] else { continue }
            index.append(RenderEntry(
                component: spec.component,
                variant: spec.variant,
                category: spec.category,
                light: light,
                dark: dark,
                width: Int(spec.size.width * 2),
                height: Int(spec.size.height * 2),
                scale: 2
            ))
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try encoder.encode(index)
        try json.write(to: URL(fileURLWithPath: outRoot).appendingPathComponent("index.json"))
        print("Wrote \(index.count) entries -> \(outRoot)/index.json")
    }

    @MainActor static var allSpecs: [Spec] {
        buttonSamples + cardSamples + badgeSamples + avatarSamples + labelSamples
        + dividerSamples + skeletonSamples + toggleSamples + progressSamples
        + alertSamples + toastSamples + emptySamples + searchSamples + chipSamples
        + ratingSamples + counterSamples + stepperSamples + sliderSamples
        + otpSamples + dateSamples + listSamples + inputSamples + navSamples
        + sidebarSamples + pickerSamples + accordionSamples + modalSamples
        + carouselSamples + tabSamples
    }
}