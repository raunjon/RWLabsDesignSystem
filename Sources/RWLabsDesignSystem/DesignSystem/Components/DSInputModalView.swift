//
//  DSInputModalView.swift
//  RWLabsDesignSystem
//
//  Created by Raunak Joneja on 29/03/26.
//

import SwiftUI

// MARK: - Input Field Configuration

/// Configuration for a text input field in DSInputModalView
public struct DSInputFieldConfig: Identifiable {
    public let id = UUID()
    public let label: String?
    public let placeholder: String
    @Binding public var initialValue: String
    public let icon: Image?
    public let isSecure: Bool
    public let keyboardType: UIKeyboardType
    public let textContentType: UITextContentType?
    public let autocapitalization: UITextAutocapitalizationType

    public init(
        label: String? = nil,
        placeholder: String,
        initialValue: Binding<String>,
        icon: Image? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: UITextAutocapitalizationType = .sentences
    ) {
        self.label = label
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        _initialValue = initialValue
    }
}

// MARK: - Action Button Configuration

/// Configuration for an action button in DSInputModalView
public struct DSActionButtonConfig: Identifiable {
    public let id = UUID()
    public let title: String
    public let style: ActionButtonStyle
    public let isDestructive: Bool
    public var isDisabled: Bool
    public var isLoading: Bool
    public let action: ([String]) -> Void

    public enum ActionButtonStyle {
        case primary
        case secondary
        case cancel
    }

    public init(
        title: String,
        style: ActionButtonStyle = .primary,
        isDestructive: Bool = false,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        action: @escaping ([String]) -> Void
    ) {
        self.title = title
        self.style = style
        self.isDestructive = isDestructive
        self.action = action
        self.isDisabled = isDisabled
        self.isLoading = isLoading
    }
}

// MARK: - Input Modal View

/// A modal view with dynamic text fields and action buttons
///
/// DSInputModalView provides a flexible modal dialog that can display:
/// - Optional title and subtitle
/// - Multiple configurable text fields
/// - Multiple action buttons with various styles
///
/// # Example Usage
/// ```swift
/// DSInputModalView(
///     title: "Add Comment",
///     subtitle: "Enter your comment below",
///     inputFields: [
///         DSInputFieldConfig(
///             placeholder: "Your comment",
///             initialValue: $comment
///         )
///     ],
///     actions: [
///         DSActionButtonConfig(title: "Cancel", style: .cancel) { _ in },
///         DSActionButtonConfig(title: "Submit", style: .primary) { values in
///             print(values[0])
///         }
///     ]
/// )
/// ```
public struct DSInputModalView: View {
    let title: String?
    let subtitle: String?
    var inputFields: [DSInputFieldConfig]
    let actions: [DSActionButtonConfig]

    private var textFieldValues: [String] {
        inputFields.map { $0.initialValue }
    }
    @Environment(\.dismiss) private var dismiss

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        inputFields: [DSInputFieldConfig],
        actions: [DSActionButtonConfig]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.inputFields = inputFields
        self.actions = actions
    }

    public var body: some View {
        DSCard(elevation: .high) {
            VStack(spacing: .sm) {
                // Title
                if let title = title {
                    DSText(title, style: .title2, color: Color.Text.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, .md)
                        .padding(.horizontal, .lg)
                }

                // Subtitle
                if let subtitle = subtitle {
                    DSText(subtitle, style: .bodyMedium, color: Color.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, .xxs)
                        .padding(.horizontal, .lg)
                }

                // Dynamic Text Fields
                VStack(spacing: .sm) {
                    ForEach(inputFields.indices, id: \.self) { index in
                        DSTextField(
                            text: inputFields[index].$initialValue,
                            label: inputFields[index].label,
                            placeholder: inputFields[index].placeholder,
                            errorMessage: nil,
                            isSecure: inputFields[index].isSecure,
                            icon: inputFields[index].icon,
                            keyboardType: inputFields[index].keyboardType,
                            textContentType: inputFields[index].textContentType,
                            autocapitalization: inputFields[index].autocapitalization
                        )
                        .padding(.horizontal, .lg)
                    }
                }
                .padding(.top, .md)

                // Action Buttons
                if actions.count == 1 {
                    // Single button layout
                    DSInputModalActionButton(config: actions[0], textFieldValues: textFieldValues)
                        .padding(.horizontal, .lg)
                        .padding(.top, .md)
                        .padding(.bottom, .md)
                } else if actions.count == 2 {
                    // Two button horizontal layout
                    HStack(spacing: .sm) {
                        ForEach(actions) { actionConfig in
                            DSInputModalActionButton(config: actionConfig, textFieldValues: textFieldValues)
                        }
                    }
                    .padding(.horizontal, .lg)
                    .padding(.top, .md)
                    .padding(.bottom, .md)
                } else {
                    // Multiple buttons vertical layout
                    VStack(spacing: .xs) {
                        ForEach(actions) { actionConfig in
                            DSInputModalActionButton(config: actionConfig, textFieldValues: textFieldValues)
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

// MARK: - Action Button

private struct DSInputModalActionButton: View {
    let config: DSActionButtonConfig
    let textFieldValues: [String]

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
                config.action(textFieldValues)
            }

        case .secondary:
            DSButton(
                title: config.title,
                variant: .secondary,
                size: .small,
                isLoading: config.isLoading,
                isDisabled: config.isDisabled
            ) {
                config.action(textFieldValues)
            }

        case .cancel:
            DSButton(
                title: config.title,
                variant: config.isDestructive ? .destructive : .outline,
                size: .small,
                isLoading: config.isLoading,
                isDisabled: config.isDisabled
            ) {
                config.action(textFieldValues)
            }
        }
    }
}

// MARK: - Convenience Modifier

public extension View {
    /// Presents an input modal view when a binding to a Boolean value is true
    ///
    /// - Parameters:
    ///   - isPresented: A binding to whether the modal is presented
    ///   - title: Optional title text
    ///   - subtitle: Optional subtitle text
    ///   - inputFields: Array of input field configurations
    ///   - actions: Array of action button configurations
    func inputModal(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        inputFields: [DSInputFieldConfig],
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

                DSInputModalView(
                    title: title,
                    subtitle: subtitle,
                    inputFields: inputFields,
                    actions: actions
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: isPresented.wrappedValue)
    }
}

// MARK: - Previews

#Preview("Single Field") {
    ZStack {
        Color.gray.opacity(0.1)

        DSInputModalView(
            title: "Add Comment",
            subtitle: "Enter your comment below",
            inputFields: [
                DSInputFieldConfig(placeholder: "Your comment here...", initialValue: .constant(""))
            ],
            actions: [
                DSActionButtonConfig(title: "Cancel", style: .secondary, isDestructive: false) { _ in
                    print("Cancelled")
                },
                DSActionButtonConfig(title: "Submit", style: .primary) { values in
                    print("Submitted: \(values)")
                }
            ]
        )
    }
}

#Preview("Multiple Fields") {
    ZStack {
        Color.gray.opacity(0.1)

        DSInputModalView(
            title: "User Information",
            subtitle: "Please fill in all the details",
            inputFields: [
                DSInputFieldConfig(
                    label: "First Name",
                    placeholder: "Enter first name",
                    initialValue: .constant(""),
                    icon: Image(systemName: "person"),
                    autocapitalization: .words
                ),
                DSInputFieldConfig(
                    label: "Email",
                    placeholder: "Enter email",
                    initialValue: .constant(""),
                    icon: Image(systemName: "envelope"),
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .none
                ),
                DSInputFieldConfig(
                    label: "Password",
                    placeholder: "Enter password",
                    initialValue: .constant(""),
                    icon: Image(systemName: "lock"),
                    isSecure: true,
                    textContentType: .password,
                    autocapitalization: .none
                )
            ],
            actions: [
                DSActionButtonConfig(title: "Cancel", style: .cancel) { _ in
                    print("Cancelled")
                },
                DSActionButtonConfig(title: "Save", style: .primary) { values in
                    print("Saved: \(values)")
                }
            ]
        )
    }
}

#Preview("Destructive Action") {
    ZStack {
        Color.gray.opacity(0.1)

        DSInputModalView(
            title: "Delete Account",
            subtitle: "This action cannot be undone. Please type your password to confirm.",
            inputFields: [
                DSInputFieldConfig(
                    label: "Password",
                    placeholder: "Enter your password",
                    initialValue: .constant(""),
                    icon: Image(systemName: "lock"),
                    isSecure: true
                )
            ],
            actions: [
                DSActionButtonConfig(title: "Cancel", style: .cancel) { _ in
                    print("Cancelled")
                },
                DSActionButtonConfig(title: "Delete", style: .secondary, isDestructive: true) { values in
                    print("Deleted: \(values)")
                }
            ]
        )
    }
}
