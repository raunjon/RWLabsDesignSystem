//
//  DSMenu.swift
//  RWLabsDesignSystem
//
//  Action menu matching the Figma "Option dropdown": a surface card with 12pt rows, each an
//  optional 16pt icon and a 12px label; destructive rows in the error color.
//
//  DSMenu(items: [
//      .init(title: "Select", icon: Image(systemName: "checkmark.square")) { … },
//      .init(title: "Delete", icon: Image(systemName: "trash"), role: .destructive) { … },
//  ]) {
//      Image(systemName: "ellipsis")
//  }
//
//  Presentation: .dropdown shows the Figma card in a popover; .system uses the iOS menu.
//

import SwiftUI

// MARK: - Menu Item
public enum DSMenuRole: Sendable {
    case `default`
    case destructive
}

public struct DSMenuItem {
    public let title: String
    public let icon: Image?
    public let role: DSMenuRole
    public let isDisabled: Bool
    public let isSelected: Bool
    public let isDivider: Bool
    public let submenu: [DSMenuItem]?
    public let action: (() -> Void)?

    public init(
        title: String,
        icon: Image? = nil,
        role: DSMenuRole = .default,
        isDisabled: Bool = false,
        isSelected: Bool = false,
        submenu: [DSMenuItem]? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.role = role
        self.isDisabled = isDisabled
        self.isSelected = isSelected
        self.isDivider = false
        self.submenu = submenu
        self.action = action
    }

    public static var divider: DSMenuItem {
        DSMenuItem(divider: ())
    }

    private init(divider: Void) {
        self.title = ""
        self.icon = nil
        self.role = .default
        self.isDisabled = false
        self.isSelected = false
        self.isDivider = true
        self.submenu = nil
        self.action = nil
    }
}

public enum DSMenuPresentation: Sendable {
    /// Figma option dropdown card in a popover
    case dropdown
    /// Native iOS menu
    case system
}

// MARK: - Option Dropdown
/// The Figma option dropdown card. Submenus show as a header with their items indented.
public struct DSOptionDropdown: View {
    /// Raised one step in dark mode so the card separates from the page.
    @MainActor static var surface: Color {
        Color(light: Color.Selection.surface, dark: Color.Selection.surfaceSelected)
    }

    let items: [DSMenuItem]
    let onSelect: (DSMenuItem) -> Void

    public init(items: [DSMenuItem], onSelect: @escaping (DSMenuItem) -> Void = { $0.action?() }) {
        self.items = items
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            rows(items, indent: 0)
        }
        .padding(.sm)
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: .radiusLG)
                .fill(Self.surface)
                .shadow(color: .black.opacity(0.25), radius: 9)
        )
    }

    private func rows(_ items: [DSMenuItem], indent: CGFloat) -> AnyView {
        AnyView(ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            if item.isDivider {
                Rectangle()
                    .fill(Color.Selection.border)
                    .frame(height: .thin)
            } else if let submenu = item.submenu {
                row(item, isHeader: true).padding(.leading, indent)
                rows(submenu, indent: indent + .md)
            } else {
                Button { onSelect(item) } label: {
                    row(item, isHeader: false)
                }
                .buttonStyle(.plain)
                .disabled(item.isDisabled)
                .opacity(item.isDisabled ? 0.5 : 1)
                .padding(.leading, indent)
            }
        })
    }

    private func row(_ item: DSMenuItem, isHeader: Bool) -> some View {
        let color: Color = item.role == .destructive ? .Semantic.error : .Text.primary
        return HStack(spacing: .xs) {
            if let icon = item.icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            Text(item.title)
                .fontStyle(isHeader ? .bodySmallMedium : .label)
            if item.isSelected {
                Spacer(minLength: .xs)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .semibold))
            }
        }
        .foregroundColor(color)
        .frame(minWidth: 80, alignment: .leading)
        .contentShape(Rectangle())
    }
}

// MARK: - DSMenu
public struct DSMenu<Label: View>: View {
    public typealias MenuItem = DSMenuItem
    public typealias MenuRole = DSMenuRole

    let items: [DSMenuItem]
    let presentation: DSMenuPresentation
    let label: () -> Label

    @State private var isOpen = false

    public init(
        items: [DSMenuItem],
        presentation: DSMenuPresentation = .dropdown,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.items = items
        self.presentation = presentation
        self.label = label
    }

    public var body: some View {
        switch presentation {
        case .dropdown:
            Button { isOpen = true } label: { label() }
                .buttonStyle(.plain)
                .popover(isPresented: $isOpen, arrowEdge: .top) {
                    DSOptionDropdown(items: items) { item in
                        isOpen = false
                        item.action?()
                    }
                    .presentationCompactAdaptation(.popover)
                    .presentationBackground(DSOptionDropdown.surface)
                }
        case .system:
            Menu {
                DSSystemMenuItems(items: items)
            } label: {
                label()
            }
        }
    }
}

// MARK: - System Menu Items
/// The items as native menu buttons; shared by `.system` menus and `dsContextMenu`.
private struct DSSystemMenuItems: View {
    let items: [DSMenuItem]

    var body: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            if item.isDivider {
                Divider()
            } else if let submenu = item.submenu {
                Menu {
                    DSSystemMenuItems(items: submenu)
                } label: {
                    itemLabel(item)
                }
            } else {
                Button(role: item.role == .destructive ? .destructive : nil) {
                    item.action?()
                } label: {
                    itemLabel(item)
                }
                .disabled(item.isDisabled)
            }
        }
    }

    @ViewBuilder
    private func itemLabel(_ item: DSMenuItem) -> some View {
        if item.isSelected {
            SwiftUI.Label(item.title, systemImage: "checkmark")
        } else if let icon = item.icon {
            SwiftUI.Label { Text(item.title) } icon: { icon }
        } else {
            Text(item.title)
        }
    }
}

// MARK: - Context Menu Modifier
public extension View {
    /// Long-press menu with the same items. Context menus are always native.
    func dsContextMenu(items: [DSMenuItem]) -> some View {
        contextMenu { DSSystemMenuItems(items: items) }
    }
}

// MARK: - Preview
/// Mirrors the Figma Option dropdown, then a live menu in both presentations.
private struct DSMenuGallery: View {
    private let items: [DSMenuItem] = [
        .init(title: "Label", icon: Image(systemName: "checkmark.square")),
        .init(title: "Label", icon: Image(systemName: "trash"), role: .destructive),
        .init(title: "Label", icon: Image(systemName: "plus.square"))
    ]

    var body: some View {
        VStack(spacing: .xl) {
            DSOptionDropdown(items: items)

            HStack(spacing: .lg) {
                DSMenu(items: items) {
                    Image(systemName: "ellipsis.circle").font(.title2).foregroundColor(.Icon.secondary)
                }
                DSMenu(items: items, presentation: .system) {
                    Text("System menu").fontStyle(.bodySmallMedium).foregroundColor(.Text.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSMenuGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSMenuGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSMenuGallery().designSystem()
}
