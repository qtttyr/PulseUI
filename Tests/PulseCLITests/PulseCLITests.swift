import Foundation
import Testing
@testable import PulseCLI

@Suite("Embedded catalog")
struct EmbeddedCatalogTests {
    @Test("Catalog exposes all components")
    func catalogCompleteness() {
        #expect(EmbeddedPulse.allComponentNames.count == 43)
        let names = Set(EmbeddedPulse.allComponentNames)
        #expect(names.count == 43)
    }

    @Test("Every component has type, category and usage metadata")
    func metadataCompleteness() {
        for name in EmbeddedPulse.allComponentNames {
            #expect(!(EmbeddedPulse.catalogTypes[name] ?? "").isEmpty, "missing type for \(name)")
            #expect(!(EmbeddedPulse.categories[name] ?? "").isEmpty, "missing category for \(name)")
            #expect(!(EmbeddedPulse.usageExamples[name] ?? "").isEmpty, "missing usage for \(name)")
        }
    }

    @Test("Every component has embedded source content")
    func embeddedSourcesPresent() {
        for name in EmbeddedPulse.allComponentNames {
            let content = EmbeddedPulse.content(of: name)
            #expect(content != nil, "no embedded file for \(name)")
            #expect(content!.count > 300, "unexpectedly small file for \(name)")
        }
    }

    @Test("Shared theme/utilities are embedded")
    func sharedFilesPresent() {
        for name in ["PulseTheme", "PulseColorToken", "PulseMotionToken", "PulseUtilities", "GlassEffect"] {
            #expect(EmbeddedPulse.content(of: name) != nil, "missing shared file \(name)")
        }
    }

    @Test("Button source is the real PulseButton")
    func buttonSourceIsReal() {
        let content = EmbeddedPulse.content(of: "PulseButton") ?? ""
        #expect(content.contains("public struct PulseButton"))
        #expect(content.contains("pulseEntrance"))
    }

    @Test("Usage examples reference the exported type")
    func usageMatchesType() {
        let name = "PulseButton"
        let type = EmbeddedPulse.catalogTypes[name] ?? ""
        let usage = EmbeddedPulse.usageExamples[name] ?? ""
        #expect(usage.hasPrefix(type + "("))
    }
}

@Suite("CLI logic")
struct CLILogicTests {
    @Test("Detects the package root from the current folder")
    func detectsPackageRoot() {
        let cwd = FileManager.default.currentDirectoryPath
        let detected = PulseCLI.detectProjectFolder(startingAt: cwd)
        #expect(detected != nil)
        #expect(FileManager.default.fileExists(atPath: detected!.appendingPathComponent("Package.swift").path))
    }

    @Test("Usage card prints type, category and usage")
    func usageCardShape() {
        let card = PulseCLI.usageCard(name: "PulseButton")
        #expect(card.contains("PulseButton"))
        #expect(card.contains("Actions"))
        #expect(card.contains("PulseButton("))
    }

    @Test("Slug resolution maps short names to components")
    func slugResolution() {
        let available = Set(EmbeddedPulse.allComponentNames)
        let cmd = CommandAdd()
        #expect(cmd.resolve("button", in: available) == "PulseButton")
        #expect(cmd.resolve("PulseButton", in: available) == "PulseButton")
        #expect(cmd.resolve("pulsebutton", in: available) == "PulseButton")
        #expect(cmd.resolve("otp", in: available) == "PulseOTP")
        #expect(cmd.resolve("date range", in: available) == "PulseDateRange")
        #expect(cmd.resolve("nope", in: available) == nil)
    }

    @Test("Suggestions catch a typo close to a slug")
    func typoSuggestions() {
        let available = Set(EmbeddedPulse.allComponentNames)
        let cmd = CommandAdd()
        let suggestion = cmd.suggestions(for: "buton", from: available)
        #expect(suggestion.contains("PulseButton"))
        let none = cmd.suggestions(for: "zzzzzz", from: available)
        #expect(none == "pulse list")
    }
}