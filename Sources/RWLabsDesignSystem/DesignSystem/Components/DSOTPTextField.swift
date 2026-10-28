//
//  DSOTPTextField.swift
//  RWLabsDesignSystem
//
//  OTP input matching the Figma "OTP field": 56pt circles that fill left to right,
//  with auto-advance and auto-backspace.
//
//  Figma states map onto the code length and error message:
//    1–5    → digits entered; the next empty circle shows the caret while focused
//    Error  → errorMessage set
//

import SwiftUI

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

    /// The circle that receives the next digit.
    private var activeIndex: Int {
        min(code.count, length - 1)
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
        VStack(alignment: .leading, spacing: .xxs) {
            if let label {
                Text(label)
                    .fontStyle(.bodySmall)
                    .foregroundColor(.Input.title)
            }

            // OTP Input Fields
            HStack(spacing: spacing) {
                ForEach(0..<length, id: \.self) { index in
                    OTPSingleField(
                        character: getCharacter(at: index),
                        showsCaret: focusedField != nil && index == code.count,
                        isError: errorMessage != nil,
                        isDisabled: isDisabled,
                        fieldSize: fieldSize
                    )
                    .onTapGesture {
                        // The hidden field is bound to the next empty circle, so focus that one
                        focusedField = activeIndex
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
            .textContentType(.oneTimeCode)
            .textInputAutocapitalization(.never)
            .frame(height: 0)
            .opacity(0)
            .focused($focusedField, equals: activeIndex)
            .disabled(isDisabled)

            if let message = errorMessage ?? helperText {
                DSInputHelper(message, isError: errorMessage != nil)
            }
        }
    }
}

// MARK: - Single OTP Field
private struct OTPSingleField: View {
    let character: String
    let showsCaret: Bool
    let isError: Bool
    let isDisabled: Bool
    let fieldSize: CGFloat

    /// Entered and active circles get the heavier 2pt ring; empty ones stay at 1pt.
    private var isEmphasized: Bool {
        isError || !character.isEmpty || showsCaret
    }

    private var borderColor: Color {
        if isDisabled { return .clear }
        if isError { return .Input.borderError }
        return isEmphasized ? .Input.borderFocused : .Input.otpBorderEmpty
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(isDisabled ? Color.Input.autofillBackground : Color.Input.background)

            Circle()
                .strokeBorder(borderColor, lineWidth: isEmphasized ? .medium : .thin)

            Text(showsCaret && character.isEmpty ? "|" : character)
                .fontStyle(.body)
                .foregroundColor(isError ? .Input.borderError : (isDisabled ? .Input.autofillText : .Input.text))
        }
        .frame(width: fieldSize, height: fieldSize)
        .contentShape(Circle())
    }
}

// MARK: - Preview
/// Mirrors the Figma OTP field sheet.
private struct DSOTPTextFieldGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .lg) {
            DSOTPTextField(code: .constant("1"))
            DSOTPTextField(code: .constant("12"))
            DSOTPTextField(code: .constant("123"))
            DSOTPTextField(code: .constant("1234"), label: "Enter OTP", helperText: "Check your messages for the code")
            DSOTPTextField(code: .constant("1234"), errorMessage: "Invalid OTP")
            DSOTPTextField(code: .constant("1234"), isDisabled: true)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSOTPTextFieldGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSOTPTextFieldGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSOTPTextFieldGallery().designSystem()
}
