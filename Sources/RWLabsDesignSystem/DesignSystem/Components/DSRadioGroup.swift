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
                DSText(label, style: .bodyMedium, color: isDisabled ? Color.Text.tertiary : Color.Text.primary)
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
        Button(action: {
            if !isDisabled {
                selection = option
            }
        }) {
            HStack(spacing: .sm) {
                ZStack {
                    Circle()
                        .stroke(selection == option ? Color.Border.active : Color.Border.default, lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if selection == option {
                        Circle()
                            .fill(Color.Border.active)
                            .frame(width: 10, height: 10)
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
