import SwiftUI
import UIKit
import PulseUI

struct GalleryRootView: View {
    @Environment(\.pulseTheme) private var theme

    enum Appearance: String, CaseIterable, Identifiable {
        case light, system, dark
        var id: String { rawValue }
        var label: String { rawValue.capitalized }
        var scheme: ColorScheme? {
            switch self {
            case .light: .light
            case .system: nil
            case .dark: .dark
            }
        }
    }

    @State private var appearance: Appearance = .system
    @State private var glassOn = true
    @State private var selectedCategory = "All"
    @State private var query = ""
    @State private var selectedItem: GalleryItem?
    @State private var promoMode = false

    private var visibleItems: [GalleryItem] {
        GalleryItem.all.filter { item in
            (selectedCategory == "All" || item.category == selectedCategory)
                && (query.isEmpty || item.name.localizedCaseInsensitiveContains(query) || item.tagline.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                header
                filters
                if promoMode {
                    promoBanner
                }
                LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.lg) {
                    ForEach(visibleItems) { item in
                        GalleryCard(item: item)
                            .environment(\.galleryGlass, false)
                            .environment(\.galleryPreview, true)
                            .onTapGesture {
                                PulseHaptic.selection()
                                selectedItem = item
                            }
                    }
                }
                footer
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 48)
        }
        .animation(theme.motion.spring, value: promoMode)
        .background(
            ZStack {
                theme.colors.background
                RadialGradient(
                    colors: [theme.colors.accent.opacity(0.12), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 500
                )
            }
            .ignoresSafeArea()
        )
        .preferredColorScheme(appearance.scheme)
        .environment(\.galleryGlass, glassOn)
        .sheet(item: $selectedItem) { item in
            GalleryDetail(item: item)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(48)
                .presentationBackground(theme.colors.background)
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 190, maximum: 420), spacing: theme.spacing.lg, alignment: .top)]
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    PulseLabel("Pulse", role: .hero)
                        .foregroundStyle(theme.colors.foreground)
                    PulseLabel("UI for iOS 26 · Liquid Glass · Pure SwiftUI", role: .caption)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                }
                Spacer()
                PulseBadge("v\(PulseUI.version)", tone: .accent, style: glassOn ? .glass : .subtle, showDot: true)
            }

            HStack(spacing: theme.spacing.sm) {
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)

                Spacer()

                Toggle(isOn: $glassOn) {
                    Label(glassOn ? "Glass" : "Solid", systemImage: glassOn ? "drop.fill" : "square.fill")
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                }
                .toggleStyle(.button)
                .clipShape(Capsule())
                .pulseGlassCapsule(.interactive)

                Toggle(isOn: $promoMode) {
                    Label("Promo", systemImage: promoMode ? "sparkles.rectangle.stack.fill" : "sparkles.rectangle.stack")
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.foregroundSecondary)
                }
                .toggleStyle(.button)
                .clipShape(Capsule())
                .pulseGlassCapsule(.interactive)
            }
        }
        .padding(.top, 24)
    }

    private var promoBanner: some View {
        HStack(spacing: theme.spacing.md) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.title2)
                .foregroundStyle(theme.colors.accent)
                .symbolEffect(.pulse, options: .repeating)
            VStack(alignment: .leading, spacing: 2) {
                PulseLabel("PulseUI / Live system", role: .headline)
                PulseLabel("33 components. One native language.", role: .caption)
                    .foregroundStyle(theme.colors.foregroundSecondary)
            }
            Spacer()
            PulseBadge("iOS 26", tone: .accent, style: .glass, showDot: true)
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surfaceElevated.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
        .pulseGlass(cornerRadius: theme.radius.xl)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GalleryItem.categories, id: \.self) { category in
                    PulseChip(category, isSelected: selectedCategory == category, style: glassOn ? .glass : .tinted) {
                        PulseHaptic.selection()
                        selectedCategory = category
                    }
                }
            }
        }
        .padding(.horizontal, 1)
    }

    private var footer: some View {
        VStack(spacing: theme.spacing.sm) {
            PulseDivider(.gradient)
                .padding(.vertical, 8)
            PulseLabel("When something catches your eye, tap it.", role: .callout)
                .foregroundStyle(theme.colors.foregroundSecondary)
            PulseLabel("Copy the snippet, then add it to your app with `pulse add`.", role: .footnote)
                .foregroundStyle(theme.colors.foregroundTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Card

private struct GalleryCard: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.galleryGlass) private var glassOn
    @Environment(\.galleryPreview) private var preview
    let item: GalleryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                SceneFactory.scene(for: item.slug)
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: theme.radius.xl, topTrailingRadius: theme.radius.xl))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(theme.typography.title3.font)
                        .foregroundStyle(theme.colors.foreground)
                        .lineLimit(1)
                    Circle()
                        .fill(theme.colors.accent)
                        .frame(width: 6, height: 6)
                        .shadow(color: theme.colors.accent.opacity(0.8), radius: 4)
                    Spacer()
                    Image(systemName: "chevron.up.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(theme.colors.foregroundTertiary)
                }
                Text(item.tagline)
                    .font(theme.typography.footnote.font)
                    .foregroundStyle(theme.colors.foregroundSecondary)
                    .lineLimit(2, reservesSpace: true)
                Text(item.category.uppercased())
                    .font(theme.typography.overline.font)
                    .tracking(1.2)
                    .foregroundStyle(theme.colors.accent)
                    .padding(.top, 2)
            }
            .padding(14)
        }
        .background(
            Group {
                if glassOn {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.clear)
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(theme.colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(theme.colors.border, lineWidth: 1)
                        )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .modifier(GalleryCardGlassModifier(enabled: glassOn && !preview, radius: 28))
    }
}

private struct GalleryCardGlassModifier: ViewModifier {
    let enabled: Bool
    let radius: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content.pulseGlass(cornerRadius: radius)
        } else {
            content
        }
    }
}

// MARK: - Detail

struct GalleryDetail: View {
    @Environment(\.pulseTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    let item: GalleryItem

    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                header
                stage
                usageCard
                addCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                theme.colors.background
                RadialGradient(
                    colors: [theme.colors.accent.opacity(0.1), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                PulseBadge(item.category, tone: .accent, style: .glass)
                Spacer()
                Button {
                    PulseHaptic.selection()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(theme.colors.foregroundSecondary)
                        .frame(width: 34, height: 34)
                        .pulseGlassCapsule(.clear)
                }
                .buttonStyle(PulseIconButtonStyle())
            }
            PulseLabel(item.name, role: .hero)
                .foregroundStyle(theme.colors.foreground)
            PulseLabel(item.tagline, role: .callout)
                .foregroundStyle(theme.colors.foregroundSecondary)
        }
        .padding(.top, 20)
    }

    private var stage: some View {
        SceneFactory.scene(for: item.slug)
            .frame(height: 340)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous))
            .pulseGlass(cornerRadius: theme.radius.xl)
    }

    private var usageCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                PulseLabel("Usage", role: .headline)
                    .foregroundStyle(theme.colors.foreground)
                Spacer()
                Button {
                    withAnimation(theme.motion.springSnappy) { copied = true }
                    UIPasteboard.general.string = item.usage
                    Task {
                        try? await Task.sleep(for: .seconds(1.4))
                        withAnimation(theme.motion.springSnappy) { copied = false }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.caption.weight(.semibold))
                        Text(copied ? "Copied" : "Copy")
                            .font(theme.typography.caption.font.weight(.semibold))
                    }
                    .foregroundStyle(copied ? theme.colors.success : theme.colors.foregroundSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .pulseGlassCapsule(.interactive)
                }
                .buttonStyle(PulseIconButtonStyle())
            }

            Text(item.usage)
                .font(theme.typography.mono.font)
                .foregroundStyle(theme.colors.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                        .fill(theme.colors.surface.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .strokeBorder(theme.colors.border.opacity(0.5), lineWidth: 1)
                        )
                )
                .textSelection(.enabled)
        }
    }

    private var addCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            PulseLabel("Add to your project", role: .headline)
                .foregroundStyle(theme.colors.foreground)
            HStack(spacing: 8) {
                Text(item.addCommand)
                    .font(theme.typography.mono.font)
                    .foregroundStyle(theme.colors.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                    .strokeBorder(theme.colors.border, lineWidth: 1)
                            )
                    )
                    .textSelection(.enabled)

                Image(systemName: "terminal.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.colors.accent)
                    .frame(width: 40, height: 40)
                    .pulseGlassCapsule(.interactive)
            }
        }
    }
}