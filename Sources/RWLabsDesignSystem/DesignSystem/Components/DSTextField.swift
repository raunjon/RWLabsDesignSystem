//
//  DSTextField.swift
//  RWLDesignSystem
//
//  Design system text field component
//

import SwiftUI

// MARK: - TextField State
public enum DSTextFieldState {
    case `default`
    case focused
    case error
    case disabled

    @MainActor
    var borderColor: Color {
        switch self {
        case .default:
            return Color.Border.default
        case .focused:
            return Color.Border.focused
        case .error:
            return Color.Border.error
        case .disabled:
            return Color.Border.disabled
        }
    }

    @MainActor
    var backgroundColor: Color {
        switch self {
        case .disabled:
            return Color.Background.secondary
        default:
            return Color.Background.primary
        }
    }
}

// MARK: - DSTextField Component
public struct DSTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    let label: String?
    let placeholder: String
    let helperText: String?
    let errorMessage: String?
    let isDisabled: Bool
    let isSecure: Bool
    let icon: Image?
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let autocapitalization: UITextAutocapitalizationType

    public init(
        text: Binding<String>,
        label: String? = nil,
        placeholder: String = "",
        helperText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false,
        isSecure: Bool = false,
        icon: Image? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: UITextAutocapitalizationType = .sentences
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
        self.isSecure = isSecure
        self.icon = icon
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
    }

    private var currentState: DSTextFieldState {
        if isDisabled {
            return .disabled
        } else if errorMessage != nil {
            return .error
        } else if isFocused {
            return .focused
        } else {
            return .default
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            // Label
            if let label = label {
                Text(label)
                    .fontStyle(.bodySmall)
                    .foregroundColor(Color.Text.secondary)
            }

            // Input Field
            HStack(spacing: .sm) {
                if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.Text.secondary)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .fontStyle(.body)
                        .disabled(isDisabled)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization == .none ? .never : (autocapitalization == .words ? .words : (autocapitalization == .sentences ? .sentences : .characters)))
                } else {
                    TextField(placeholder, text: $text)
                        .fontStyle(.body)
                        .disabled(isDisabled)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization == .none ? .never : (autocapitalization == .words ? .words : (autocapitalization == .sentences ? .sentences : .characters)))
                }
            }
            .padding(.input)
            .background(currentState.backgroundColor)
            .cornerRadius(.radiusXL)
            .border(currentState.borderColor, lineWidth: .medium, cornerRadius: .radiusXL)
            .onChange(of: isDisabled) { _, newValue in
                // Clear focus when disabled to prevent invalid session states
                if newValue {
                    isFocused = false
                }
            }

            // Helper or Error Text
            if let errorMessage = errorMessage {
                HStack(spacing: .xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color.Semantic.error)
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .fontStyle(.caption)
                        .foregroundColor(Color.Semantic.error)
                }
            } else if let helperText = helperText {
                Text(helperText)
                    .fontStyle(.caption)
                    .foregroundColor(Color.Text.tertiary)
            }
        }
    }
}

// MARK: - DSTextArea Component
public struct DSTextArea: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    let label: String?
    let placeholder: String
    let helperText: String?
    let errorMessage: String?
    let isDisabled: Bool
    let minHeight: CGFloat

    public init(
        text: Binding<String>,
        label: String? = nil,
        placeholder: String = "",
        helperText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false,
        minHeight: CGFloat = 120
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
        self.minHeight = minHeight
    }

    private var currentState: DSTextFieldState {
        if isDisabled {
            return .disabled
        } else if errorMessage != nil {
            return .error
        } else if isFocused {
            return .focused
        } else {
            return .default
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            // Label
            if let label = label {
                Text(label)
                    .fontStyle(.bodySmall)
                    .foregroundColor(Color.Text.secondary)
            }

            // Text Editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .fontStyle(.body)
                        .foregroundColor(Color.Text.tertiary)
                        .padding(.horizontal, DSSpacing.Component.inputPadding)
                        .padding(.vertical, DSSpacing.Component.inputPadding)
                }

                TextEditor(text: $text)
                    .fontStyle(.body)
                    .disabled(isDisabled)
                    .focused($isFocused)
                    .padding(.xs)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: minHeight)
            .background(currentState.backgroundColor)
            .cornerRadius(.radiusMD)
            .border(currentState.borderColor, lineWidth: .medium, cornerRadius: .radiusMD)
            .onChange(of: isDisabled) { _, newValue in
                // Clear focus when disabled to prevent invalid session states
                if newValue {
                    isFocused = false
                }
            }

            // Helper or Error Text
            if let errorMessage = errorMessage {
                HStack(spacing: .xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color.Semantic.error)
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .fontStyle(.caption)
                        .foregroundColor(Color.Semantic.error)
                }
            } else if let helperText = helperText {
                Text(helperText)
                    .fontStyle(.caption)
                    .foregroundColor(Color.Text.tertiary)
            }
        }
    }
}

// MARK: - Preview
struct DSTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .lg) {
            DSTextField(
                text: .constant(""),
                label: "Email",
                placeholder: "Enter your email",
                helperText: "We'll never share your email"
            )

            DSTextField(
                text: .constant(""),
                label: "Password",
                placeholder: "Enter password",
                isSecure: true,
                icon: Image(systemName: "lock.fill")
            )

            DSTextField(
                text: .constant("error@example.com"),
                label: "Email with Error",
                placeholder: "Enter your email",
                errorMessage: "This email is already taken"
            )

            DSTextField(
                text: .constant("Disabled"),
                label: "Disabled Field",
                placeholder: "Can't edit this",
                isDisabled: true
            )

            DSTextArea(
                text: .constant(""),
                label: "Description",
                placeholder: "Enter a description",
                helperText: "Maximum 500 characters"
            )
        }
        .padding()
    }
}

public struct DSText: View {
    @State public var text: String
    public var style: DSTypography.Style = .body
    public var color: Color = .Text.primary
    public var body: some View {
        Text(text)
            .typography(style, color: color)
    }
}
