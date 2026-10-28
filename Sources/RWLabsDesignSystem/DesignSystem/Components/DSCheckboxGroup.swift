//
//  DSCheckboxGroup.swift
//  RWLDesignSystem
//
//  Checkbox group for multiple selection
//

import SwiftUI

// MARK: - DSCheckboxGroup

public struct DSCheckboxGroup<T: Hashable & CustomStringConvertible>: View {

    // MARK: - Properties

    @Binding var selection: Set<T>
    let options: [T]
    let label: String?
    let isDisabled: Bool

    // MARK: - Initialization

    public init(
        selection: Binding<Set<T>>,
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
                    checkboxButton(for: option)
                }
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Checkbox Button

    @ViewBuilder
    private func checkboxButton(for option: T) -> some View {
        HStack(spacing: .sm) {
            DSCheckbox(
                isChecked: Binding(
                    get: { selection.contains(option) },
                    set: { isChecked in
                        if isChecked {
                            selection.insert(option)
                        } else {
                            selection.remove(option)
                        }
                    }
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

#Preview("Checkbox Group") {
    VStack(spacing: .xl) {
        DSCheckboxGroup(
            selection: .constant(["option1", "option3"]),
            options: ["option1", "option2", "option3"],
            label: "Select Multiple"
        )

        DSCheckboxGroup(
            selection: .constant(["WiFi"]),
            options: ["WiFi", "Bluetooth", "GPS"],
            label: "Features"
        )

        DSCheckboxGroup(
            selection: .constant(["disabled"]),
            options: ["disabled", "option"],
            label: "Disabled",
            isDisabled: true
        )
    }
    .padding()
}
