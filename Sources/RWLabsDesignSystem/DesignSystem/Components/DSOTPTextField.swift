//
//  DSOTPTextField.swift
//  RWLabsDesignSystem
//
//  OTP Input Field Component with auto-advance and auto-backspace
//

import SwiftUI

// MARK: - OTP TextField State
public enum DSOTPTextFieldState {
    case `default`
    case focused
    case error
    case disabled

    @MainActor
    func borderColor(filled: Bool = false) -> Color {
        switch self {
        case .default:
            return filled ? Color.Border.dark : Color.Border.default
        case .focused:
            return focusedColor
        case .error:
            return Color.Border.error
        case .disabled:
            return Color.Border.disabled
        }
    }
    
    @MainActor
    var focusedColor: Color {
        Color.Border.active
    }

    @MainActor
    var borderWidth: CGFloat {
        switch self {
        case .focused:
            return DSBorderWidth.medium
        default:
            return DSBorderWidth.thin
        }
    }

    @MainActor
    var backgroundColor: Color {
        switch self {
        case .disabled:
            return Color.Button.disabled
        default:
            return Color.Background.primary
        }
    }
}

// MARK: - DSOTPTextField Component
public struct DSOTPTextField: View {
    @Binding var code: String
    @FocusState private var focusedField: Int?

    let length: Int
    let label: String?
    let helperText: String?
    let errorMessage: String?
    let isDisabled: Bool
    let onChange: ((String) -> Void)?

    private let fieldSize: CGFloat = 56
    private let spacing: CGFloat = 34

    public init(
        code: Binding<String>,
        length: Int = 4,
        label: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false,
        onChange: ((String) -> Void)? = nil
    ) {
        self._code = code
        self.length = length
        self.label = label
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
        self.onChange = onChange
    }

    private var currentState: DSOTPTextFieldState {
        if isDisabled {
            return .disabled
        } else if errorMessage != nil {
            return .error
        } else {
            return .default
        }
    }

    private func getCharacter(at index: Int) -> String {
        index < code.count ? String(code[code.index(code.startIndex, offsetBy: index)]) : ""
    }

    private func updateCode(newCode: String) {
        let filtered = newCode.filter { $0.isNumber }
        let truncated = String(filtered.prefix(length))

        if truncated != code {
            code = truncated
            onChange?(truncated)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            // Label
            if let label = label {
                DSText(label, style: .bodySmall, color: .Text.secondary)
            }

            // OTP Input Fields
            HStack(spacing: spacing) {
                ForEach(0..<length, id: \.self) { index in
                    OTPSingleField(
                        character: getCharacter(at: index),
                        state: currentState,
                        isFocused: focusedField == index,
                        isDisabled: isDisabled,
                        fieldSize: fieldSize
                    )
                    .frame(width: fieldSize, height: fieldSize)
                    .onTapGesture {
                        focusedField = index
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .onChange(of: code) { oldValue, newValue in
                // Auto-focus next field on character entry
                if newValue.count > oldValue.count {
                    if newValue.count < length {
                        focusedField = newValue.count
                    } else {
                        focusedField = nil
                    }
                } else if newValue.count < oldValue.count {
                    // Auto-focus previous field on backspace
                    focusedField = max(0, newValue.count)
                }
            }

            // Hidden TextField for actual input handling
            TextField("", text: Binding(
                get: { code },
                set: { updateCode(newCode: $0) }
            ))
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .frame(height: 0)
            .opacity(0)
            .focused($focusedField, equals: code.count < length ? code.count : length - 1)
            .disabled(isDisabled)

            // Helper or Error Text
            if let errorMessage = errorMessage {
                HStack(spacing: .xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color.Semantic.error)
                        .font(.system(size: 12))
                    DSText(errorMessage, style: .caption, color: .Semantic.error)
                }
            } else if let helperText = helperText {
                DSText(helperText, style: .caption, color: .Text.tertiary)
            }
        }
    }
}

// MARK: - Single OTP Field
private struct OTPSingleField: View {
    let character: String
    let state: DSOTPTextFieldState
    let isFocused: Bool
    let isDisabled: Bool
    let fieldSize: CGFloat

    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(state.backgroundColor)

            // Border
            Circle()
                .stroke(
                    isFocused ? state.focusedColor : (state.borderColor(filled: !character.isEmpty)),
                    lineWidth: isFocused ? state.borderWidth : DSBorderWidth.thin
                )

            // Cursor or Character
            if isFocused && character.isEmpty {
                DSText("|", style: .body, color: .Text.primary)
                    .opacity(0.7)
            } else {
                DSText(character, style: .body, color: character.isEmpty ? .Text.placeholder : .Text.primary)
            }
        }
        .frame(width: fieldSize, height: fieldSize)
    }
}

// MARK: - Preview
struct DSOTPTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .lg) {
            // Default state
            VStack(alignment: .leading, spacing: .md) {
                DSText("Default", style: .bodySmall, color: .Text.secondary)

                DSOTPTextField(
                    code: .constant("1"),
                    length: 4,
                    label: "Enter OTP",
                    helperText: "Check your email for the code"
                )
            }

            // With error
            VStack(alignment: .leading, spacing: .md) {
                DSText("With Error", style: .bodySmall, color: .Text.secondary)

                DSOTPTextField(
                    code: .constant("123"),
                    length: 4,
                    label: "Enter OTP",
                    errorMessage: "Invalid OTP"
                )
            }

            // Filled
            VStack(alignment: .leading, spacing: .md) {
                DSText("Complete", style: .bodySmall, color: .Text.secondary)

                DSOTPTextField(
                    code: .constant("1234"),
                    length: 4,
                    label: "Enter OTP"
                )
            }

            // Disabled
            VStack(alignment: .leading, spacing: .md) {
                DSText("Disabled", style: .bodySmall, color: .Text.secondary)

                DSOTPTextField(
                    code: .constant("1234"),
                    length: 4,
                    label: "Enter OTP",
                    isDisabled: true
                )
            }

            Spacer()
        }
        .padding()
    }
}
