//
//  DSOptionalPicker.swift
//  RWLDesignSystem
//
//  Picker component with optional selection support and label/icon support
//

import SwiftUI

// MARK: - DSOptionalPicker

public struct DSOptionalPicker<T: Hashable & CustomStringConvertible>: View {

    // MARK: - Properties

    @Binding var selection: T?
    let options: [T]
    let label: String?
    let icon: Image?
    let placeholder: String
    let isDisabled: Bool

    // MARK: - Initialization

    public init(
        selection: Binding<T?>,
        options: [T],
        label: String? = nil,
        icon: Image? = nil,
        placeholder: String = "Select an option",
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.icon = icon
        self.placeholder = placeholder
        self.isDisabled = isDisabled
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            if let label = label {
                Text(label)
                    .fontStyle(.bodyMedium)
                    .foregroundColor(isDisabled ? Color.Text.tertiary : Color.Text.primary)
            }

            Menu {
                // Clear button
                Button(action: {
                    if !isDisabled {
                        selection = nil
                    }
                }) {
                    if selection == nil {
                        Label("None", systemImage: "checkmark")
                    } else {
                        Text("None")
                    }
                }

                Divider()

                // Options
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if !isDisabled {
                            selection = option
                        }
                    }) {
                        if selection == option {
                            Label(option.description, systemImage: "checkmark")
                        } else {
                            Text(option.description)
                        }
                    }
                }
            } label: {
                HStack {
                    if let icon = icon {
                        icon
                            .foregroundColor(Color.Text.tertiary)
                    }

                    Text(selection?.description ?? placeholder)
                        .fontStyle(.body)
                        .foregroundColor(selection == nil ? Color.Text.tertiary : Color.Text.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color.Text.tertiary)
                }
                .padding(.horizontal, .md)
                .padding(.vertical, .sm)
                .background(Color.Background.secondary)
                .cornerRadius(.radiusMD)
                .border(Color.Border.default, lineWidth: .thin, cornerRadius: .radiusMD)
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
    }
}

// MARK: - Preview

#Preview("Optional Picker - Selected") {
    VStack(spacing: .xl) {
        DSOptionalPicker(
            selection: .constant("Option 1"),
            options: ["Option 1", "Option 2", "Option 3"],
            label: "Choose Option"
        )

        DSOptionalPicker(
            selection: .constant("United States"),
            options: ["United States", "Canada", "Mexico"],
            label: "Country",
            icon: Image(systemName: "globe")
        )

        Spacer()
    }
    .padding()
}

#Preview("Optional Picker - Nil") {
    VStack(spacing: .xl) {
        DSOptionalPicker(
            selection: .constant(nil as String?),
            options: ["Option 1", "Option 2", "Option 3"],
            label: "Choose Option"
        )

        DSOptionalPicker(
            selection: .constant(nil as String?),
            options: ["United States", "Canada", "Mexico"],
            label: "Country",
            icon: Image(systemName: "globe")
        )

        Spacer()
    }
    .padding()
}

#Preview("Optional Picker - Disabled") {
    VStack(spacing: .xl) {
        DSOptionalPicker(
            selection: .constant("Option 1"),
            options: ["Option 1", "Option 2", "Option 3"],
            label: "Disabled Picker",
            isDisabled: true
        )

        DSOptionalPicker(
            selection: .constant(nil as String?),
            options: ["United States", "Canada", "Mexico"],
            label: "Disabled (Nil)",
            isDisabled: true
        )

        Spacer()
    }
    .padding()
}
