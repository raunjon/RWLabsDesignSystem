//
//  DSTabBar.swift
//  RWLabsDesignSystem
//
//  Bottom navigation bar matching the Figma "Nav Bar": a full-width card with rounded top corners
//  and an upward shadow. Each item is a 24pt icon over a 10px title; the selected item turns brand
//  coral and shows its filled icon.
//
//  Style SwiftUI's own TabView, so tabs keep their state and the selection stays yours:
//
//  TabView(selection: $tab) {
//      HomeView().dsTab(Screen.home)
//      ChatView().dsTab(Screen.chat)
//  }
//  .dsTabBarStyle(selection: $tab, tabs: [
//      DSTab(Screen.home, title: "Home", icon: Image("home"), selectedIcon: Image("home.fill")),
//      DSTab(Screen.chat, title: "Chat", icon: Image("chat"), selectedIcon: Image("chat.fill"), badge: 3),
//  ])
//
//  `DSTabBar` draws the bar on its own, for layouts that don't use TabView.
//

import SwiftUI

// MARK: - DSTabBar
public struct DSTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabItem]

    public init(selectedTab: Binding<Int>, items: [TabItem]) {
        self._selectedTab = selectedTab
        self.items = items
    }

    @available(*, deprecated, message: "Figma has one nav bar look; use init(selectedTab:items:)")
    public init(selectedTab: Binding<Int>, items: [TabItem], style: TabBarStyle) {
        self.init(selectedTab: selectedTab, items: items)
    }

    public var body: some View {
        DSTabBarContent(
            selection: $selectedTab,
            tabs: items.enumerated().map { index, item in
                DSTab(index, title: item.title, icon: item.icon, selectedIcon: item.selectedIcon, badge: item.badge)
            }
        )
    }

    public struct TabItem {
        public let icon: Image
        public let selectedIcon: Image?
        public let title: String
        public let badge: Int?

        /// - Parameter selectedIcon: Figma swaps to the filled icon when selected.
        public init(icon: Image, selectedIcon: Image? = nil, title: String, badge: Int? = nil) {
            self.icon = icon
            self.selectedIcon = selectedIcon
            self.title = title
            self.badge = badge
        }
    }

    @available(*, deprecated, message: "Figma has one nav bar look")
    public enum TabBarStyle {
        case `default`
        case minimal
        case floating
    }
}

// MARK: - Tab
/// One nav bar item, identified by the same value you tag the tab's content with.
public struct DSTab<Value: Hashable> {
    public let value: Value
    public let title: String
    public let icon: Image
    public let selectedIcon: Image?
    public let badge: Int?

    /// - Parameter selectedIcon: Figma swaps to the filled icon when selected.
    public init(_ value: Value, title: String, icon: Image, selectedIcon: Image? = nil, badge: Int? = nil) {
        self.value = value
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.badge = badge
    }
}

// MARK: - Bar
/// The drawn nav bar: a full-width card with rounded top corners and an upward shadow.
struct DSTabBarContent<Value: Hashable>: View {
    @Binding var selection: Value
    let tabs: [DSTab<Value>]

    /// Bar height above the bottom safe area; tab pages are padded by this much
    static var height: CGFloat { 64 }
    /// Figma item gap
    private let itemSpacing: CGFloat = 28
    private let topRadius: CGFloat = .radiusXL
    /// Figma "Corner/Extra-large"
    private let bottomRadius: CGFloat = 28

    var body: some View {
        HStack(spacing: itemSpacing) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { _, tab in
                DSTabBarButton(tab: tab, isSelected: selection == tab.value) {
                    withAnimation(.easeInOut(duration: 0.2)) { selection = tab.value }
                }
            }
        }
        .padding(.horizontal, .sm)
        .padding(.vertical, .xs)
        .frame(maxWidth: .infinity, minHeight: Self.height)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: topRadius,
                bottomLeadingRadius: bottomRadius,
                bottomTrailingRadius: bottomRadius,
                topTrailingRadius: topRadius
            )
            .fill(Color.NavBar.bar)
            .shadow(color: .NavBar.shadow, radius: 9.4, x: 1, y: -1)
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

private struct DSTabBarButton<Value: Hashable>: View {
    let tab: DSTab<Value>
    let isSelected: Bool
    let action: () -> Void

    private var color: Color { isSelected ? .NavBar.selected : .NavBar.unselected }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                (isSelected ? tab.selectedIcon ?? tab.icon : tab.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .overlay(alignment: .topTrailing) {
                        if let badge = tab.badge, badge > 0 {
                            DSUnreadBadge(count: badge)
                                .offset(x: 10, y: -6)
                        }
                    }
                Text(tab.title)
                    .fontStyle(.caption)
                    .lineLimit(1)
                    .fixedSize()
            }
            .foregroundColor(color)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - TabView Style
public extension View {
    /// Replaces a TabView's system bar with the Figma nav bar. Mark each tab with `.dsTab(_:)`.
    func dsTabBarStyle<Value: Hashable>(selection: Binding<Value>, tabs: [DSTab<Value>]) -> some View {
        overlay(alignment: .bottom) {
            DSTabBarContent(selection: selection, tabs: tabs)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    /// Tags a TabView page, hides the system tab bar for it, and pads its safe area so content
    /// scrolls clear of the nav bar. TabView hosts each page separately, so every page needs this.
    func dsTab<Value: Hashable>(_ value: Value) -> some View {
        safeAreaPadding(.bottom, DSTabBarContent<Value>.height)
            .toolbar(.hidden, for: .tabBar)
            .tag(value)
    }
}

// MARK: - View with Tab Bar
public struct DSTabBarView<Content: View>: View {
    @Binding var selectedTab: Int
    let items: [DSTabBar.TabItem]
    let content: (Int) -> Content

    public init(
        selectedTab: Binding<Int>,
        items: [DSTabBar.TabItem],
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._selectedTab = selectedTab
        self.items = items
        self.content = content
    }

    @available(*, deprecated, message: "Figma has one nav bar look; use init(selectedTab:items:content:)")
    public init(
        selectedTab: Binding<Int>,
        items: [DSTabBar.TabItem],
        style: DSTabBar.TabBarStyle,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.init(selectedTab: selectedTab, items: items, content: content)
    }

    public var body: some View {
        content(selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                DSTabBar(selectedTab: $selectedTab, items: items)
            }
            .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview
/// A native TabView with the Figma nav bar (Iconly stand-ins from SF Symbols).
private struct DSTabBarGallery: View {
    enum Screen: Hashable { case home, communities, events, chat, profile }

    @State private var screen = Screen.home

    private let tabs: [DSTab<Screen>] = [
        DSTab(.home, title: "Home", icon: Image(systemName: "house"), selectedIcon: Image(systemName: "house.fill")),
        DSTab(.communities, title: "Communities", icon: Image(systemName: "person.3"), selectedIcon: Image(systemName: "person.3.fill")),
        DSTab(.events, title: "Events", icon: Image(systemName: "ticket"), selectedIcon: Image(systemName: "ticket.fill")),
        DSTab(.chat, title: "Chat", icon: Image(systemName: "ellipsis.bubble"), selectedIcon: Image(systemName: "ellipsis.bubble.fill"), badge: 3),
        DSTab(.profile, title: "Profile", icon: Image(systemName: "person"), selectedIcon: Image(systemName: "person.fill")),
    ]

    var body: some View {
        TabView(selection: $screen) {
            ForEach(tabs, id: \.value) { tab in
                Text(tab.title)
                    .fontStyle(.heading2)
                    .foregroundColor(.Text.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.Background.primary)
                    .dsTab(tab.value)
            }
        }
        .dsTabBarStyle(selection: $screen, tabs: tabs)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSTabBarGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSTabBarGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSTabBarGallery().designSystem()
}
