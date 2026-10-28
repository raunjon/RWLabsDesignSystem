//
//  DSRadioGroup.swift
//  RWLDesignSystem
//
//  Radio button group for single selection
//

import SwiftUI

// MARK: - DSRadioGroup

public struct DSRadioGroup<T: Hashable & CustomStringConvertible>: View {

    // MARK: - Properties

    @Binding var selection: T?
    let options: [T]
    let label: String?
    let isDisabled: Bool

    // MARK: - Initialization

    public init(
        selection: Binding<T?>,
        options: [T],
        label: String? = nil,
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.isDisabled = isDisabled
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            if let label = label {
                DSText(label, style: .bodySmallMedium, color: isDisabled ? Color.Text.tertiary : Color.Text.primary)
            }

            VStack(alignment: .leading, spacing: .xs) {
                ForEach(options, id: \.self) { option in
                    radioButton(for: option)
                }
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Radio Button

    @ViewBuilder
    private func radioButton(for option: T) -> some View {
        HStack(spacing: .sm) {
            DSRadio(
                isSelected: Binding(
                    get: { selection == option },
                    set: { if $0 { selection = option } }
                ),
                isEnabled: !isDisabled
            )

            DSText(option.description, style: .body, color: Color.Text.primary)

            Spacer()
        }
        .padding(.vertical, .xs)
    }
}

// MARK: - Preview

#Preview("Radio Group") {
    VStack(spacing: .xl) {
        DSRadioGroup(
            selection: .constant("option1"),
            options: ["option1", "option2", "option3"],
            label: "Choose One"
        )

        DSRadioGroup(
            selection: .constant("Small"),
            options: ["Small", "Medium", "Large"],
            label: "Size"
        )

        DSRadioGroup(
            selection: .constant("disabled"),
            options: ["disabled", "option"],
            label: "Disabled",
            isDisabled: true
        )
    }
    .padding()
}
