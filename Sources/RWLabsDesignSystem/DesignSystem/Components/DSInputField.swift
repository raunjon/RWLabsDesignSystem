//
//  DSInputField.swift
//  RWLabsDesignSystem
//
//  The shared input field pieces, matching the Figma "Input fields" component.
//
//  Figma states map onto status plus focus:
//    Active    → focused
//    Inactive  → not focused
//    Autofill  → .autofill (also used for disabled fields)
//    Error     → .error
//
//  Style any field you build:
//
//  TextField("Email", text: $email)
//      .focused($isFocused)
//      .dsInputFieldStyle(status: .normal, isFocused: isFocused)
//
//  Or add Figma's title and helper row around it:
//
//  DSInputField(title: "Email", helper: "We'll never share it", isFocused: isFocused) {
//      TextField("Email", text: $email).focused($isFocused)
//  }
//
//  Any control fits inside: TextField, SecureField, a Menu label, a prefix icon…
//

import SwiftUI

// MARK: - Input Field Size
public enum DSInputFieldSize: CaseIterable, Sendable {
    /// 56pt field, 16px text
    case large
    /// 40pt field, 14px text
    case small

    var minHeight: CGFloat {
        switch self {
        case .large: 56
        case .small: 40
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large: .radiusLG
        case .small: .radiusMD
        }
    }

    var textStyle: DSTypography.Style {
        switch self {
        case .large: .body
        case .small: .bodySmall
        }
    }

    var titleStyle: DSTypography.Style {
        switch self {
        case .large: .bodySmall
        case .small: .label
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .large: 16
        case .small: 14
        }
    }
}

// MARK: - Input Field Status
public enum DSInputFieldStatus: Sendable {
    /// Bordered field; the border darkens while focused
    case normal
    /// Error border and helper text
    case error
    /// Filled, borderless field for system-filled values
    case autofill
}

// MARK: - Input Field Style
/// Draws the Figma field box around any content: text style, padding, fill and border.
/// Disabled fields take the autofill look, since Figma has no separate disabled state.
public struct DSInputFieldStyle: ViewModifier {
    let size: DSInputFieldSize
    let status: DSInputFieldStatus
    let isFocused: Bool

    @Environment(\.isEnabled) private var isEnabled

    public init(size: DSInputFieldSize = .large, status: DSInputFieldStatus = .normal, isFocused: Bool = false) {
        self.size = size
        self.status = status
        self.isFocused = isFocused
    }

    private var showsFill: Bool {
        status == .autofill || !isEnabled
    }

    private var borderColor: Color {
        if status == .error { return .Input.borderError }
        if showsFill { return .clear }
        return isFocused ? .Input.borderFocused : .Input.border
    }

    public func body(content: Content) -> some View {
        content
            .fontStyle(size.textStyle)
            .foregroundColor(showsFill ? .Input.autofillText : .Input.text)
            .tint(.Input.borderFocused)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .sm)
            .padding(.vertical, .xs)
            .frame(minHeight: size.minHeight)
            .background(showsFill ? Color.Input.autofillBackground : Color.Input.background)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .border(borderColor, lineWidth: .thin, cornerRadius: size.cornerRadius)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

public extension View {
    /// Style a field (or any row of content) as a design system input.
    func inputFieldStyle(
        size: DSInputFieldSize = .large,
        status: DSInputFieldStatus = .normal,
        isFocused: Bool = false
    ) -> some View {
        modifier(DSInputFieldStyle(size: size, status: status, isFocused: isFocused))
    }
}

// MARK: - Input Field Container
/// Figma's input layout: title, styled field, helper row. The field content is yours.
public struct DSInputField<Content: View>: View {
    let title: String?
    let helper: String?
    let size: DSInputFieldSize
    let status: DSInputFieldStatus
    let isFocused: Bool
    let content: Content

    public init(
        title: String? = nil,
        helper: String? = nil,
        size: DSInputFieldSize = .large,
        status: DSInputFieldStatus = .normal,
        isFocused: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.helper = helper
        self.size = size
        self.status = status
        self.isFocused = isFocused
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xxs) {
            if let title {
                Text(title)
                    .fontStyle(size.titleStyle)
                    .foregroundColor(.Input.title)
            }

            content
                .inputFieldStyle(size: size, status: status, isFocused: isFocused)

            if let helper {
                DSInputHelper(helper, isError: status == .error)
            }
        }
    }
}

// MARK: - Helper Row
/// The 12px helper line under a field: info color normally, error color on error.
public struct DSInputHelper: View {
    let text: String
    let isError: Bool

    public init(_ text: String, isError: Bool = false) {
        self.text = text
        self.isError = isError
    }

    public var body: some View {
        HStack(spacing: .xxs) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 12))
            Text(text)
                .fontStyle(.label)
        }
        .foregroundColor(isError ? .Input.helperError : .Input.helper)
    }
}

// MARK: - Clear Button
/// Trailing ✕ that empties the bound text. Hidden while the text is empty.
public struct DSInputClearButton: View {
    @Binding var text: String
    let size: DSInputFieldSize

    public init(text: Binding<String>, size: DSInputFieldSize = .large) {
        self._text = text
        self.size = size
    }

    public var body: some View {
        if !text.isEmpty {
            Button {
                text = ""
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: size.iconSize))
                    .foregroundColor(.Input.icon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear")
        }
    }
}

// MARK: - Preview
/// Mirrors the Figma Input fields sheet (Active, Inactive, Autofill, Error per size),
/// then shows different controls inside the same container.
private struct DSInputFieldGallery: View {
    @State private var password = "secret"
    @State private var amount = "120"
    @State private var gender = "Female"

    private func staticRow(_ size: DSInputFieldSize) -> some View {
        HStack {
            Text("Label")
            Spacer()
            Image(systemName: "xmark").font(.system(size: size.iconSize))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                ForEach(DSInputFieldSize.allCases, id: \.self) { size in
                    VStack(alignment: .leading, spacing: .md) {
                        DSInputField(title: "Label", helper: "Label", size: size, isFocused: true) { staticRow(size) }
                        DSInputField(title: "Label", helper: "Label", size: size) { staticRow(size) }
                        DSInputField(title: "Label", helper: "Label", size: size, status: .autofill) { staticRow(size) }
                        DSInputField(title: "Label", helper: "Label", size: size, status: .error) { staticRow(size) }
                        
                    }
                }

                DSInputField(title: "Password") {
                    HStack {
                        SecureField("Password", text: $password)
                        Image(systemName: "eye.slash").foregroundColor(.Input.icon)
                    }
                }

                DSTextField(text: $amount, label: "First name", placeholder: "Enter your name", helperText: "We'll never share your name")
                    .inputFieldStyle(status: .autofill, isFocused: false)

                DSInputField(title: "Amount", helper: "Paid monthly") {
                    HStack(spacing: .xs) {
                        Text("₹").foregroundColor(.Input.placeholder)
                        TextField("0", text: $amount).keyboardType(.decimalPad)

                    }
                }

                DSInputField(title: "Gender") {
                    Menu {
                        ForEach(["Female", "Male", "Other"], id: \.self) { option in
                            Button(option) { gender = option }
                        }
                    } label: {
                        HStack {
                            Text(gender).foregroundColor(.Input.text)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundColor(.Input.icon)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSInputFieldGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSInputFieldGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSInputFieldGallery().designSystem()
}
