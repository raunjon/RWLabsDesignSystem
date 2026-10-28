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
/// Phone number input matching the Figma "Phone number field": a country segment
/// (flag, dial code, chevron) joined to the number field, with a clear button.
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

    let countries: [CountryCode]
    let placeholder: String
    let status: DSInputFieldStatus

    @FocusState private var isFocused: Bool

    /// Figma's phone field is 46pt, between the small and large input sizes.
    private let height: CGFloat = 46

    public init(
        selectedCountryCode: Binding<CountryCode>,
        mobile: Binding<String>,
        countries: [CountryCode] = CountryCode.all,
        placeholder: String = "Enter your number",
        status: DSInputFieldStatus = .normal
    ) {
        self._selectedCountryCode = selectedCountryCode
        self._mobile = mobile
        self.countries = countries
        self.placeholder = placeholder
        self.status = status
    }

    private var borderColor: Color {
        if status == .error { return .Input.borderError }
        return isFocused ? .Input.borderFocused : .Input.border
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Country Code Dropdown
            DSPicker(selection: $selectedCountryCode, options: countries) {
                HStack(spacing: .xs) {
                    Text(selectedCountryCode.flag)
                    Text(selectedCountryCode.code)
                        .foregroundColor(.Input.text)
                    Image(systemName: "chevron.down")
                        .font(.system(size: DSInputFieldSize.large.iconSize))
                        .foregroundColor(.Input.icon)
                }
                .fontStyle(.body)
                .padding(.horizontal, .sm)
                .frame(maxHeight: .infinity)
            }

            Rectangle()
                .fill(borderColor)
                .frame(width: .thin)

            // Phone Number Input Field
            HStack(spacing: .xs) {
                TextField("", text: $mobile, prompt: Text(placeholder).foregroundColor(.Input.placeholder))
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .focused($isFocused)
                    .foregroundColor(.Input.text)
                    .tint(.Input.borderFocused)

                DSInputClearButton(text: $mobile)
            }
            .fontStyle(.body)
            .padding(.horizontal, .sm)
        }
        .frame(height: height)
        .background(Color.Input.background)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLG))
        .border(borderColor, lineWidth: .thin, cornerRadius: .radiusLG)
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

// MARK: - Preview
private struct DSMobileInputFieldGallery: View {
    @State private var country = CountryCode.all[0]
    @State private var empty = ""
    @State private var filled = "98765 43210"

    var body: some View {
        VStack(spacing: .lg) {
            DSMobileInputField(selectedCountryCode: $country, mobile: $empty)
            DSMobileInputField(selectedCountryCode: $country, mobile: $filled)
            DSMobileInputField(selectedCountryCode: $country, mobile: $filled, status: .error)
        }
        .padding(.lg)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSMobileInputFieldGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSMobileInputFieldGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSMobileInputFieldGallery().designSystem()
}
