#!/usr/bin/env swift
// Generates Sources/PulseCLI/Resources/EmbeddedComponents.swift from the real
// component sources. Every file is base64-encoded so no escaping of Swift
// source inside Swift string literals is ever needed.
//
// Run: swift Tools/Pulse/generate_embedded.swift
// Output: Sources/PulseCLI/Resources/EmbeddedComponents.swift (UTF-8, LF)

import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let componentsRoot = root.appendingPathComponent("Sources/PulseUI/Components")
let themeRoot = root.appendingPathComponent("Sources/PulseUI/Theme")
let utilitiesRoot = root.appendingPathComponent("Sources/PulseUI/Utilities")
let entryFile = root.appendingPathComponent("Sources/PulseUI/PulseUI.swift")

struct Entry: Codable {
    let name: String
    let relativePath: String
    let base64: String
}

func encode(_ url: URL, name: String, relativePath: String) throws -> Entry {
    let data = try Data(contentsOf: url)
    return Entry(name: name, relativePath: relativePath, base64: data.base64EncodedString())
}

var entries: [Entry] = []

let fm = FileManager.default
for dir in (try fm.contentsOfDirectory(at: componentsRoot, includingPropertiesForKeys: nil)).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
    guard dir.hasDirectoryPath else { continue }
    let files = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        .filter { $0.pathExtension == "swift" }
        .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
    for file in files {
        let name = file.deletingPathExtension().lastPathComponent
        let rel = "Components/\(dir.lastPathComponent)/\(file.lastPathComponent)"
        entries.append(try encode(file, name: name, relativePath: rel))
    }
}

for file in (try fm.contentsOfDirectory(at: themeRoot, includingPropertiesForKeys: nil))
    .filter({ $0.pathExtension == "swift" })
    .sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
    let name = file.deletingPathExtension().lastPathComponent
    let rel = "Theme/\(file.lastPathComponent)"
    entries.append(try encode(file, name: name, relativePath: rel))
}

for file in (try fm.contentsOfDirectory(at: utilitiesRoot, includingPropertiesForKeys: nil))
    .filter({ $0.pathExtension == "swift" })
    .sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
    let name = file.deletingPathExtension().lastPathComponent
    let rel = "Utilities/\(file.lastPathComponent)"
    entries.append(try encode(file, name: name, relativePath: rel))
}

entries.append(try encode(entryFile, name: "PulseUI", relativePath: "PulseUI.swift"))

// Public type names used to build the catalog (component name -> primary type).
let catalogTypes: [String: String] = [
    "PulseCalendar": "PulseCalendar", "PulseForm": "PulseForm", "PulseKanban": "PulseKanban",
    "PulseChart": "PulseChart", "PulseCommandPalette": "PulseCommandPalette",
    "PulseContentState": "PulseContentState",
    "PulseDataToolbar": "PulseDataToolbar",
    "PulseAccordion": "PulseAccordionGroup", "PulseAlert": "PulseAlert", "PulseAvatar": "PulseAvatar",
    "PulseBadge": "PulseBadge", "PulseButton": "PulseButton", "PulseCard": "PulseCard",
    "PulseCarousel": "PulseCarousel", "PulseChip": "PulseChip", "PulseCounter": "PulseCounter",
    "PulseDateRange": "PulseDateRange", "PulseDivider": "PulseDivider", "PulseEmptyState": "PulseEmptyState",
    "PulseInput": "PulseInput", "PulseLabel": "PulseLabel", "PulseList": "PulseList",
    "PulseModal": "PulseModal", "PulseNavigationBar": "PulseNavigationBar", "PulseOTP": "PulseOTP",
    "PulsePicker": "PulsePicker", "PulseProgress": "PulseProgress", "PulseRating": "PulseRating",
    "PulseSearch": "PulseSearch", "PulseSheet": "PulseSheet", "PulseSidebar": "PulseSidebar",
    "PulseSkeleton": "PulseSkeleton", "PulseSlider": "PulseSlider", "PulseStepper": "PulseStepper",
    "PulseTabBar": "PulseTabBar", "PulseToast": "PulseToast", "PulseToggle": "PulseToggle",
    "PulseMetricCard": "PulseMetricCard",
    "PulseSegmentedControl": "PulseSegmentedControl", "PulseTable": "PulseTable",
    "PulseTimeline": "PulseTimeline", "PulseTooltip": "PulseTooltip", "PulseSpotlight": "PulseSpotlight",
]

let categories: [String: String] = [
    "PulseCalendar": "Form", "PulseForm": "Form", "PulseKanban": "Data Display",
    "PulseChart": "Data Display", "PulseCommandPalette": "Navigation",
    "PulseContentState": "Feedback", "PulseDataToolbar": "Navigation", "PulseMetricCard": "Data Display",
    "PulseAccordion": "Layout", "PulseAlert": "Feedback", "PulseAvatar": "Data Display",
    "PulseBadge": "Data Display", "PulseButton": "Actions", "PulseCard": "Layout",
    "PulseCarousel": "Layout", "PulseChip": "Data Display", "PulseCounter": "Data Display",
    "PulseDateRange": "Form", "PulseDivider": "Layout", "PulseEmptyState": "Feedback",
    "PulseInput": "Form", "PulseLabel": "Typography", "PulseList": "Layout",
    "PulseModal": "Overlay", "PulseNavigationBar": "Navigation", "PulseOTP": "Form",
    "PulsePicker": "Form", "PulseProgress": "Feedback", "PulseRating": "Data Display",
    "PulseSearch": "Navigation", "PulseSheet": "Overlay", "PulseSidebar": "Navigation",
    "PulseSkeleton": "Feedback", "PulseSlider": "Form", "PulseStepper": "Form",
    "PulseTabBar": "Navigation", "PulseToast": "Feedback", "PulseToggle": "Form",
    "PulseSegmentedControl": "Form", "PulseTable": "Data Display",
    "PulseTimeline": "Data Display", "PulseTooltip": "Overlay", "PulseSpotlight": "Layout",
]

let usage: [String: String] = [
    "PulseCalendar": "PulseCalendar(selection: $date)",
    "PulseForm": "PulseForm(\"Profile\", isValid: isValid, submit: save) { fields }",
    "PulseKanban": "PulseKanban(columns) { card, column in move(card, to: column) }",
    "PulseChart": "PulseChart(\"Revenue\", points: points, style: .area)",
    "PulseCommandPalette": "PulseCommandPalette(isPresented: $show, actions: commands)",
    "PulseContentState": "PulseContentState(.loading) { content }",
    "PulseDataToolbar": "PulseDataToolbar(query: $query) { filters } sort: { sorting }",
    "PulseMetricCard": "PulseMetricCard(\"Revenue\", value: \"$128K\", delta: .positive(\"+12.4%\"))",
    "PulseAccordion": "PulseAccordionGroup(items: [AccordionItem(title: \"Q\", content: { PulseLabel(\"A\", role: .body) })], defaultExpanded: [0])",
    "PulseAlert": "PulseAlert(.success, title: \"Saved\", message: \"Done.\")",
    "PulseAvatar": "PulseAvatar(size: .md, status: .online) { Image(\"avatar\").resizable().scaledToFill() }",
    "PulseBadge": "PulseBadge(\"Beta\", tone: .accent, style: .subtle, showDot: true)",
    "PulseButton": "PulseButton(\"Continue\", variant: .primary, size: .lg) { await submit() }",
    "PulseCard": "PulseCard(.elevated) { PulseLabel(\"Body\", role: .body) }",
    "PulseCarousel": "PulseCarousel(items: items, indicatorStyle: .bars) { item in PulseCard(.gradient) { Text(item.title) } }.frame(width: 200)",
    "PulseChip": "PulseChip(\"Swift\", isSelected: true, style: .tinted)",
    "PulseCounter": "PulseCounter(value: 1289, font: .system(size: 56, weight: .bold, design: .rounded))",
    "PulseDateRange": "PulseDateRange(startDate: $start, endDate: $end)",
    "PulseDivider": "PulseDivider(.gradient) \nPulseDivider(.solid, label: \"Or continue with\")",
    "PulseEmptyState": "PulseEmptyState(icon: \"tray\", title: \"No items\", message: \"Add something.\") { PulseButton(\"Add\", variant: .primary) }",
    "PulseInput": "PulseInput(\"Email\", text: $email, prompt: \"you@example.com\")",
    "PulseLabel": "PulseLabel(\"Title\", role: .title3)",
    "PulseList": "PulseList(.rounded) { PulseListRow(\"WiFi\", subtitle: \"Connected\", icon: \"wifi\", iconTint: .blue) }",
    "PulseModal": "PulseModal(isPresented: $show, style: .glass) { myContent } \n// or: myView.pulseModal(isPresented: $show) { myContent }",
    "PulseNavigationBar": "PulseNavigationBar(title: \"Discover\", subtitle: \"San Francisco\") { EmptyView() } trailing: { PulseAvatar(size: .sm) { EmptyView() } }",
    "PulseOTP": "PulseOTP(length: 6, code: $code) { code in print(code) }",
    "PulsePicker": "PulsePicker($selection, items: [PickerItem(value: \"All\", label: \"All\")], style: .segmented)",
    "PulseProgress": "PulseProgress(.linear, value: 0.68, caption: \"Uploading…\")",
    "PulseRating": "PulseRating(rating: $rating, size: 28, showsValue: true)",
    "PulseSearch": "PulseSearch(text: $query, prompt: \"Search…\", style: .glass)",
    "PulseSheet": "PulseSheet(item: $item, detents: [.medium, .large]) { item in myContent(item) }",
    "PulseSidebar": "PulseSidebar(style: .rail) { PulseSidebarItem(\"Home\", icon: \"house\", isSelected: true) {} }",
    "PulseSkeleton": "PulseSkeletonCard() \nPulseSkeleton(width: 120, height: 14)",
    "PulseSlider": "PulseSlider(\"Volume\", value: $volume, in: 0...1, step: 0.1, showsValue: true)",
    "PulseStepper": "PulseStepper($count, in: 0...100, step: 5)",
    "PulseTabBar": "PulseTabBar(selection: $tab, tabs: [TabItem(label: \"Home\", icon: \"house\")], style: .floating)",
    "PulseToast": "PulseToastCenter.shared.show(title: \"Saved\", message: \"Changes applied\", tone: .success) \n// attach: .pulseToast() on root view",
    "PulseToggle": "PulseToggle(\"Airplane mode\", isOn: $on, style: .ios)",
    "PulseSegmentedControl": "PulseSegmentedControl(selection: $selection, items: tabs)",
    "PulseTable": "PulseTable(rows, columns: [PulseTableColumn(\"Name\") { Text($0.name) }])",
    "PulseTimeline": "PulseTimeline(events)",
    "PulseTooltip": "PulseTooltip(\"More information\") { InfoButton() } tooltip: { HelpView() }",
    "PulseSpotlight": "PulseSpotlight(eyebrow: \"New\", title: \"Build momentum\") { actions }",
]

let scaf = root.appendingPathComponent("Tools/Pulse/TemplateTheme")

func componentScaffold(_ type: String) -> String {
    "// MARK: - \(type)\n\n" +
    "\(type)(\n" +
    "    // 🎛 configure\n" +
    ")\n"
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let payload = try encoder.encode(entries)

let usageLiteral = usage.sorted { $0.key < $1.key }
    .map { key, value in
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "\"\(key)\": \"\(escaped)\""
    }
    .joined(separator: ", ")

let typesLiteral = catalogTypes.sorted { $0.key < $1.key }
    .map { "\"\($0.key)\": \"\($0.value)\"" }
    .joined(separator: ", ")

let categoriesLiteral = categories.sorted { $0.key < $1.key }
    .map { "\"\($0.key)\": \"\($0.value)\"" }
    .joined(separator: ", ")

let namesLiteral = catalogTypes.keys.sorted().map { "\"\($0)\"" }.joined(separator: ", ")

let out = """
// AUTO-GENERATED — do not edit by hand.
// Run `swift Tools/Pulse/generate_embedded.swift` to regenerate.
// Embedded pack of PulseUI source files (base64) for the `pulse` CLI.
import Foundation

public struct EmbeddedFile: Codable, Sendable, Equatable {
    public let name: String
    public let relativePath: String
    public let base64: String
}

public enum EmbeddedPulse {
    public static let files: [EmbeddedFile] = try! JSONDecoder().decode([EmbeddedFile].self, from: Data(base64Encoded: "\(Data(payload).base64EncodedString())")!)

    public static let allComponentNames: [String] = [\(namesLiteral)]

    public static let catalogTypes: [String: String] = [\(typesLiteral)]

    public static let categories: [String: String] = [\(categoriesLiteral)]

    public static let usageExamples: [String: String] = [\(usageLiteral)]

    public static func content(of name: String) -> String? {
        guard let file = files.first(where: { $0.name == name }) else { return nil }
        return Data(base64Encoded: file.base64).flatMap { String(data: $0, encoding: .utf8) }
    }
}

"""

let outputURL = URL(fileURLWithPath: "Sources/PulseCLI/Resources/EmbeddedComponents.swift")
try out.write(to: outputURL, atomically: true, encoding: .utf8)

print("Embedded \(entries.count) files -> \(outputURL.path)")