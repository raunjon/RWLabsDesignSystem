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
                DSText(label, style: .bodyMedium, color: isDisabled ? Color.Text.tertiary : Color.Text.primary)
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
        Button(action: {
            if !isDisabled {
                if selection.contains(option) {
                    selection.remove(option)
                } else {
                    selection.insert(option)
                }
            }
        }) {
            HStack(spacing: .sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .border(selection.contains(option) ? Color.Background.brand : Color.Border.default, lineWidth: 1)
                        .frame(width: 20, height: 20)

                    if selection.contains(option) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.Background.brand)
                            .frame(width: 20, height: 20)

                        Image(systemName: "checkmark")
                            .foregroundColor(Color.Icon.primary)
                    }
                }

                DSText(option.description, style: .body, color: Color.Text.primary)

                Spacer()
            }
            .padding(.vertical, .xs)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
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
