//
//  DSOptionalPicker.swift
//  RWLabsDesignSystem
//
//  Picker whose value may be empty, built on DSBasePicker (see DSPickerBase.swift).
//

import SwiftUI

// MARK: - DSOptionalPicker
/// May be empty: shows the placeholder, and tapping the selected option again clears it.
public struct DSOptionalPicker<T: Hashable & CustomStringConvertible>: View {
    @Binding var selection: T?
    let options: [T]
    let label: String?
    let icon: Image?
    let placeholder: String
    let helper: String?
    let presentation: DSPickerPresentation
    let isDisabled: Bool

    public init(
        selection: Binding<T?>,
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
    }

    public var body: some View {
        DSBasePicker(
            label,
            selection: $selection,
            options: options,
            placeholder: placeholder,
            helper: helper,
            icon: icon,
            presentation: presentation,
            allowsDeselection: true
        )
        .disabled(isDisabled)
    }
}
