//
//  DSMenu.swift
//  RWLDesignSystem
//
//  Context menu and dropdown menu component
//

import SwiftUI

// MARK: - DSMenu

public struct DSMenu<Label: View>: View {
    let items: [MenuItem]
    let label: () -> Label

    public init(
        items: [MenuItem],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.items = items
        self.label = label
    }

    public var body: some View {
        Menu {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                menuButton(for: item)
            }
        } label: {
            label()
        }
    }

    @ViewBuilder
    private func menuButton(for item: MenuItem) -> AnyView {
        AnyView(ZStack {
            if let submenu = item.submenu {
                AnyView(
                    Menu {
                        ForEach(Array(submenu.enumerated()), id: \.offset) { _, subItem in
                            menuButton(for: subItem)
                        }
                    } label: {
                        itemLabel(for: item)
                    }
                )
            } else if item.isDivider {
                AnyView(Divider())
            } else {
                AnyView(
                    Button(role: item.role == .destructive ? .destructive : nil, action: {
                        item.action?()
                    }) {
                        itemLabel(for: item)
                    }
                        .disabled(item.isDisabled)
                )
            }
        })
    }

    @ViewBuilder
    private func itemLabel(for item: MenuItem) -> some View {
        HStack {
            if let icon = item.icon {
                icon
            }

            Text(item.title)

            if item.isSelected {
                Spacer()
                Image(systemName: "checkmark")
            }
        }
    }

    public struct MenuItem {
        public let title: String
        public let icon: Image?
        public let role: MenuRole
        public let isDisabled: Bool
        public let isSelected: Bool
        public let isDivider: Bool
        public let submenu: [MenuItem]?
        public let action: (() -> Void)?

        public init(
            title: String,
            icon: Image? = nil,
            role: MenuRole = .default,
            isDisabled: Bool = false,
            isSelected: Bool = false,
            submenu: [MenuItem]? = nil,
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

        public static var divider: MenuItem {
            MenuItem(title: "", isDivider: true, action: nil)
        }

        private init(title: String, isDivider: Bool, action: (() -> Void)?) {
            self.title = title
            self.icon = nil
            self.role = .default
            self.isDisabled = false
            self.isSelected = false
            self.isDivider = isDivider
            self.submenu = nil
            self.action = action
        }
    }

    public enum MenuRole {
        case `default`
        case destructive
    }
}

// MARK: - Context Menu Modifier

public extension View {
    func dsContextMenu(items: [DSMenu<AnyView>.MenuItem]) -> some View {
        self.contextMenu {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                if item.isDivider {
                    Divider()
                } else if let submenu = item.submenu {
                    Menu {
                        ForEach(Array(submenu.enumerated()), id: \.offset) { _, subItem in
                            Button(action: {
                                subItem.action?()
                            }) {
                                HStack {
                                    if let icon = subItem.icon {
                                        icon
                                    }
                                    Text(subItem.title)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            if let icon = item.icon {
                                icon
                            }
                            Text(item.title)
                        }
                    }
                } else {
                    Button(role: item.role == .destructive ? .destructive : nil, action: {
                        item.action?()
                    }) {
                        HStack {
                            if let icon = item.icon {
                                icon
                            }
                            Text(item.title)
                        }
                    }
                    .disabled(item.isDisabled)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic Menu") {
    struct PreviewWrapper: View {
        @State private var sortOrder = "Name"

        var body: some View {
            VStack(spacing: .xl) {
                DSMenu(items: [
                    .init(
                        title: "Edit",
                        icon: Image(systemName: "pencil"),
                        action: { print("Edit") }
                    ),
                    .init(
                        title: "Duplicate",
                        icon: Image(systemName: "doc.on.doc"),
                        action: { print("Duplicate") }
                    ),
                    .divider,
                    .init(
                        title: "Delete",
                        icon: Image(systemName: "trash"),
                        role: .destructive,
                        action: { print("Delete") }
                    )
                ]) {
                    DSButton(title: "Actions", variant: .outline) {}
                }

                DSText("Selected: \(sortOrder)", style: .caption, color: .Text.secondary)

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Menu with Submenu") {
    VStack(spacing: .xl) {
        DSMenu(items: [
            .init(
                title: "Sort By",
                icon: Image(systemName: "arrow.up.arrow.down"),
                submenu: [
                    .init(title: "Name", isSelected: true, action: { print("Sort by Name") }),
                    .init(title: "Date", action: { print("Sort by Date") }),
                    .init(title: "Size", action: { print("Sort by Size") })
                ]
            ),
            .init(
                title: "Filter",
                icon: Image(systemName: "line.3.horizontal.decrease.circle"),
                submenu: [
                    .init(title: "All", action: { print("All") }),
                    .init(title: "Active", action: { print("Active") }),
                    .init(title: "Completed", action: { print("Completed") })
                ]
            ),
            .divider,
            .init(
                title: "Share",
                icon: Image(systemName: "square.and.arrow.up"),
                action: { print("Share") }
            )
        ]) {
            DSButton(title: "More Options", variant: .secondary) {}
        }

        Spacer()
    }
    .padding()
}

#Preview("Context Menu") {
    struct PreviewWrapper: View {
        var body: some View {
            VStack(spacing: .xl) {
                DSCard(elevation: .medium) {
                    VStack(alignment: .leading, spacing: .sm) {
                        DSText("Long Press Me", style: .headline, color: .Text.primary)
                        DSText("Or right-click on macOS", style: .bodySmall, color: .Text.secondary)
                    }
                }
                .dsContextMenu(items: [
                    .init(
                        title: "Copy",
                        icon: Image(systemName: "doc.on.doc"),
                        action: { print("Copy") }
                    ),
                    .init(
                        title: "Share",
                        icon: Image(systemName: "square.and.arrow.up"),
                        action: { print("Share") }
                    ),
                    .divider,
                    .init(
                        title: "Delete",
                        icon: Image(systemName: "trash"),
                        role: .destructive,
                        action: { print("Delete") }
                    )
                ])

                DSText("Long press or right-click the card above", style: .caption, color: .Text.secondary)

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

