//
//  DSTabBar.swift
//  RWLDesignSystem
//
//  Custom tab bar component with badge support
//

import SwiftUI

// MARK: - DSTabBar

public struct DSTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabItem]
    let style: TabBarStyle

    public init(
        selectedTab: Binding<Int>,
        items: [TabItem],
        style: TabBarStyle = .default
    ) {
        self._selectedTab = selectedTab
        self.items = items
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                TabBarButton(
                    item: item,
                    isSelected: selectedTab == index,
                    style: style,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    }
                )
            }
        }
        .frame(height: 60)
        .background(style.backgroundColor)
        .overlay(
            Rectangle()
                .fill(Color.Border.subtle)
                .frame(height: 0.5),
            alignment: .top
        )
    }

    public struct TabItem {
        public let icon: Image
        public let selectedIcon: Image?
        public let title: String
        public let badge: Int?

        public init(
            icon: Image,
            selectedIcon: Image? = nil,
            title: String,
            badge: Int? = nil
        ) {
            self.icon = icon
            self.selectedIcon = selectedIcon
            self.title = title
            self.badge = badge
        }
    }

    public enum TabBarStyle {
        case `default`
        case minimal
        case floating

        @MainActor
        var backgroundColor: Color {
            switch self {
            case .default, .minimal:
                return Color.Background.primary
            case .floating:
                return Color.Background.secondary
            }
        }

        var showTitle: Bool {
            switch self {
            case .default:
                return true
            case .minimal, .floating:
                return false
            }
        }
    }
}

// MARK: - Tab Bar Button

private struct TabBarButton: View {
    let item: DSTabBar.TabItem
    let isSelected: Bool
    let style: DSTabBar.TabBarStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: .xxs) {
                ZStack(alignment: .topTrailing) {
                    // Icon
                    (isSelected && item.selectedIcon != nil ? item.selectedIcon! : item.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? .Icon.brand : .Icon.secondary)

                    // Badge
                    if let badge = item.badge, badge > 0 {
                        DSText(badge > 99 ? "99+" : "\(badge)", style: .label, color: Color.Background.primary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.Icon.brandSecondary)
                            .clipShape(Capsule())
                            .offset(x: 12, y: -4)
                    }
                }

                // Title
                if style.showTitle {
                    DSText(item.title, style: isSelected ? .label : .label, color: isSelected ? .Icon.brand : .Icon.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .xs)
        }
    }
}

// MARK: - View with Tab Bar

public struct DSTabBarView<Content: View>: View {
    @Binding var selectedTab: Int
    let items: [DSTabBar.TabItem]
    let style: DSTabBar.TabBarStyle
    let content: (Int) -> Content

    public init(
        selectedTab: Binding<Int>,
        items: [DSTabBar.TabItem],
        style: DSTabBar.TabBarStyle = .default,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._selectedTab = selectedTab
        self.items = items
        self.style = style
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            content(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            DSTabBar(selectedTab: $selectedTab, items: items, style: style)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview

#Preview("Default Tab Bar") {
    struct PreviewWrapper: View {
        @State private var selectedTab = 0

        let items: [DSTabBar.TabItem] = [
            .init(
                icon: Image(systemName: "house"),
                selectedIcon: Image(systemName: "house.fill"),
                title: "Home"
            ),
            .init(
                icon: Image(systemName: "magnifyingglass"),
                title: "Search"
            ),
            .init(
                icon: Image(systemName: "bell"),
                selectedIcon: Image(systemName: "bell.fill"),
                title: "Notifications",
                badge: 5
            ),
            .init(
                icon: Image(systemName: "person"),
                selectedIcon: Image(systemName: "person.fill"),
                title: "Profile"
            )
        ]

        var body: some View {
            VStack(spacing: 0) {
                // Content
                ZStack {
                    switch selectedTab {
                    case 0:
                        ContentPlaceholder(title: "Home", icon: "house.fill")
                    case 1:
                        ContentPlaceholder(title: "Search", icon: "magnifyingglass")
                    case 2:
                        ContentPlaceholder(title: "Notifications", icon: "bell.fill")
                    case 3:
                        ContentPlaceholder(title: "Profile", icon: "person.fill")
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                DSTabBar(selectedTab: $selectedTab, items: items, style: .default)
            }
            .background(Color.Background.secondary)
        }
    }

    return PreviewWrapper()
}

#Preview("Minimal Tab Bar") {
    struct PreviewWrapper: View {
        @State private var selectedTab = 0

        let items: [DSTabBar.TabItem] = [
            .init(icon: Image(systemName: "house.fill"), title: "Home"),
            .init(icon: Image(systemName: "magnifyingglass"), title: "Search"),
            .init(icon: Image(systemName: "bell.fill"), title: "Notifications", badge: 12),
            .init(icon: Image(systemName: "person.fill"), title: "Profile")
        ]

        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case 0:
                        ContentPlaceholder(title: "Home", icon: "house.fill")
                    case 1:
                        ContentPlaceholder(title: "Search", icon: "magnifyingglass")
                    case 2:
                        ContentPlaceholder(title: "Notifications", icon: "bell.fill")
                    case 3:
                        ContentPlaceholder(title: "Profile", icon: "person.fill")
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                DSTabBar(selectedTab: $selectedTab, items: items, style: .minimal)
            }
            .background(Color.Background.secondary)
        }
    }

    return PreviewWrapper()
}

#Preview("Tab Bar with DSTabBarView") {
    struct PreviewWrapper: View {
        @State private var selectedTab = 0

        let items: [DSTabBar.TabItem] = [
            .init(icon: Image(systemName: "house"), selectedIcon: Image(systemName: "house.fill"), title: "Home"),
            .init(icon: Image(systemName: "star"), selectedIcon: Image(systemName: "star.fill"), title: "Favorites", badge: 3),
            .init(icon: Image(systemName: "gear"), selectedIcon: Image(systemName: "gear"), title: "Settings")
        ]

        var body: some View {
            DSTabBarView(selectedTab: $selectedTab, items: items) { tab in
                switch tab {
                case 0:
                    ContentPlaceholder(title: "Home", icon: "house.fill")
                case 1:
                    ContentPlaceholder(title: "Favorites", icon: "star.fill")
                case 2:
                    ContentPlaceholder(title: "Settings", icon: "gear")
                default:
                    EmptyView()
                }
            }
        }
    }

    return PreviewWrapper()
}

// MARK: - Helper View

private struct ContentPlaceholder: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: .lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(Color.Icon.brand)

            DSText(title, style: .heading2, color: Color.Text.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Background.secondary)
    }
}
