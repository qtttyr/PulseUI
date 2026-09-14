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
        case "remove":
            return CommandRemove().run(arguments: Array(args.dropFirst()))
        case "uninstall":
            return CommandUninstall().run(arguments: Array(args.dropFirst()))
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

    public static func detectXcodeProjectFolder(startingAt path: String = FileManager.default.currentDirectoryPath) -> URL? {
        var current = URL(fileURLWithPath: path, isDirectory: true)
        let fm = FileManager.default
        while true {
            if let entry = try? fm.contentsOfDirectory(at: current, includingPropertiesForKeys: nil)
                .first(where: { $0.pathExtension == "xcodeproj" }),
               fm.fileExists(atPath: entry.appendingPathComponent("project.pbxproj").path) {
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
          pulse uninstall              Remove the installed pulse CLI
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

        guard let project = PulseCLI.detectProjectFolder() ?? PulseCLI.detectXcodeProjectFolder() else {
            Console.warn("No Package.swift or Xcode project found in this folder (or any parent).")
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

        if !FileManager.default.fileExists(atPath: project.appendingPathComponent("Package.swift").path) {
            return setupXcodeProject(project: project, options: options)
        }

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
        let refreshGeneratedTheme = (try? String(contentsOf: themeURL, encoding: .utf8))
            .map { $0.contains("Generated by pulse init") } ?? false
        let didWriteTheme = (try? PulseCLI.write(
            ThemeTemplate.render(accent: options.accent, radius: options.radius),
            to: themeURL,
            overwrite: refreshGeneratedTheme
        )) ?? false
        if didWriteTheme {
            Console.ok("Generated \(relative(themeURL, to: project)) — your brand start point")
        } else {
            Console.dim("Theme scaffold already exists at \(relative(themeURL, to: project)) (kept)")
        }
        let agentsURL = project.appendingPathComponent("AGENTS.md")
        let didWriteAgents = (try? PulseCLI.write(
            AgentsTemplate.render(componentRoot: "Sources/PulseUI"),
            to: agentsURL,
            overwrite: false
        )) ?? false
        if didWriteAgents {
            Console.ok("Generated AGENTS.md — component map for humans and coding agents")
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

    private func setupXcodeProject(project: URL, options: ParsedOptions) -> Int32 {
        let root = project.appendingPathComponent("PulseUIComponents", isDirectory: true)
        do {
            for file in EmbeddedPulse.files where !EmbeddedPulse.allComponentNames.contains(file.name) {
                guard let content = EmbeddedPulse.content(of: file.name) else { continue }
                _ = try PulseCLI.write(content, to: root.appendingPathComponent(file.relativePath), overwrite: false)
            }
            let theme = ThemeTemplate.render(accent: options.accent, radius: options.radius, includeImport: false)
            let themeURL = root.appendingPathComponent("PulseUITheme.swift")
            let refreshGeneratedTheme = (try? String(contentsOf: themeURL, encoding: .utf8))
                .map { $0.contains("Generated by pulse init") } ?? false
            _ = try PulseCLI.write(theme, to: themeURL, overwrite: refreshGeneratedTheme)
            _ = try PulseCLI.write(AgentsTemplate.render(componentRoot: "PulseUIComponents"), to: project.appendingPathComponent("AGENTS.md"), overwrite: false)
        } catch {
            Console.error("Could not create PulseUI files: \(error.localizedDescription)")
            return 1
        }

        guard let xcodeproj = try? FileManager.default.contentsOfDirectory(at: project, includingPropertiesForKeys: nil)
            .first(where: { $0.pathExtension == "xcodeproj" }),
              patchXcodeProject(at: xcodeproj.appendingPathComponent("project.pbxproj")) else {
            Console.error("Could not attach PulseUIComponents to the Xcode target.")
            Console.info("The files are available in PulseUIComponents. Add that folder to the app target in Xcode.")
            return 1
        }
        let themeWasApplied = applyThemeToXcodeApp(project: project)

        Console.ok("Created PulseUIComponents with shared theme files")
        Console.ok("Attached PulseUIComponents to the Xcode target")
        if themeWasApplied {
            Console.ok("Applied the generated theme to the app root")
        }
        Console.ok("Generated AGENTS.md for humans and coding agents")
        Console.info("""

        Done. PulseUI source files are now part of the app target.
        Add components with:
          pulse add button toast alert

        Use PulseUI types directly in this Xcode target (no `import PulseUI`).
        """)
        return 0
    }

    private func applyThemeToXcodeApp(project: URL) -> Bool {
        let fm = FileManager.default
        guard let files = fm.enumerator(
            at: project,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )?.compactMap({ $0 as? URL }).filter({ $0.pathExtension == "swift" }) else {
            return false
        }

        for file in files where !file.path.contains(".xcodeproj") && !file.path.contains("Tests") {
            guard var text = try? String(contentsOf: file, encoding: .utf8),
                  text.contains("@main"),
                  text.contains("WindowGroup"),
                  !text.contains(".pulseTheme("),
                  let contentView = text.range(of: "ContentView()") else {
                continue
            }
            text.replaceSubrange(
                contentView,
                with: "ContentView()\n                .pulseTheme(pulse)"
            )
            do {
                try text.write(to: file, atomically: true, encoding: .utf8)
                return true
            } catch {
                return false
            }
        }
        return false
    }

    private func patchXcodeProject(at pbxproj: URL) -> Bool {
        guard var text = try? String(contentsOf: pbxproj, encoding: .utf8) else { return false }

        // Reuse an existing group so `pulse init` can repair a partial setup.
        let marker: String
        if let groupLine = text.split(separator: "\n").first(where: {
            $0.contains("/* PulseUIComponents */ = {")
        }) {
            marker = String(groupLine.split(separator: " ").first ?? "")
        } else {
            let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24).uppercased()
            marker = String(id)
            let group = """
            \(marker) /* PulseUIComponents */ = {
                isa = PBXFileSystemSynchronizedRootGroup;
                explicitFileTypes = {
                };
                explicitFolders = (
                );
                path = PulseUIComponents;
                sourceTree = "<group>";
            };
            """
            if let section = text.range(of: "/* Begin PBXFileSystemSynchronizedRootGroup section */") {
                text.insert(contentsOf: group, at: section.upperBound)
            } else if let section = text.range(of: "/* Begin PBXFrameworksBuildPhase section */") {
                text.insert(contentsOf: "/* Begin PBXFileSystemSynchronizedRootGroup section */\n\(group)/* End PBXFileSystemSynchronizedRootGroup section */\n\n", at: section.lowerBound)
            } else {
                return false
            }
        }

        let groupReference = "\(marker) /* PulseUIComponents */"
        if let mainGroup = text.range(of: "mainGroup = ") {
            let mainIDStart = mainGroup.upperBound
            guard let mainIDEnd = text.range(of: ";", range: mainIDStart..<text.endIndex) else { return false }
            let mainID = String(text[mainIDStart..<mainIDEnd.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let mainObject = text.range(of: "\(mainID) ") else { return false }
            guard let children = text.range(of: "children = (", range: mainObject.upperBound..<text.endIndex),
                  let childrenEnd = text.range(of: "\n\t\t\t);", range: children.upperBound..<text.endIndex) else { return false }
            let childrenBody = text[children.upperBound..<childrenEnd.lowerBound]
            if !childrenBody.contains(groupReference) {
                text.insert(contentsOf: "\n\t\t\t\t\(groupReference),", at: childrenEnd.lowerBound)
            }
        }

        // Attach the group to the application target, not the test targets.
        var searchStart = text.startIndex
        while let nativeTarget = text.range(of: "isa = PBXNativeTarget;", range: searchStart..<text.endIndex),
              let targetStart = text.range(of: "\n\t\t", options: .backwards, range: text.startIndex..<nativeTarget.lowerBound),
              let targetEnd = text.range(of: "\n\t\t};", range: nativeTarget.upperBound..<text.endIndex) {
            let targetBody = text[targetStart.lowerBound..<targetEnd.lowerBound]
            if targetBody.contains("productType = \"com.apple.product-type.application\";") {
                if let groups = targetBody.range(of: "fileSystemSynchronizedGroups = ("),
                   let groupsEnd = text.range(of: "\n\t\t\t);", range: groups.upperBound..<targetEnd.lowerBound) {
                    let groupsBody = text[groups.upperBound..<groupsEnd.lowerBound]
                    if !groupsBody.contains(groupReference) {
                        text.insert(contentsOf: "\n\t\t\t\t\(groupReference),", at: groupsEnd.lowerBound)
                    }
                } else {
                    text.insert(contentsOf: "\n\t\t\tfileSystemSynchronizedGroups = (\n\t\t\t\t\(groupReference),\n\t\t\t);", at: targetEnd.lowerBound)
                }
                break
            }
            searchStart = targetEnd.upperBound
        }
        do {
            try text.write(to: pbxproj, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
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
        resolved = dependencyClosure(for: Array(Set(resolved)))

        if !options.all {
            for entry in unknown {
                Console.error("Unknown component '\(entry)'. Try: \(suggestions(for: entry, from: available))")
            }
            if resolved.isEmpty {
                Console.info("Nothing to add. Run `pulse list` to see the catalog.")
                return 1
            }
        }

        let packageProject = PulseCLI.detectProjectFolder()
        let xcodeProject = packageProject == nil ? PulseCLI.detectXcodeProjectFolder() : nil
        let hasProject = packageProject != nil || xcodeProject != nil

        // 1. Ensure dependency (same as init) unless vendoring.
        if options.source || xcodeProject != nil {
            vendor(resolved, options: options, project: packageProject ?? xcodeProject)
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

    private func vendor(_ names: [String], options: ParsedOptions, project: URL?) {
        guard let project else {
            Console.error("Vendoring needs a Swift package or Xcode project.")
            return
        }
        let root: URL
        if PulseCLI.detectProjectFolder(startingAt: project.path) != nil {
            root = PulseCLI.vendoredRoot(project: project, dir: options.dir)
        } else {
            root = project.appendingPathComponent("PulseUIComponents")
        }
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

        if !FileManager.default.fileExists(atPath: project.appendingPathComponent("AGENTS.md").path) {
            _ = try? PulseCLI.write(AgentsTemplate.render(componentRoot: relative(root, to: project)), to: project.appendingPathComponent("AGENTS.md"), overwrite: false)
        }
        Console.ok("Vendored \(names.count) component(s) — theme + helpers ready in \(relative(root, to: project))")
        Console.info("Add that folder to your project via Xcode (red-folder reference works) or a local SPM target:")
        Console.dim("  .target(name: \"PulseUI\", path: \"\(relative(root, to: project))\", exclude: [\"Resources\"])")
    }

    private func dependencyClosure(for names: [String]) -> [String] {
        let dependencies: [String: [String]] = [
            "PulseAccordion": ["PulseDivider"],
            "PulseAlert": ["PulseBadge"],
            "PulseForm": ["PulseButton"],
            "PulseToast": ["PulseBadge"],
        ]
        var installed = Set(names)
        var pending = names
        while let name = pending.popLast() {
            for dependency in dependencies[name, default: []] where installed.insert(dependency).inserted {
                pending.append(dependency)
            }
        }
        return installed.sorted()
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
        guard let project = PulseCLI.detectProjectFolder() ?? PulseCLI.detectXcodeProjectFolder() else {
            Console.error("No Package.swift or Xcode project found in this folder or any parent.")
            return 1
        }

        let isSwiftPackage = FileManager.default.fileExists(atPath: project.appendingPathComponent("Package.swift").path)
        let packageFile = project.appendingPathComponent("Package.swift")
        let themeFile = isSwiftPackage
            ? project.appendingPathComponent("Sources/PulseUITheme.swift")
            : project.appendingPathComponent("PulseUIComponents/PulseUITheme.swift")
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

        if hasDependency && isSwiftPackage {
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

// MARK: - uninstall

struct CommandUninstall {
    func run(arguments: [String]) -> Int32 {
        let options = ParsedOptions(arguments: arguments)
        guard let executable = locateExecutable() else {
            Console.warn("The current pulse executable path could not be identified.")
            Console.info("Remove it with your package manager or delete the installed pulse binary.")
            return 1
        }
        let path = executable.standardizedFileURL.path
        let resolvedPath = executable.resolvingSymlinksInPath().standardizedFileURL.path
        let isHomebrew = resolvedPath.contains("/Cellar/") || resolvedPath.contains("/Homebrew/")

        Console.info("\npulse uninstall — remove the Pulse CLI\n")
        if isHomebrew {
            Console.info("""
            This CLI was installed by Homebrew.

            Run:
              brew uninstall pulse

            This removes the `pulse` command. Your projects and vendored
            component sources are not touched.
            """)
            Console.dim("Installed binary: \(path)")
            return 0
        }

        Console.step("Executable: \(path)")
        Console.ok("Your projects and component sources will not be changed")
        guard options.yes || Console.prompt("Remove this CLI?") else {
            Console.info("Cancelled. Nothing was changed.")
            return 0
        }

        do {
            try FileManager.default.removeItem(atPath: path)
            Console.ok("Removed pulse")
            Console.info("Open a new terminal or refresh your shell hash. Then `pulse init` will be unavailable.")
            return 0
        } catch {
            Console.error("Could not remove \(path): \(error.localizedDescription)")
            Console.info("Try: rm \(path)")
            return 1
        }
    }

    private func locateExecutable() -> URL? {
        let raw = CommandLine.arguments.first ?? ""
        let fm = FileManager.default
        if raw.contains("/") {
            let url = URL(fileURLWithPath: raw).standardizedFileURL
            return fm.isExecutableFile(atPath: url.path) ? url : nil
        }

        let paths = (ProcessInfo.processInfo.environment["PATH"] ?? "")
            .split(separator: ":")
            .map(String.init)
        for directory in paths {
            let candidate = URL(fileURLWithPath: directory).appendingPathComponent(raw)
            if fm.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
        }
        return nil
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
        } else if let folder = PulseCLI.detectXcodeProjectFolder() {
            Console.ok("Xcode project: \(folder.path)")
            let components = folder.appendingPathComponent("PulseUIComponents", isDirectory: true)
            if !FileManager.default.fileExists(atPath: components.path) {
                Console.warn("PulseUI sources missing — run `pulse init`")
            } else if let xcodeproj = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                        .first(where: { $0.pathExtension == "xcodeproj" }),
                      let projectText = try? String(contentsOf: xcodeproj.appendingPathComponent("project.pbxproj"), encoding: .utf8),
                      projectText.contains("path = PulseUIComponents;"),
                      projectText.contains("fileSystemSynchronizedGroups = (") {
                Console.ok("Vendored sources attached to the app target")
            } else {
                Console.warn("PulseUI sources are not attached to the app target — run `pulse init`")
            }
        } else {
            Console.warn("No Package.swift or Xcode project found — run `pulse init` inside an app project")
        }

        // Terminal.
        Console.ok(Console.isTTY ? "Terminal: colors on" : "Terminal: plain (no ANSI escape)")

        Console.info("\nAll good →  pulse init  then  pulse add button toast\n")
        return swiftOK ? 0 : 1
    }
}

// MARK: - Theme template

enum ThemeTemplate {
    static func render(accent: String?, radius: Int?, includeImport: Bool = true) -> String {
        let accentValue = (accent ?? "D9FE3E").replacingOccurrences(of: "#", with: "").uppercased()
        let radiusValue = min(max(radius ?? 10, 4), 24)
        let imports = includeImport ? "    import SwiftUI\n    import PulseUI\n" : "    import SwiftUI\n"
        return """
    \(imports)

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
            success: Color(light: 0x16A34A, dark: 0x4ADE80),
            warning: Color(light: 0xEA580C, dark: 0xFB923C),
            error: Color(light: 0xDC2626, dark: 0xF87171),
            info: Color(light: 0x2563EB, dark: 0x60A5FA),
            ring: Color(light: 0x\(accentValue), dark: 0x\(accentValue)),
            gradientAccent: [
                Color(light: 0x\(accentValue), dark: 0x\(accentValue)),
                Color(light: 0x46F0FF, dark: 0x46F0FF),
            ]
            // Everything else uses premium defaults — override here.
        ),
        spacing: .default,
        radius: RadiusTokens(
            sm: \(max(radiusValue - 4, 2)), md: \(radiusValue), lg: \(min(radiusValue + 4, 32)), xl: \(min(radiusValue + 10, 40)), xxl: \(min(radiusValue + 18, 48))
        ),
        typography: .default,
        motion: .default,
        elevation: .default
    )

    // Activate at app root:
    //   ContentView()
    //       .pulseTheme(pulse)
    """
    }
}

enum AgentsTemplate {
    static func render(componentRoot: String) -> String {
        """
        # PulseUI project guide

        This project uses PulseUI, a source-owned SwiftUI component system.
        The vendored sources live at `\(componentRoot)/`.

        ## Rules for humans and coding agents

        - Use the existing PulseUI components before creating a custom equivalent.
        - Keep component source changes inside `\(componentRoot)/` and app-specific
          composition in the app target's normal source folder.
        - In this Xcode project, PulseUI is vendored into the app target, so do not
          add `import PulseUI`; use the public types directly.
        - Preserve `PulseTheme`, accessibility labels, Dynamic Type and Reduce Motion.
        - Do not add Liquid Glass to ordinary content cards, tables or charts.
          Reserve it for navigation, toolbars, menus and transient surfaces.

        ## CLI workflow

        ```bash
        pulse add button card table
        pulse list
        pulse doctor
        pulse remove --yes
        ```

        `pulse add <name...>` copies component source into `\(componentRoot)/`.
        `pulse remove` removes only the integration scaffold and keeps vendored
        component files. Never delete the component folder unless the user
        explicitly asks for it.

        ## Component map

        Components are grouped below by their source folders. Search
        `\(componentRoot)/Components/` before adding new UI:

        \(EmbeddedPulse.allComponentNames.sorted().map { "- \($0)" }.joined(separator: "\n"))
        """
    }
}