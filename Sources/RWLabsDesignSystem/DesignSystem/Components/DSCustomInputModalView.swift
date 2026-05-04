//
//  DSCustomInputModalView.swift
//  RWLabsDesignSystem
//
//  Advanced modal view with multiple input types and flexible layouts
//

import SwiftUI

// MARK: - Input Type

/// Supported input types for custom modal
public enum DSCustomInputType {
    case text(DSTextInputConfig)
    case toggle(DSToggleInputConfig)
    case picker(DSPickerInputConfig)
    case datePicker(DSDateInputConfig)
    case slider(DSSliderInputConfig)
    case stepper(DSStepperInputConfig)
}

// MARK: - Input Configurations

/// Configuration for text input
public struct DSTextInputConfig {
    public let label: String?
    public let placeholder: String
    public let icon: Image?
    public let isSecure: Bool
    public let keyboardType: UIKeyboardType
    public let textContentType: UITextContentType?
    public let autocapitalization: UITextAutocapitalizationType
    public var isDisabled: Bool
    @Binding public var value: String

    public init(
        label: String? = nil,
        placeholder: String,
        value: Binding<String>,
        icon: Image? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: UITextAutocapitalizationType = .sentences,
        isDisabled: Bool = false
    ) {
        self.label = label
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        self.isDisabled = isDisabled
        _value = value
    }
}

/// Configuration for toggle input
public struct DSToggleInputConfig {
    public let label: String
    public let description: String?
    public let onTintColor: Color?
    @Binding public var value: Bool

    public init(
        label: String,
        description: String? = nil,
        value: Binding<Bool>,
        onTintColor: Color? = nil
    ) {
        self.label = label
        self.description = description
        self.onTintColor = onTintColor
        _value = value
    }
}

/// Configuration for picker input
public struct DSPickerInputConfig {
    public let label: String?
    public let icon: Image?
    public let options: [String]
    @Binding public var value: String

    public init(
        label: String? = nil,
        icon: Image? = nil,
        options: [String],
        value: Binding<String>
    ) {
        self.label = label
        self.icon = icon
        self.options = options
        _value = value
    }
}

/// Configuration for date picker input
public struct DSDateInputConfig {
    public let label: String?
    public let style: DSDatePicker.Style
    @Binding public var value: Date

    public init(
        label: String? = nil,
        style: DSDatePicker.Style = .dateOnly,
        value: Binding<Date>
    ) {
        self.label = label
        self.style = style
        _value = value
    }
}

/// Configuration for slider input
public struct DSSliderInputConfig {
    public let label: String?
    public let range: ClosedRange<Double>
    public let step: Double?
    @Binding public var value: Double

    public init(
        label: String? = nil,
        range: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        value: Binding<Double>
    ) {
        self.label = label
        self.range = range
        self.step = step
        _value = value
    }
}

/// Configuration for stepper input
public struct DSStepperInputConfig {
    public let label: String
    public let range: ClosedRange<Int>
    public let step: Int
    @Binding public var value: Int

    public init(
        label: String,
        range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        value: Binding<Int>
    ) {
        self.label = label
        self.range = range
        self.step = step
        _value = value
    }
}

// MARK: - Input Row Configuration

/// Represents a row in the modal, which can contain 1 or 2 inputs
public struct DSCustomInputRow: Identifiable {
    public let id = UUID()
    public let inputs: [DSCustomInputType]

    /// Creates a row with a single input
    public init(_ input: DSCustomInputType) {
        self.inputs = [input]
    }

    /// Creates a row with two inputs side by side
    public init(_ input1: DSCustomInputType, _ input2: DSCustomInputType) {
        self.inputs = [input1, input2]
    }

    public var isSingleInput: Bool {
        inputs.count == 1
    }
}

// MARK: - Custom Input Modal View

/// An advanced modal view with multiple input types and flexible layouts
///
/// DSCustomInputModalView provides:
/// - Multiple input types (text, toggle, picker, date, slider, stepper)
/// - Flexible layouts (1 or 2 inputs per row)
/// - Optional title and subtitle
/// - Customizable action buttons
///
/// # Example Usage
/// ```swift
/// DSCustomInputModalView(
///     title: "User Profile",
///     subtitle: "Fill in your details",
///     rows: [
///         DSCustomInputRow(
///             .text(DSTextInputConfig(label: "First Name", placeholder: "Enter name", value: $firstName)),
///             .text(DSTextInputConfig(label: "Last Name", placeholder: "Enter name", value: $lastName))
///         ),
///         DSCustomInputRow(
///             .picker(DSPickerInputConfig(label: "Country", options: countries, value: $country))
///         ),
///         DSCustomInputRow(
///             .toggle(DSToggleInputConfig(label: "Subscribe to newsletter", value: $subscribe))
///         )
///     ],
///     actions: [
///         DSActionButtonConfig(title: "Cancel", style: .cancel) { },
///         DSActionButtonConfig(title: "Save", style: .primary) { }
///     ]
/// )
/// ```
public struct DSCustomInputModalView: View {
    let title: String?
    let subtitle: String?
    let rows: [DSCustomInputRow]
    let actions: [DSActionButtonConfig]

    @Environment(\.dismiss) private var dismiss

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        rows: [DSCustomInputRow],
        actions: [DSActionButtonConfig]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.rows = rows
        self.actions = actions
    }

    public var body: some View {
        DSCard(elevation: .medium) {
            VStack(spacing: .sm) {
                // Title
                if let title = title {
                    Text(title)
                        .fontStyle(.title2)
                        .foregroundStyle(Color.Text.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, .md)
                        .padding(.horizontal, .lg)
                }

                // Subtitle
                if let subtitle = subtitle {
                    Text(subtitle)
                        .typography(.bodyMedium, color: Color.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, .xxs)
                        .padding(.horizontal, .lg)
                }

                // Dynamic Input Rows
                VStack(spacing: .md) {
                    ForEach(rows.indices, id: \.self) { rowIndex in
                        if rows[rowIndex].isSingleInput {
                            // Single input layout
                            DSCustomInputView(inputType: Binding(
                                get: { rows[rowIndex].inputs[0] },
                                set: { _ in }
                            ))
                                .padding(.horizontal, .lg)
                        } else {
                            // Two inputs side by side
                            HStack(spacing: .sm) {
                                ForEach(0..<rows[rowIndex].inputs.count, id: \.self) { inputIndex in
                                    DSCustomInputView(inputType: Binding(
                                        get: { rows[rowIndex].inputs[inputIndex] },
                                        set: { _ in }
                                    ))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, .lg)
                        }
                    }
                }
                .padding(.top, .md)

                // Action Buttons
                if actions.count == 1 {
                    // Single button layout
                    DSCustomInputActionButton(config: actions[0])
                        .padding(.horizontal, .lg)
                        .padding(.top, .md)
                        .padding(.bottom, .md)
                } else if actions.count == 2 {
                    // Two button horizontal layout
                    HStack(spacing: .sm) {
                        ForEach(actions) { actionConfig in
                            DSCustomInputActionButton(config: actionConfig)
                        }
                    }
                    .padding(.horizontal, .lg)
                    .padding(.top, .md)
                    .padding(.bottom, .md)
                } else {
                    // Multiple buttons vertical layout
                    VStack(spacing: .xs) {
                        ForEach(actions) { actionConfig in
                            DSCustomInputActionButton(config: actionConfig)
                        }
                    }
                    .padding(.horizontal, .lg)
                    .padding(.top, .md)
                    .padding(.bottom, .md)
                }
            }
        }
        .padding(.lg)
    }
}

// MARK: - Custom Input View

private struct DSCustomInputView: View {
    @Binding var inputType: DSCustomInputType

    var body: some View {
        switch inputType {
        case .text(let config):
            DSTextField(
                text: config.$value,
                label: config.label,
                placeholder: config.placeholder,
                errorMessage: nil,
                isDisabled: config.isDisabled,
                isSecure: config.isSecure,
                icon: config.icon,
                keyboardType: config.keyboardType,
                textContentType: config.textContentType,
                autocapitalization: config.autocapitalization
            )

        case .toggle(let config):
            DSToggle(
                isOn: config.$value,
                label: config.label,
                description: config.description,
                onTintColor: config.onTintColor
            )

        case .picker(let config):
            DSPicker(
                selection: config.$value,
                options: config.options,
                label: config.label,
                icon: config.icon
            )

        case .datePicker(let config):
            DSDatePicker(
                selection: config.$value,
                style: config.style,
                label: config.label
            )

        case .slider(let config):
            VStack(alignment: .leading, spacing: .xs) {
                if let label = config.label {
                    HStack {
                        Text(label)
                            .typography(.bodyMedium, color: Color.Text.primary)
                        Spacer()
                        Text(String(format: "%.1f", config.value))
                            .typography(.bodyMedium, color: Color.Text.secondary)
                    }
                }

                DSSlider(
                    value: config.$value,
                    range: config.range,
                    step: config.step
                )
            }

        case .stepper(let config):
            HStack {
                Text(config.label)
                    .typography(.bodyMedium, color: Color.Text.primary)

                Spacer()

                DSStepper(
                    value: config.$value,
                    range: config.range,
                    step: config.step
                )
            }
        }
    }
}

// MARK: - Action Button

private struct DSCustomInputActionButton: View {
    let config: DSActionButtonConfig

    var body: some View {
        switch config.style {
        case .primary:
            DSButton(
                title: config.title,
                variant: .primary,
                size: .small,
                isLoading: config.isLoading,
                isDisabled: config.isDisabled
            ) {
                config.action([])
            }

        case .secondary:
            DSButton(
                title: config.title,
                variant: .outline,
                size: .small,
                isLoading: config.isLoading,
                isDisabled: config.isDisabled
            ) {
                config.action([])
            }

        case .cancel:
            DSButton(
                title: config.title,
                variant: config.isDestructive ? .destructive : .outline,
                size: .small,
                isLoading: config.isLoading,
                isDisabled: config.isDisabled
            ) {
                config.action([])
            }
        }
    }
}

// MARK: - Convenience Modifier

public extension View {
    /// Presents a custom input modal view when a binding to a Boolean value is true
    ///
    /// - Parameters:
    ///   - isPresented: A binding to whether the modal is presented
    ///   - title: Optional title text
    ///   - subtitle: Optional subtitle text
    ///   - rows: Array of input row configurations
    ///   - actions: Array of action button configurations
    func customInputModal(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        rows: [DSCustomInputRow],
        actions: [DSActionButtonConfig]
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }

                DSCustomInputModalView(
                    title: title,
                    subtitle: subtitle,
                    rows: rows,
                    actions: actions
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: isPresented.wrappedValue)
    }
}

// MARK: - Previews

#Preview("Mixed Input Types") {
    struct PreviewWrapper: View {
        @State private var firstName = ""
        @State private var lastName = ""
        @State private var email = ""
        @State private var country = "United States"
        @State private var birthDate = Date()
        @State private var subscribe = true
        @State private var notifications = false
        @State private var volume: Double = 50
        @State private var age: Int = 25

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1)

                DSCustomInputModalView(
                    title: "User Profile",
                    subtitle: "Complete your profile information",
                    rows: [
                        // Two text inputs in one row
                        DSCustomInputRow(
                            .text(DSTextInputConfig(
                                label: "First Name",
                                placeholder: "Enter first name",
                                value: $firstName,
                                icon: Image(systemName: "person"),
                                autocapitalization: .words
                            )),
                            .text(DSTextInputConfig(
                                label: "Last Name",
                                placeholder: "Enter last name",
                                value: $lastName,
                                autocapitalization: .words
                            ))
                        ),
                        // Single email input
                        DSCustomInputRow(
                            .text(DSTextInputConfig(
                                label: "Email",
                                placeholder: "your@email.com",
                                value: $email,
                                icon: Image(systemName: "envelope"),
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress,
                                autocapitalization: .none
                            ))
                        ),
                        // Picker and Date picker in one row
                        DSCustomInputRow(
                            .picker(DSPickerInputConfig(
                                label: "Country",
                                icon: Image(systemName: "globe"),
                                options: ["United States", "Canada", "Mexico", "UK"],
                                value: $country
                            )),
                            .datePicker(DSDateInputConfig(
                                label: "Birth Date",
                                style: .dateOnly,
                                value: $birthDate
                            ))
                        ),
                        // Toggle
                        DSCustomInputRow(
                            .toggle(DSToggleInputConfig(
                                label: "Subscribe to Newsletter",
                                description: "Receive updates and promotions",
                                value: $subscribe
                            ))
                        ),
                        // Slider
                        DSCustomInputRow(
                            .slider(DSSliderInputConfig(
                                label: "Volume",
                                range: 0...100,
                                step: 1,
                                value: $volume
                            ))
                        ),
                        // Two toggles in one row
                        DSCustomInputRow(
                            .toggle(DSToggleInputConfig(
                                label: "Notifications",
                                value: $notifications
                            )),
                            .stepper(DSStepperInputConfig(
                                label: "Age",
                                range: 0...120,
                                step: 1,
                                value: $age
                            ))
                        )
                    ],
                    actions: [
                        DSActionButtonConfig(title: "Cancel", style: .cancel) { _ in
                            print("Cancelled")
                        },
                        DSActionButtonConfig(title: "Save Profile", style: .primary) { _ in
                            print("Saved: \(firstName) \(lastName), \(email), \(country)")
                        }
                    ]
                )
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Settings Form") {
    struct PreviewWrapper: View {
        @State private var username = "johndoe"
        @State private var displayName = "John Doe"
        @State private var theme = "Light"
        @State private var language = "English"
        @State private var autoSave = true
        @State private var notifications = true
        @State private var soundEnabled = false
        @State private var brightness: Double = 75
        @State private var fontSize: Int = 14

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1)

                DSCustomInputModalView(
                    title: "Settings",
                    subtitle: "Customize your preferences",
                    rows: [
                        // Account settings
                        DSCustomInputRow(
                            .text(DSTextInputConfig(
                                label: "Username",
                                placeholder: "username",
                                value: $username,
                                icon: Image(systemName: "at"),
                                autocapitalization: .none
                            ))
                        ),
                        DSCustomInputRow(
                            .text(DSTextInputConfig(
                                label: "Display Name",
                                placeholder: "Your name",
                                value: $displayName,
                                icon: Image(systemName: "person.circle")
                            ))
                        ),
                        // Appearance
                        DSCustomInputRow(
                            .picker(DSPickerInputConfig(
                                label: "Theme",
                                icon: Image(systemName: "paintbrush"),
                                options: ["Light", "Dark", "Auto"],
                                value: $theme
                            )),
                            .picker(DSPickerInputConfig(
                                label: "Language",
                                icon: Image(systemName: "globe"),
                                options: ["English", "Spanish", "French"],
                                value: $language
                            ))
                        ),
                        // Preferences
                        DSCustomInputRow(
                            .toggle(DSToggleInputConfig(
                                label: "Auto Save",
                                description: "Save changes automatically",
                                value: $autoSave
                            ))
                        ),
                        DSCustomInputRow(
                            .toggle(DSToggleInputConfig(
                                label: "Push Notifications",
                                value: $notifications
                            )),
                            .toggle(DSToggleInputConfig(
                                label: "Sound Effects",
                                value: $soundEnabled
                            ))
                        ),
                        // Display
                        DSCustomInputRow(
                            .slider(DSSliderInputConfig(
                                label: "Brightness",
                                range: 0...100,
                                step: 5,
                                value: $brightness
                            ))
                        ),
                        DSCustomInputRow(
                            .stepper(DSStepperInputConfig(
                                label: "Font Size",
                                range: 10...24,
                                step: 2,
                                value: $fontSize
                            ))
                        )
                    ],
                    actions: [
                        DSActionButtonConfig(title: "Cancel", style: .cancel) { _ in
                            print("Cancelled")
                        },
                        DSActionButtonConfig(title: "Apply", style: .primary) { _ in
                            print("Applied settings")
                        }
                    ]
                )
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Compact Form") {
    struct PreviewWrapper: View {
        @State private var name = ""
        @State private var email = ""
        @State private var acceptTerms = false

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1)

                DSCustomInputModalView(
                    title: "Quick Sign Up",
                    rows: [
                        DSCustomInputRow(
                            .text(DSTextInputConfig(
                                placeholder: "Full Name",
                                value: $name,
                                icon: Image(systemName: "person.fill")
                            ))
                        ),
                        DSCustomInputRow(
                            .text(DSTextInputConfig(
                                placeholder: "Email Address",
                                value: $email,
                                icon: Image(systemName: "envelope.fill"),
                                keyboardType: .emailAddress,
                                autocapitalization: .none
                            ))
                        ),
                        DSCustomInputRow(
                            .toggle(DSToggleInputConfig(
                                label: "I accept the terms and conditions",
                                value: $acceptTerms
                            ))
                        )
                    ],
                    actions: [
                        DSActionButtonConfig(title: "Cancel", style: .cancel) { _ in },
                        DSActionButtonConfig(title: "Sign Up", style: .primary) { _ in }
                    ]
                )
            }
        }
    }

    return PreviewWrapper()
}
