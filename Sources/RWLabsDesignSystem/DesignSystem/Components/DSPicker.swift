//
//  DSPicker.swift
//  RWLabsDesignSystem
//
//  Picker over values with a `description`, built on DSBasePicker (see DSPickerBase.swift).
//  Opens inline like the Figma "Gender picker" by default.
//

import SwiftUI

// MARK: - DSPicker
/// Always has a value.
public struct DSPicker<T: Hashable & CustomStringConvertible>: View {
    @Binding var selection: T
    let options: [T]
    let label: String?
    let icon: Image?
    let placeholder: String
    let helper: String?
    let presentation: DSPickerPresentation
    let isDisabled: Bool
    let labelView: AnyView?

    public init(
        selection: Binding<T>,
        options: [T],
        label: String? = nil,
        icon: Image? = nil,
        placeholder: String = "Select an option",
        helper: String? = nil,
        presentation: DSPickerPresentation = .inline,
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.icon = icon
        self.placeholder = placeholder
        self.helper = helper
        self.presentation = presentation
        self.isDisabled = isDisabled
        self.labelView = nil
    }

    /// A system menu with your own trigger, e.g. the country code in `DSMobileInputField`.
    public init<Content: View>(
        selection: Binding<T>,
        options: [T],
        label: String? = nil,
        icon: Image? = nil,
        placeholder: String = "Select an option",
        isDisabled: Bool = false,
        @ViewBuilder labelView: () -> Content
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.icon = icon
        self.placeholder = placeholder
        self.helper = nil
        self.presentation = .menu
        self.isDisabled = isDisabled
        self.labelView = AnyView(labelView())
    }

    public var body: some View {
        Group {
            if let labelView {
                Menu {
                    Picker(label ?? "", selection: $selection) {
                        ForEach(options, id: \.self) { Text($0.description).tag($0) }
                    }
                } label: {
                    labelView
                }
                .buttonStyle(.plain)
            } else {
                DSBasePicker(
                    label,
                    selection: Binding(get: { selection }, set: { if let new = $0 { selection = new } }),
                    options: options,
                    placeholder: placeholder,
                    helper: helper,
                    icon: icon,
                    presentation: presentation
                )
            }
        }
        .disabled(isDisabled)
    }
}

// MARK: - Preview
private struct DSPickerGallery: View {
    @State private var option = "Option 1"
    @State private var country: String?
    @State private var city: String? = "Pune"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                DSPicker(selection: $option, options: ["Option 1", "Option 2", "Option 3"], label: "Choose option")
                DSPicker(selection: $option, options: ["Option 1", "Option 2"], label: "Menu", presentation: .menu)
                DSOptionalPicker(selection: $country, options: ["India", "Canada"], label: "Country",
                                 icon: Image(systemName: "globe"), helper: "Where you live now")
                DSOptionalPicker(selection: $city, options: ["Pune", "Mumbai"], label: "Disabled", isDisabled: true)
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSPickerGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSPickerGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSPickerGallery().designSystem()
}
