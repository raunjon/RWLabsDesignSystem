//
//  DSChip.swift
//  RWLabsDesignSystem
//
//  Pills matching the Figma "Pill" (large) and "Long Pill" (compact).
//
//    .large    16px text, 12pt padding. Unselected: 1pt border. Selected: filled, with a ✕ badge
//              on the top-right corner that deselects it.
//    .compact  14px text, 12×6 padding. Unselected: 1pt border. Selected: dark fill, light text.
//    DSInfoPill  the Long Pill "Info" state: a non-interactive tag.
//
//  Style any Toggle, so the content is yours:
//
//  Toggle(isOn: $hiking) { Text("Hiking") }
//      .pillStyle()                          // or .pillStyle(size: .compact)
//

import SwiftUI

// MARK: - Pill Size
public enum DSPillSize: Sendable {
    /// Figma "Pill"
    case large
    /// Figma "Long Pill"
    case compact

    var fontStyle: DSTypography.Style {
        self == .large ? .body : .bodySmall
    }

    var horizontalPadding: CGFloat { .sm }
    var verticalPadding: CGFloat { self == .large ? .sm : 6 }
}

// MARK: - Pill Style
public struct DSPillStyle: ToggleStyle {
    let size: DSPillSize

    public init(size: DSPillSize = .large) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        DSPillBody(configuration: configuration, size: size)
    }
}

private struct DSPillBody: View {
    let configuration: ToggleStyleConfiguration
    let size: DSPillSize

    @Environment(\.isEnabled) private var isEnabled

    private var isOn: Bool { configuration.isOn }

    private var fill: Color {
        guard isOn else { return .clear }
        return size == .large ? .Pill.selectedFill : .Pill.compactSelectedFill
    }

    private var border: Color {
        switch size {
        case .large:   isOn ? .clear : .Pill.border
        case .compact: .Pill.compactBorder
        }
    }

    private var text: Color {
        size == .compact && isOn ? .Pill.compactSelectedText : .Pill.text
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { configuration.isOn.toggle() }
        } label: {
            configuration.label
                .fontStyle(size.fontStyle)
                .foregroundColor(text)
                .lineLimit(1)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .background(Capsule().fill(fill))
                .overlay(Capsule().strokeBorder(border, lineWidth: .thin))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if size == .large && isOn {
                DSPillRemoveBadge {
                    withAnimation(.easeInOut(duration: 0.15)) { configuration.isOn = false }
                }
                .offset(x: 2, y: -6)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// The 20pt ✕ on a selected large pill.
private struct DSPillRemoveBadge: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.Pill.removeIcon)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.Pill.removeFill))
                .overlay(Circle().strokeBorder(Color.Selection.surface, lineWidth: 1.5))
                .contentShape(Circle().inset(by: -8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove")
    }
}

public extension View {
    /// Figma pill for a Toggle.
    func pillStyle(size: DSPillSize = .large) -> some View {
        toggleStyle(DSPillStyle(size: size))
    }
}

// MARK: - Info Pill
/// Figma Long Pill "Info": a read-only tag.
public struct DSInfoPill<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .fontStyle(.bodySmall)
            .foregroundColor(.Pill.text)
            .lineLimit(1)
            .padding(.horizontal, DSPillSize.compact.horizontalPadding)
            .padding(.vertical, DSPillSize.compact.verticalPadding)
            .background(Capsule().fill(Color.Pill.infoFill))
            .overlay(Capsule().strokeBorder(Color.Pill.infoBorder, lineWidth: .thin))
    }
}

public extension DSInfoPill where Content == Text {
    init(_ title: String) {
        self.init { Text(title) }
    }
}

// MARK: - DSChip
/// Convenience pill with a title, optional icon and an optional trailing ✕, built on `DSPillStyle`.
public struct DSChip: View {

    public enum Variant {
        case filled
        case outlined
    }

    let title: String
    let icon: Image?
    @Binding var isSelected: Bool
    let size: DSPillSize
    let isDismissible: Bool
    let onDismiss: (() -> Void)?

    public init(
        title: String,
        icon: Image? = nil,
        isSelected: Binding<Bool> = .constant(false),
        size: DSPillSize = .compact,
        isDismissible: Bool = false,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self._isSelected = isSelected
        self.size = size
        self.isDismissible = isDismissible
        self.onDismiss = onDismiss
    }

    @available(*, deprecated, message: "Figma has one pill look per size; use init(title:icon:isSelected:size:isDismissible:onDismiss:)")
    public init(
        title: String,
        icon: Image? = nil,
        isSelected: Binding<Bool> = .constant(false),
        isDismissible: Bool = false,
        variant: Variant,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(title: title, icon: icon, isSelected: isSelected, size: .compact,
                  isDismissible: isDismissible, onDismiss: onDismiss)
    }

    public var body: some View {
        Toggle(isOn: $isSelected) {
            HStack(spacing: .xxs) {
                if let icon {
                    icon.font(.system(size: 12))
                }
                Text(title)
                if isDismissible {
                    Button {
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(title)")
                }
            }
        }
        .pillStyle(size: size)
    }
}

// MARK: - Preview
/// Mirrors the Figma Pill and Long Pill sheets, then custom content.
private struct DSChipGallery: View {
    @State private var travel = false
    @State private var music = true
    @State private var hiking = false
    @State private var cooking = true

    var body: some View {
        VStack(alignment: .leading, spacing: .lg) {
            HStack(spacing: .sm) {
                Toggle("Travel", isOn: $travel).pillStyle()
                Toggle("Music", isOn: $music).pillStyle()
            }
            HStack(spacing: .sm) {
                Toggle("Hiking", isOn: $hiking).pillStyle(size: .compact)
                Toggle("Cooking", isOn: $cooking).pillStyle(size: .compact)
                DSInfoPill("Info")
            }
            HStack(spacing: .sm) {
                DSChip(title: "With icon", icon: Image(systemName: "star.fill"), isSelected: $music)
                DSChip(title: "Dismissible", isDismissible: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChipGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChipGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSChipGallery().designSystem()
}
