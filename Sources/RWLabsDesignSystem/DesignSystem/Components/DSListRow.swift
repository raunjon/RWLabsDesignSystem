//
//  DSListRow.swift
//  RWLDesignSystem
//
//  Reusable list row for settings and navigation
//

import SwiftUI

// MARK: - DSListRow

public struct DSListRow: View {
    let icon: Image?
    let iconColor: Color?
    let title: String
    let subtitle: String?
    let value: String?
    let accessory: RowAccessory
    let action: (() -> Void)?

    public init(
        icon: Image? = nil,
        iconColor: Color? = nil,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        accessory: RowAccessory = .none,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.accessory = accessory
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: .md) {
                // Leading icon
                if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(iconColor ?? Color.Icon.brand)
                }

                // Title and subtitle
                VStack(alignment: .leading, spacing: .xxs) {
                    DSText(title, style: .body, color: Color.Text.primary)

                    if let subtitle = subtitle {
                        DSText(subtitle, style: .bodySmallMedium, color: Color.Text.secondary)
                    }
                }

                Spacer()

                // Value
                if let value = value {
                    DSText(value, style: .body, color: Color.Text.secondary)
                }

                // Accessory
                accessoryView
            }
            .padding(.vertical, .sm)
            .padding(.horizontal, .md)
            .background(Color.Background.primary)
        }
        .disabled(action == nil && accessory == .none)
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .disclosure:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.Text.tertiary)
        case .checkmark:
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.Icon.brand)
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
        case .custom(let view):
            view
        }
    }

    public enum RowAccessory: Equatable {
        case none
        case disclosure
        case checkmark
        case toggle(Binding<Bool>)
        case custom(AnyView)

        public static func == (lhs: RowAccessory, rhs: RowAccessory) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none): return true
            case (.disclosure, .disclosure): return true
            case (.checkmark, .checkmark): return true
            case (.toggle, .toggle): return true
            case (.custom, .custom): return true
            default: return false
            }
        }

        public static func customView<V: View>(_ view: V) -> RowAccessory {
            .custom(AnyView(view))
        }
    }
}

// MARK: - List Section

public struct DSListSection<Content: View>: View {
    let title: String?
    let footer: String?
    let content: () -> Content

    public init(
        title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            if let title = title {
                DSText(title.uppercased(), style: .label, color: Color.Text.secondary)
                    .padding(.horizontal, .md)
                    .padding(.top, .sm)
            }

            VStack(spacing: 0) {
                content()
            }
            .background(Color.Background.primary)
            .cornerRadius(.radiusSM)
            .border(.Border.inverse, lineWidth: 1, cornerRadius: .radiusSM)

            if let footer = footer {
                DSText(footer, style: .label, color: Color.Text.tertiary)
                    .padding(.horizontal, .md)
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic List Rows") {
    ScrollView {
        VStack(spacing: .md) {
            DSListSection(title: "Account") {
                DSListRow(
                    icon: Image(systemName: "person.circle"),
                    title: "Profile",
                    accessory: .disclosure,
                    action: { print("Profile tapped") }
                )

                Divider()

                DSListRow(
                    icon: Image(systemName: "lock.circle"),
                    title: "Privacy",
                    accessory: .disclosure,
                    action: { print("Privacy tapped") }
                )

                Divider()

                DSListRow(
                    icon: Image(systemName: "bell.circle"),
                    title: "Notifications",
                    accessory: .disclosure,
                    action: { print("Notifications tapped") }
                )
            }

            DSListSection(title: "About") {
                DSListRow(
                    icon: Image(systemName: "info.circle"),
                    title: "Version",
                    value: "1.0.0",
                    accessory: .none
                )

                Divider()

                DSListRow(
                    icon: Image(systemName: "doc.text"),
                    title: "Terms of Service",
                    accessory: .disclosure,
                    action: { print("Terms tapped") }
                )
            }
        }
        .padding()
    }
    .background(Color.Background.secondary)
}

#Preview("List with Toggles") {
    struct PreviewWrapper: View {
        @State private var notifications = true
        @State private var locationServices = false
        @State private var analytics = true

        var body: some View {
            ScrollView {
                VStack(spacing: .md) {
                    DSListSection(
                        title: "Permissions",
                        footer: "These settings control app permissions"
                    ) {
                        DSListRow(
                            icon: Image(systemName: "bell.badge"),
                            iconColor: Color.Semantic.warning,
                            title: "Push Notifications",
                            subtitle: "Receive updates and alerts",
                            accessory: .toggle($notifications)
                        )

                        Divider()

                        DSListRow(
                            icon: Image(systemName: "location"),
                            iconColor: Color.Icon.brand,
                            title: "Location Services",
                            subtitle: "Allow location access",
                            accessory: .toggle($locationServices)
                        )

                        Divider()

                        DSListRow(
                            icon: Image(systemName: "chart.bar"),
                            iconColor: Color.Semantic.success,
                            title: "Analytics",
                            subtitle: "Help improve the app",
                            accessory: .toggle($analytics)
                        )
                    }
                }
                .padding()
            }
            .background(Color.Background.secondary)
        }
    }

    return PreviewWrapper()
}

#Preview("List with Selection") {
    struct PreviewWrapper: View {
        @State private var selectedTheme = "System"

        let themes = ["Light", "Dark", "System"]

        var body: some View {
            ScrollView {
                VStack(spacing: .md) {
                    DSListSection(title: "Appearance") {
                        ForEach(Array(themes.enumerated()), id: \.offset) { index, theme in
                            if index > 0 {
                                Divider()
                            }

                            DSListRow(
                                title: theme,
                                accessory: selectedTheme == theme ? .checkmark : .none,
                                action: {
                                    selectedTheme = theme
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color.Background.secondary)
        }
    }

    return PreviewWrapper()
}

#Preview("List with Subtitles") {
    ScrollView {
        VStack(spacing: .md) {
            DSListSection(title: "Settings") {
                DSListRow(
                    icon: Image(systemName: "wifi"),
                    iconColor: Color.Icon.brand,
                    title: "Wi-Fi",
                    subtitle: "Connected to Home Network",
                    value: "On",
                    accessory: .disclosure,
                    action: { print("Wi-Fi tapped") }
                )

                Divider()

                DSListRow(
                    icon: Image(systemName: "antenna.radiowaves.left.and.right"),
                    iconColor: Color.Semantic.success,
                    title: "Cellular",
                    subtitle: "Using 2.3 GB this month",
                    accessory: .disclosure,
                    action: { print("Cellular tapped") }
                )

                Divider()

                DSListRow(
                    icon: Image(systemName: "battery.100"),
                    iconColor: Color.Semantic.success,
                    title: "Battery",
                    subtitle: "100% - Fully Charged",
                    accessory: .disclosure,
                    action: { print("Battery tapped") }
                )
            }
        }
        .padding()
    }
    .background(Color.Background.secondary)
}
