//
//  DSTextField.swift
//  RWLabsDesignSystem
//
//  Ready-made text field and text area, built on DSInputField (see DSInputField.swift).
//

import SwiftUI

// MARK: - DSTextField Component
/// Convenience field with title, placeholder, helper/error text and a clear button,
/// built on `DSInputField` and `dsInputFieldStyle`.
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
    let trailingIcon: AnyView?
    let size: DSInputFieldSize
    let showsClearButton: Bool

    init(
        _ text: Binding<String>,
        label: String? = nil,
        placeholder: String = "",
        helperText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false,
        isSecure: Bool = false,
        icon: Image? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: UITextAutocapitalizationType = .sentences,
        trailingIcon: AnyView? = nil,
        size: DSInputFieldSize = .large,
        showsClearButton: Bool = true
    ) {
        self.init(text: text, label: label, placeholder: placeholder, helperText: helperText, errorMessage: errorMessage, isDisabled: isDisabled, isSecure: isSecure, icon: icon, keyboardType: keyboardType, textContentType: textContentType, autocapitalization: autocapitalization, trailingIcon: trailingIcon, size: size, showsClearButton: showsClearButton)
    }

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
        autocapitalization: UITextAutocapitalizationType = .sentences,
        trailingIcon: AnyView? = nil,
        size: DSInputFieldSize = .large,
        showsClearButton: Bool = true
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
        self.trailingIcon = trailingIcon
        self.size = size
        self.showsClearButton = showsClearButton
    }

    private var capitalization: TextInputAutocapitalization {
        switch autocapitalization {
        case .none:          .never
        case .words:         .words
        case .allCharacters: .characters
        default:             .sentences
        }
    }

    private var prompt: Text {
        Text(placeholder).foregroundColor(.Input.placeholder)
    }

    public var body: some View {
        DSInputField(
            title: label,
            helper: errorMessage ?? helperText,
            size: size,
            status: errorMessage != nil ? .error : .normal,
            isFocused: isFocused
        ) {
            HStack(spacing: .xs) {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(.Input.icon)
                }

                Group {
                    if isSecure {
                        SecureField("", text: $text, prompt: prompt)
                    } else {
                        TextField("", text: $text, prompt: prompt)
                    }
                }
                .focused($isFocused)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(capitalization)

                if let trailingIcon {
                    trailingIcon
                        .frame(width: size.iconSize, height: size.iconSize)
                        .foregroundColor(.Input.icon)
                } else if showsClearButton && !isDisabled {
                    DSInputClearButton(text: $text, size: size)
                }
            }
        }
        .disabled(isDisabled)
        .onChange(of: isDisabled) { _, newValue in
            // Clear focus when disabled to prevent invalid session states
            if newValue {
                isFocused = false
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

    public var body: some View {
        DSInputField(
            title: label,
            helper: errorMessage ?? helperText,
            status: errorMessage != nil ? .error : .normal,
            isFocused: isFocused
        ) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    // Matches TextEditor's built-in text insets
                    Text(placeholder)
                        .foregroundColor(.Input.placeholder)
                        .padding(.top, .xs)
                        .padding(.leading, 5)
                }

                TextEditor(text: $text)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: minHeight)
        }
        .disabled(isDisabled)
        .onChange(of: isDisabled) { _, newValue in
            // Clear focus when disabled to prevent invalid session states
            if newValue {
                isFocused = false
            }
        }
    }
}

// MARK: - Preview
private struct DSTextFieldGallery: View {
    @State private var email = ""
    @State private var password = "secret"
    @State private var name = "secret"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                DSTextField(text: $name, label: "First name", placeholder: "Enter your name", helperText: "We'll never share your name")
                DSTextField(text: $email, label: "Email", placeholder: "Enter your email", helperText: "We'll never share your email")
                DSTextField(text: $password, label: "Password", placeholder: "Enter password", isSecure: true, icon: Image(systemName: "lock"))
                DSTextField(text: .constant("Disabled"), label: "Disabled", isDisabled: true)
                DSTextArea(text: .constant(""), label: "Description", placeholder: "Enter a description", helperText: "Maximum 500 characters")
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSTextFieldGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSTextFieldGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSTextFieldGallery().designSystem()
}
