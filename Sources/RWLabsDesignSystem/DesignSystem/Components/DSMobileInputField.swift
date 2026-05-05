//
//  DSMobileInputField.swift
//  RWLDesignSystem
//
//  Mobile phone number input field with country code selector.
//  Provides a complete phone input experience with country code dropdown,
//  phone number input field, and clear button.
//

import SwiftUI

// MARK: - Country Code Model
/// Represents a country with its phone code, flag, and display name.
/// Used by DSMobileInputField for country code selection.
public struct CountryCode: Identifiable, Hashable, CustomStringConvertible, Sendable {
    public let id: String
    public let code: String
    public let flag: String
    public let name: String

    public var description: String {
        "\(flag) \(code)"
    }

    /// Predefined list of supported countries
    public static let all: [CountryCode] = [
        CountryCode(id: "IN", code: "+91", flag: "🇮🇳", name: "India"),
        CountryCode(id: "US", code: "+1", flag: "🇺🇸", name: "United States"),
        CountryCode(id: "GB", code: "+44", flag: "🇬🇧", name: "United Kingdom"),
        CountryCode(id: "AU", code: "+61", flag: "🇦🇺", name: "Australia"),
        CountryCode(id: "CA", code: "+1", flag: "🇨🇦", name: "Canada"),
        CountryCode(id: "DE", code: "+49", flag: "🇩🇪", name: "Germany"),
        CountryCode(id: "FR", code: "+33", flag: "🇫🇷", name: "France"),
        CountryCode(id: "JP", code: "+81", flag: "🇯🇵", name: "Japan"),
    ]

    public init(id: String, code: String, flag: String, name: String) {
        self.id = id
        self.code = code
        self.flag = flag
        self.name = name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: CountryCode, rhs: CountryCode) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - DS Mobile Input Field Component
/// A complete mobile phone number input field with integrated country code selector.
///
/// Features:
/// - Country code dropdown with flag, code, and name
/// - Phone number input field with proper keyboard type
/// - Clear button that appears when text is entered
/// - Theme-aware styling using design system colors and typography
/// - Proper border and corner radius styling
///
/// Usage:
/// ```swift
/// @State var countryCode = CountryCode.all[0]
/// @State var phone = ""
///
/// DSMobileInputField(selectedCountryCode: $countryCode, mobile: $phone)
/// ```
public struct DSMobileInputField: View {
    /// Selected country code - binds to parent state for phone code selection
    @Binding public var selectedCountryCode: CountryCode
    /// Phone number input - binds to parent state for phone number entry
    @Binding public var mobile: String
    
    @FocusState var isFocused: Bool

    public init(selectedCountryCode: Binding<CountryCode>, mobile: Binding<String>) {
        self._selectedCountryCode = selectedCountryCode
        self._mobile = mobile
    }

    public var body: some View {
        // Phone Number Field with Country Code
        HStack(spacing: 0) {
            // Country Code Dropdown
            DSPicker(selection: $selectedCountryCode, options: CountryCode.all) {
                HStack(spacing: .s8) {
                    DSText(selectedCountryCode.flag, style: .body)
                    DSText(selectedCountryCode.code, style: .body)
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.Icon.secondary)
                }
                .frame(height: 46)
                .padding(.horizontal, .s8)
                .background(Color.Background.primary)
            }

            // Divider
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(Color.Border.default)

            // Phone Number Input Field
            HStack(spacing: .s8) {
                TextField("Enter your number", text: $mobile)
                    .foregroundColor(Color.Text.primary)
                    .keyboardType(.numberPad)
                    .accentColor(Color.Icon.brand)
                    .focused($isFocused)

                if !mobile.isEmpty {
                    Button(action: {
                        mobile = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.Text.placeholder)
                    }
                }
            }
            .frame(height: 46)
            .padding(.horizontal, .s12)
            .background(Color.Background.primary)
        }
        .frame(height: 46)
        .border(isFocused ? .Border.active : .Border.default, lineWidth: 1, cornerRadius: .r16)
        .animation(.easeInOut, value: isFocused)
    }
}

// MARK: - Preview
#Preview {
    @State var country = CountryCode.all[0]
    @State var phone = ""

    return DSMobileInputField(selectedCountryCode: $country, mobile: $phone)
        .padding(.s24)
}
