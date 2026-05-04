//
//  DSToggle.swift
//  RWLDesignSystem
//
//  Standard iOS toggle/switch component
//

import SwiftUI

// MARK: - DSToggle

public struct DSToggle: View {
    @Binding var isOn: Bool

    let label: String?
    let description: String?
    let isDisabled: Bool
    let onTintColor: Color

    public init(
        isOn: Binding<Bool>,
        label: String? = nil,
        description: String? = nil,
        isDisabled: Bool = false,
        onTintColor: Color? = nil
    ) {
        self._isOn = isOn
        self.label = label
        self.description = description
        self.isDisabled = isDisabled
        self.onTintColor = onTintColor ?? Color.Button.primary
    }

    public var body: some View {
        HStack(alignment: .top, spacing: .md) {
            // Label and description
            if label != nil || description != nil {
                VStack(alignment: .leading, spacing: .xxs) {
                    if let label = label {
                        Text(label)
                            .fontStyle(.body)
                            .foregroundColor(isDisabled ? Color.Text.tertiary : Color.Text.primary)
                    }

                    if let description = description {
                        Text(description)
                            .fontStyle(.bodySmall)
                            .foregroundColor(Color.Text.secondary)
                    }
                }

                Spacer()
            }

            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(onTintColor)
                .disabled(isDisabled)
        }
    }
}

// MARK: - Grouped Toggle (Settings Style)

public struct DSToggleGroup: View {
    let toggles: [ToggleItem]

    public init(toggles: [ToggleItem]) {
        self.toggles = toggles
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(toggles.enumerated()), id: \.offset) { index, item in
                DSToggle(
                    isOn: item.isOn,
                    label: item.label,
                    description: item.description,
                    isDisabled: item.isDisabled,
                    onTintColor: item.tintColor
                )
                .padding(.md)
                .background(Color.Background.secondary)

                if index < toggles.count - 1 {
                    Divider()
                        .padding(.leading, .md)
                }
            }
        }
        .cornerRadius(.radiusMD)
        .border(.Border.default, lineWidth: .thin, cornerRadius: .radiusMD)
    }

    public struct ToggleItem {
        public let label: String
        public let description: String?
        public let isOn: Binding<Bool>
        public let isDisabled: Bool
        public let tintColor: Color?

        public init(
            label: String,
            description: String? = nil,
            isOn: Binding<Bool>,
            isDisabled: Bool = false,
            tintColor: Color? = nil
        ) {
            self.label = label
            self.description = description
            self.isOn = isOn
            self.isDisabled = isDisabled
            self.tintColor = tintColor
        }
    }
}

// MARK: - Previews

#Preview("Basic Toggles") {
    struct PreviewWrapper: View {
        @State private var notifications = true
        @State private var darkMode = false
        @State private var autoplay = true
        @State private var downloads = false
        @State private var disabled = false

        var body: some View {
            VStack(spacing: .lg) {
                DSToggle(
                    isOn: $notifications,
                    label: "Notifications"
                )

                DSToggle(
                    isOn: $darkMode,
                    label: "Dark Mode",
                    description: "Automatically adjust appearance based on time"
                )

                DSToggle(
                    isOn: $autoplay,
                    label: "Autoplay Videos"
                )

                DSToggle(
                    isOn: $downloads,
                    label: "Auto Downloads",
                    description: "Download content over WiFi"
                )

                DSToggle(
                    isOn: $disabled,
                    label: "Disabled Toggle",
                    description: "This toggle is disabled",
                    isDisabled: true
                )

                DSToggle(
                    isOn: $notifications,
                    label: "Custom Color",
                    onTintColor: Color.Semantic.success
                )
            }
            .padding()
        }
    }

    return PreviewWrapper()

}

#Preview("Toggle Group") {
    struct PreviewWrapper: View {
        @State private var pushNotifications = true
        @State private var emailNotifications = false
        @State private var smsNotifications = true
        @State private var soundEnabled = true
        @State private var vibrationEnabled = false

        var body: some View {
            VStack(spacing: .xl) {
                Text("Notification Settings")
                    .fontStyle(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DSToggleGroup(toggles: [
                    .init(
                        label: "Push Notifications",
                        description: "Receive push notifications",
                        isOn: $pushNotifications
                    ),
                    .init(
                        label: "Email Notifications",
                        description: "Receive notifications via email",
                        isOn: $emailNotifications
                    ),
                    .init(
                        label: "SMS Notifications",
                        description: "Receive notifications via SMS",
                        isOn: $smsNotifications
                    )
                ])

                Text("Sound & Haptics")
                    .fontStyle(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DSToggleGroup(toggles: [
                    .init(
                        label: "Sound",
                        description: "Play sound for notifications",
                        isOn: $soundEnabled
                    ),
                    .init(
                        label: "Vibration",
                        description: "Vibrate for notifications",
                        isOn: $vibrationEnabled
                    )
                ])
            }
            .padding()
        }
    }

    return PreviewWrapper()  
}

#Preview("Settings Style") {
    struct PreviewWrapper: View {
        @State private var airplaneMode = false
        @State private var wifi = true
        @State private var bluetooth = true
        @State private var cellularData = true
        @State private var personalHotspot = false

        var body: some View {
            ScrollView {
                VStack(spacing: .xl) {
                    // Connectivity
                    VStack(alignment: .leading, spacing: .sm) {
                        Text("Connectivity")
                            .fontStyle(.caption)
                            .foregroundColor(Color.Text.secondary)
                            .padding(.horizontal, .sm)

                        DSToggleGroup(toggles: [
                            .init(label: "Airplane Mode", isOn: $airplaneMode),
                            .init(label: "Wi-Fi", isOn: $wifi),
                            .init(label: "Bluetooth", isOn: $bluetooth),
                            .init(label: "Cellular Data", isOn: $cellularData),
                            .init(label: "Personal Hotspot", isOn: $personalHotspot)
                        ])
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
