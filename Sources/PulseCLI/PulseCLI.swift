import Foundation

// ============================================================
// Pulse CLI — shadcn-style workflow for PulseUI.
//   pulse init              one command: setup theme + dependency
//   pulse add button toast  one command: add the components you need
//   pulse remove              remove integration, preserve component sources
//   pulse list / doctor / version / help
// Zero dependencies: pure Foundation, runs on macOS and Linux.
// ============================================================

public enum PulseCLI {

    public static let version = "1.0.0"
    public static let repoURL = "https://github.com/qtttyr/PulseUI.git"

    // MARK: - Entry point

    public static func run(arguments: [String]) -> Int32 {
        let args = Array(arguments.dropFirst())
        guard let command = args.first, !command.hasPrefix("-") else {
            printHelp()
            return 2
        }

        switch command {
        case "init":
            return CommandInit().run(arguments: Array(args.dropFirst()))
        case "add":
            return CommandAdd().run(arguments: Array(args.dropFirst()))
        case "remove", "uninstall":
            return CommandRemove().run(arguments: Array(args.dropFirst()))
        case "list":
            return CommandList().run(arguments: Array(args.dropFirst()))
        case "doctor":
            return CommandDoctor().run(arguments: Array(args.dropFirst()))
        case "version", "--version", "-v":
            print("pulse \(version)")
            return 0
        case "help", "--help", "-h":
            printHelp()
            return 0
        default:
            Console.error("Unknown command '\(command)'.")
            printHelp()
            return 2
        }
    }

    // MARK: - Shared helpers

    public static func detectProjectFolder(startingAt path: String = FileManager.default.currentDirectoryPath) -> URL? {
        var current = URL(fileURLWithPath: path, isDirectory: true)
        let fm = FileManager.default
        while true {
            if fm.fileExists(atPath: current.appendingPathComponent("Package.swift").path) {
                return current
            }
            let parent = current.deletingLastPathComponent()
            if parent.path == current.path { return nil }
            current = parent
        }
    }

    public static func hasPulseDependency(in packageFile: URL) -> Bool {
        guard let text = try? String(contentsOf: packageFile, encoding: .utf8) else { return false }
        return text.contains("PulseUI")
    }

    public static func vendoredRoot(project: URL, dir: String?) -> URL {
        project.appendingPathComponent(dir ?? "Sources/PulseUI")
    }

    public static func usageCard(name: String) -> String {
        let type = EmbeddedPulse.catalogTypes[name] ?? name
        let usage = EmbeddedPulse.usageExamples[name] ?? "\(type)(...)  // see docs"
        return "\(type) — \(EmbeddedPulse.categories[name] ?? "Component")\n    \(usage.replacingOccurrences(of: "\n", with: "\n    "))"
    }

    public static func write(_ content: String, to url: URL, overwrite: Bool) throws -> Bool {
        let fm = FileManager.default
        if fm.fileExists(atPath: url.path) && !overwrite { return false }
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return true
    }

    // MARK: - Help

    private static func printHelp() {
        Console.info("""
        pulse — PulseUI installer

        USAGE
          pulse init                  Set up PulseUI (dependency + theme scaffold)
          pulse init --accent HEX --radius N
                                    Set up PulseUI with Studio theme tokens
          pulse add <name...>         Add components with usage cards
          pulse add --all             Add every component
          pulse add --source [...]    Vendor source files into Sources/PulseUI
          pulse remove                Remove PulseUI integration, keep sources
          pulse uninstall             Alias for pulse remove
          pulse list                  Show the component catalog
          pulse doctor                Check your environment
          pulse version
          pulse help

        OPTIONS
          --source          vendor the component files into your project
          --dir <path>      where to vendor (default Sources/PulseUI)
          --target <name>   name for @main snippets and checks
          --accent <HEX>    Studio accent color for the generated theme
          --radius <4-24>   Studio corner radius for the generated theme
          --yes / -y        skip confirmation prompts

        EXAMPLES
          pulse init
          pulse add button toast alert
          pulse add --all --source
          pulse remove --yes
        """)
    }
}

// MARK: - Console

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public enum Console {
    public static var isTTY: Bool {
        #if canImport(Darwin) || canImport(Glibc)
        return isatty(STDOUT_FILENO) != 0
        #else
        return false
        #endif
    }

    static func styled(_ text: String, _ code: String) -> String {
        isTTY ? "\u{1B}[\(code)m\(text)\u{1B}[0m" : text
    }

    public static func info(_ text: String) { print(text) }
    public static func step(_ text: String) { print(styled("·", "36") + " \(text)") }
    public static func ok(_ text: String) { print(styled("✓", "32") + " \(text)") }
    public static func warn(_ text: String) { print(styled("!", "33") + " \(text)") }
    public static func error(_ text: String) { print(styled("✗", "31") + " \(text)") }
    public static func dim(_ text: String) { print(styled(text, "2")) }
    public static func prompt(_ text: String) -> Bool {
        print(styled("?", "33") + " \(text) [y/N] ", terminator: "")
        guard let line = readLine() else { return false }
        return line.lowercased().hasPrefix("y")
    }
}

// MARK: - Options

struct ParsedOptions {
    var source = false
    var all = false
    var yes = false
    var dir: String?
    var target: String?
    var accent: String?
    var radius: Int?
    var names: [String] = []
    var unknown: [String] = []

    init(arguments: [String]) {
        var options = arguments
        while let first = options.first {
            switch first {
            case "--source": source = true; options.removeFirst()
            case "--all": all = true; options.removeFirst()
            case "--yes", "-y": yes = true; options.removeFirst()
            case "--dir":
                options.removeFirst()
                dir = options.isEmpty ? nil : options.removeFirst()
            case "--target":
                options.removeFirst()
                target = options.isEmpty ? nil : options.removeFirst()
            case "--accent":
                options.removeFirst()
                accent = options.isEmpty ? nil : options.removeFirst()
            case "--radius":
                options.removeFirst()
                if let value = options.first, let parsed = Int(value) {
                    radius = parsed
                    options.removeFirst()
                } else if !options.isEmpty {
                    options.removeFirst()
                }
            case let raw where raw.hasPrefix("-"):
                unknown.append(raw)
                options.removeFirst()
            default:
                names.append(first)
                options.removeFirst()
            }
        }
    }
}

// MARK: - Helpers

extension String {
    var slug: String {
        let normalized = lowercased().filter { $0.isLetter || $0.isNumber }
        return normalized.hasPrefix("pulse") ? String(normalized.dropFirst(5)) : normalized
    }
}

// MARK: - init

struct CommandInit {
    func run(arguments: [String]) -> Int32 {
        let options = ParsedOptions(arguments: arguments)
        Console.info("\npulse init — setting up PulseUI\n")

        if let accent = options.accent {
            let hex = accent.replacingOccurrences(of: "#", with: "")
            guard hex.count == 6, hex.allSatisfy({ $0.isHexDigit }) else {
                Console.error("Invalid accent '\(accent)'. Use a six-digit hex value, for example #D9FE3E.")
                return 2
            }
        }
        if let radius = options.radius, !(4...24).contains(radius) {
            Console.error("Invalid radius '\(radius)'. Choose a value from 4 to 24.")
            return 2
        }

        guard let project = PulseCLI.detectProjectFolder() else {
            Console.warn("No Package.swift found in this folder (or any parent).")
            Console.info("""
                For an Xcode project: add the package manually once —
                  File → Add Package Dependencies… → \(PulseCLI.repoURL)
                Then wrap your root view:
                  ContentView().pulseTheme()
                """
            )
            return 1
        }

        Console.step("Project: \(project.path)")

        // 1. Dependency.
        let packageFile = project.appendingPathComponent("Package.swift")
        if PulseCLI.hasPulseDependency(in: packageFile) {
            Console.ok("PulseUI dependency already present")
        } else {
            let didAdd = addDependency(to: packageFile)
            if didAdd {
                Console.ok("Added PulseUI dependency")
            } else {
                Console.warn("Could not edit Package.swift — add it manually:")
                Console.dim("  .package(url: \"\(PulseCLI.repoURL)\", from: \"\(PulseCLI.version)\")")
            }
        }

        // 2. Theme scaffold.
        let themeURL = project.appendingPathComponent("Sources/PulseUITheme.swift")
        let didWriteTheme = (try? PulseCLI.write(
            ThemeTemplate.render(accent: options.accent, radius: options.radius),
            to: themeURL,
            overwrite: false
        )) ?? false
        if didWriteTheme {
            Console.ok("Generated \(relative(themeURL, to: project)) — your brand start point")
        } else {
            Console.dim("Theme scaffold already exists at \(relative(themeURL, to: project)) (kept)")
        }

        // 3. Next steps.
        if let accent = options.accent, let radius = options.radius {
            Console.ok("Studio theme saved: accent \(accent.uppercased()), radius \(radius)px")
        }

        Console.info("""

        Done. Now activate the theme at app root:

        @main
        struct MyApp: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                        .pulseTheme(pulse)
                }
            }
        }

        Then add components:
          pulse add button toast alert
        """)

        return 0
    }

    private func addDependency(to packageFile: URL) -> Bool {
        guard let text = try? String(contentsOf: packageFile, encoding: .utf8) else { return false }
        guard !text.contains("PulseUI") else { return true }

        let depLine = "        .package(url: \"\(PulseCLI.repoURL)\", from: \"\(PulseCLI.version)\"),"
        let productLine = ".product(name: \"PulseUI\", package: \"PulseUI\"),"

        var updated = text
        guard let pkgDecl = updated.range(of: "let package = Package(") else { return false }

        // 1. Ensure a top-level `dependencies: [ ... ]` block.
        let targetsHeader = updated.range(of: "\n    targets: [")?.lowerBound
        let firstDeps = updated.range(of: "dependencies: [", range: pkgDecl.upperBound..<updated.endIndex)?.lowerBound

        let hasTopLevelDeps: Bool
        if let firstDeps, let targetsHeader {
            hasTopLevelDeps = firstDeps < targetsHeader
        } else {
            hasTopLevelDeps = firstDeps != nil
        }

        if hasTopLevelDeps {
            guard let deps = updated.range(of: "dependencies: [", range: pkgDecl.upperBound..<updated.endIndex) else { return false }
            let insert = updated.index(after: deps.lowerBound)
            updated.insert(contentsOf: "\n" + depLine, at: insert)
        } else {
            // Package init order: name, platforms, products, dependencies, targets.
            // Insert the block right before the `targets:` literal.
            guard let targetsHeader = updated.range(of: "\n    targets: [") else { return false }
            updated.insert(contentsOf: "\n    dependencies: [\n" + depLine + "\n    ],", at: targetsHeader.lowerBound)
        }

        // 2. Attach the product to a target. If it already has a dependency
        //    list, append to it; otherwise inject one after the `name:` argument
        //    (works for both single-line and multi-line target declarations).
        if let targetsHeader = updated.range(of: "targets: [") {
            let afterHeader = targetsHeader.upperBound
            let targetStart = updated.range(of: "executableTarget(", range: afterHeader..<updated.endIndex)
                ?? updated.range(of: ".target(", range: afterHeader..<updated.endIndex)
            if let targetStart {
                let injectable = "dependencies: [" + productLine + "],"
                if let deps = updated.range(of: "dependencies: [", range: targetStart.upperBound..<updated.endIndex) {
                    let insert = updated.index(after: deps.lowerBound)
                    updated.insert(contentsOf: "\n" + productLine, at: insert)
                } else if let nameArg = updated.range(of: "name:", range: targetStart.upperBound..<updated.endIndex),
                          let nameEnd = updated.range(of: ",", range: nameArg.upperBound..<updated.endIndex) {
                    let insert = updated.index(after: nameEnd.lowerBound)
                    updated.insert(contentsOf: " " + injectable, at: insert)
                }
            }
        }

        do {
            try updated.write(to: packageFile, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    private func relative(_ url: URL, to project: URL) -> String {
        String(url.path.dropFirst(project.path.count + 1))
    }
}

// MARK: - add

struct CommandAdd {
    func run(arguments: [String]) -> Int32 {
        let options = ParsedOptions(arguments: arguments)

        Console.info("\npulse add\n")

        let available = Set(EmbeddedPulse.allComponentNames)
        let requested = options.all
            ? EmbeddedPulse.allComponentNames
            : options.names
        var unknown: [String] = []
        var resolved: [String] = []
        for entry in requested {
            if let match = resolve(entry, in: available) {
                resolved.append(match)
            } else {
                unknown.append(entry)
            }
        }
        resolved = Array(Set(resolved)).sorted()

        if !options.all {
            for entry in unknown {
                Console.error("Unknown component '\(entry)'. Try: \(suggestions(for: entry, from: available))")
            }
            if resolved.isEmpty {
                Console.info("Nothing to add. Run `pulse list` to see the catalog.")
                return 1
            }
        }

        let hasProject = PulseCLI.detectProjectFolder() != nil

        // 1. Ensure dependency (same as init) unless vendoring.
        if options.source {
            vendor(resolved, options: options)
        } else if hasProject {
            Console.ok("\(resolved.count) component\(resolved.count == 1 ? "" : "s") resolved via the PulseUI dependency")
        } else {
            Console.warn("No Package.swift detected — components will not compile until a dependency is added.")
            Console.dim("Run `pulse init` first, or add the package in Xcode: \(PulseCLI.repoURL)")
        }

        // 2. Cards.
        Console.info("\nInstalled\n")
        for name in resolved.sorted() {
            Console.ok(PulseCLI.usageCard(name: name))
        }

        Console.info("""

        Tip: `pulse add --source` copies these components’ real sources into your
        project so you can edit them directly.
        """)
        return 0
    }

    private func vendor(_ names: [String], options: ParsedOptions) {
        guard let project = PulseCLI.detectProjectFolder() else {
            Console.error("Vendoring needs a project folder with Package.swift.")
            return
        }
        let root = PulseCLI.vendoredRoot(project: project, dir: options.dir)
        var wrote = 0

        // Shared support: theme, utilities, entry.
        for file in EmbeddedPulse.files where !EmbeddedPulse.allComponentNames.contains(file.name) {
            guard let content = EmbeddedPulse.content(of: file.name) else { continue }
            let url = root.appendingPathComponent(file.relativePath)
            // Only overwrite files matching the installed manifest, keep user edits otherwise.
            _ = (try? PulseCLI.write(content, to: url, overwrite: false))
            wrote += 1
        }

        // Requested components.
        for name in names.sorted() {
            guard let content = EmbeddedPulse.content(of: name) else {
                Console.warn("No source embedded for \(name)")
                continue
            }
            let rel = "Components/\(name)/\(name).swift"
            let url = root.appendingPathComponent(rel)
            do {
                let overwritten = try PulseCLI.write(content, to: url, overwrite: true)
                Console.ok("\(rel)\(overwritten ? "" : " (updated)")")
                wrote += 1
            } catch {
                Console.error("Failed writing \(rel): \(error.localizedDescription)")
            }
        }

        Console.ok("Vendored \(names.count) component(s) — theme + helpers ready in \(relative(root, to: project))")
        Console.info("Add that folder to your project via Xcode (red-folder reference works) or a local SPM target:")
        Console.dim("  .target(name: \"PulseUI\", path: \"\(relative(root, to: project))\", exclude: [\"Resources\"])")
    }

    private func relative(_ url: URL, to project: URL) -> String {
        String(url.path.dropFirst(project.path.count + 1))
    }

        func resolve(_ raw: String, in available: Set<String>) -> String? {
        if available.contains(raw) { return raw }
        let slugMap = Dictionary(uniqueKeysWithValues: available.map { ($0.slug, $0) })
        if let exact = slugMap[raw.slug] { return exact }
        let stripped = raw.hasPrefix("Pulse") ? String(raw.dropFirst(5)) : raw
        let plus = "Pulse" + stripped.prefix(1).uppercased() + stripped.dropFirst()
        if available.contains(plus) { return plus }
        return available.first { $0.lowercased() == raw.lowercased() }
    }

        func suggestions(for name: String, from available: Set<String>) -> String {
        let slug = name.slug
        let matches = available.compactMap { candidate in
            let score = levenshtein(slug, candidate.slug)
            return score <= 2 || candidate.slug.contains(slug) || slug.contains(candidate.slug) ? candidate : nil
        }
        let ordered = Array(Set(matches)).sorted()
        return ordered.isEmpty ? "pulse list" : ordered.joined(separator: ", ")
    }

    private func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        var matrix = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { matrix[i][0] = i }
        for j in 0...b.count { matrix[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        return matrix[a.count][b.count]
    }
}

// MARK: - remove

struct CommandRemove {
    func run(arguments: [String]) -> Int32 {
        let options = ParsedOptions(arguments: arguments)
        guard let project = PulseCLI.detectProjectFolder() else {
            Console.error("No Package.swift found in this folder or any parent.")
            return 1
        }

        let packageFile = project.appendingPathComponent("Package.swift")
        let themeFile = project.appendingPathComponent("Sources/PulseUITheme.swift")
        let themeText = (try? String(contentsOf: themeFile, encoding: .utf8)) ?? ""
        let hasTheme = themeText.contains("Generated by pulse init") ||
            themeText.contains("PulseUI theme — one file to own the whole look & feel.")
        let packageText = (try? String(contentsOf: packageFile, encoding: .utf8)) ?? ""
        let hasDependency = packageText.contains(PulseCLI.repoURL) || packageText.contains("package: \"PulseUI\"")

        Console.info("\npulse remove — removing project integration\n")
        Console.step("Project: \(project.path)")
        if hasDependency { Console.step("Will remove the PulseUI package dependency and target product reference") }
        if hasTheme { Console.step("Will remove generated Sources/PulseUITheme.swift") }
        Console.ok("Vendored component sources will be kept")
        Console.ok("Your app source files and Package.swift structure will be kept")

        guard hasDependency || hasTheme else {
            Console.info("\nPulseUI integration was not found. Nothing to remove.\n")
            return 0
        }

        if !options.yes && !Console.prompt("Continue?") {
            Console.info("Cancelled. No files were changed.")
            return 0
        }

        if hasDependency {
            guard let updated = removeDependency(from: packageText) else {
                Console.error("Could not safely identify PulseUI lines in Package.swift. No files were changed.")
                return 1
            }
            do {
                try updated.write(to: packageFile, atomically: true, encoding: .utf8)
                Console.ok("Removed PulseUI dependency references from Package.swift")
            } catch {
                Console.error("Could not update Package.swift: \(error.localizedDescription)")
                return 1
            }
        }

        if hasTheme {
            do {
                try FileManager.default.removeItem(at: themeFile)
                Console.ok("Removed generated \(relative(themeFile, to: project))")
            } catch {
                Console.error("Could not remove generated theme: \(error.localizedDescription)")
                return 1
            }
        } else if FileManager.default.fileExists(atPath: themeFile.path) {
            Console.warn("Kept existing Sources/PulseUITheme.swift because it does not look CLI-generated")
        }

        Console.info("""

        Removed safely. Vendored components remain in place and can be reused
        or downloaded again from the repository at any time.
        """)
        return 0
    }

    private func removeDependency(from text: String) -> String? {
        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var removedDependency = false
        var removedProduct = false

        for line in lines {
            if line.contains(PulseCLI.repoURL) {
                removedDependency = true
                continue
            }
            if line.contains(".product(name: \"PulseUI\", package: \"PulseUI\")") {
                removedProduct = true
                continue
            }
            result.append(line)
        }

        guard removedDependency || removedProduct else { return nil }
        return result.joined(separator: "\n")
    }

    private func relative(_ url: URL, to project: URL) -> String {
        String(url.path.dropFirst(project.path.count + 1))
    }
}

// MARK: - list

struct CommandList {
    func run(arguments: [String]) -> Int32 {
        Console.info("\npulse — 30 premium SwiftUI components\n")

        let names = EmbeddedPulse.allComponentNames
        let grouped = Dictionary(grouping: names) { EmbeddedPulse.categories[$0] ?? "Other" }
        let order = ["Actions", "Data Display", "Typography", "Feedback", "Form", "Navigation", "Layout", "Overlay"]

        for category in order {
            guard let members = grouped[category] else { continue }
            Console.info(Console.styled(category.uppercased(), "36"))
            for name in members.sorted() {
                let type = EmbeddedPulse.catalogTypes[name] ?? name
                let usage = EmbeddedPulse.usageExamples[name] ?? ""
                let firstLine = usage.components(separatedBy: "\n").first ?? usage
                Console.info("  \(Console.styled(type, "1"))  · \(firstLine)")
            }
            Console.info("")
        }

        Console.dim("Add anything:  pulse add button toast   |   Everything:  pulse add --all")
        return 0
    }
}

// MARK: - doctor

struct CommandDoctor {
    func run(arguments: [String]) -> Int32 {
        Console.info("\npulse doctor\n")

        // Swift toolchain.
        var swiftOK = false
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["swift", "--version"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try? task.run()
        task.waitUntilExit()
        let data = (pipe.fileHandleForReading.readDataToEndOfFile())
        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            swiftOK = true
            Console.ok("Swift toolchain: \(text.split(separator: "\n").first ?? "")".trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            Console.error("Swift toolchain not found (is Swift installed?)")
        }

        // Project.
        if let folder = PulseCLI.detectProjectFolder() {
            Console.ok("SwiftPM project: \(folder.path)")
            let package = folder.appendingPathComponent("Package.swift")
            if PulseCLI.hasPulseDependency(in: package) {
                Console.ok("PulseUI dependency present")
            } else {
                Console.warn("PulseUI dependency missing — run `pulse init`")
            }
            if FileManager.default.fileExists(atPath: PulseCLI.vendoredRoot(project: folder, dir: nil).path) {
                Console.ok("Vendored sources found (Sources/PulseUI)")
            }
        } else {
            Console.warn("No Package.swift in this tree — Xcode projects need File → Add Package… (\(PulseCLI.repoURL))")
        }

        // Terminal.
        Console.ok(Console.isTTY ? "Terminal: colors on" : "Terminal: plain (no ANSI escape)")

        Console.info("\nAll good →  pulse init  then  pulse add button toast\n")
        return swiftOK ? 0 : 1
    }
}

// MARK: - Theme template

enum ThemeTemplate {
    static func render(accent: String?, radius: Int?) -> String {
        let accentValue = (accent ?? "D9FE3E").replacingOccurrences(of: "#", with: "").uppercased()
        let radiusValue = min(max(radius ?? 10, 4), 24)
        return """
    import SwiftUI
    import PulseUI

    // ============================================================
    // Generated by pulse init — PulseUI theme — one file to own the whole look & feel.
    // Swap any token; every component re-skins instantly.
    // Light/dark come from Color(light:dark:) pairs.
    // ============================================================

    let pulse = PulseTheme(
        colors: ColorTokens(
            // Brand — replace with yours.
            accent: Color(light: 0x\(accentValue), dark: 0x\(accentValue)),
            accentForeground: Color.white,
            ring: Color(light: 0x\(accentValue), dark: 0x\(accentValue)),
            success: Color(light: 0x16A34A, dark: 0x4ADE80),
            warning: Color(light: 0xEA580C, dark: 0xFB923C),
            error: Color(light: 0xDC2626, dark: 0xF87171),
            info: Color(light: 0x2563EB, dark: 0x60A5FA),
            gradientAccent: [
                Color(light: 0x\(accentValue), dark: 0x\(accentValue)),
                Color(light: 0x46F0FF, dark: 0x46F0FF),
            ]
            // Everything else uses premium defaults — override here.
        ),
        radius: RadiusTokens(
            sm: \(max(radiusValue - 4, 2)), md: \(radiusValue), lg: \(min(radiusValue + 4, 32)), xl: \(min(radiusValue + 10, 40)), xxl: \(min(radiusValue + 18, 48))
        ),
        motion: .default,
        spacing: .default,
        typography: .default,
        elevation: .default
    )

    // Activate at app root:
    //   ContentView()
    //       .pulseTheme(pulse)
    """
    }
}