//
//  DSPicker.swift
//  RWLDesignSystem
//
//  Picker component with label and icon support
//

import SwiftUI

// MARK: - DSPicker

public struct DSPicker<T: Hashable & CustomStringConvertible>: View {

    // MARK: - Properties

    @Binding var selection: T
    let options: [T]
    let label: String?
    let icon: Image?
    let placeholder: String
    let isDisabled: Bool
    var labelView: AnyView?

    // MARK: - Initialization

    public init(
        selection: Binding<T>,
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
        self.labelView = nil
    }

    public init<Content: View>(
        selection: Binding<T>,
        options: [T],
        label: String? = nil,
        icon: Image? = nil,
        placeholder: String = "Select an option",
        isDisabled: Bool = false,
        @ViewBuilder labelView: @escaping () -> Content
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.icon = icon
        self.placeholder = placeholder
        self.isDisabled = isDisabled
        self.labelView = labelView().anyView()
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            if let label = label {
                Text(label)
                    .fontStyle(.bodyMedium)
                    .foregroundColor(isDisabled ? Color.Text.disabled : Color.Text.primary)
            }

            Menu {
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
                if let labelView {
                    labelView
                } else {
                    HStack {
                        if let icon = icon {
                            icon
                                .foregroundColor(Color.Text.disabled)
                        }
                        
                        Text(selection.description)
                            .fontStyle(.body)
                            .foregroundColor(Color.Text.primary)
                        
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
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
    }
}

// MARK: - Preview

#Preview("Picker") {
    VStack(spacing: .xl) {
        DSPicker(
            selection: .constant("Option 1"),
            options: ["Option 1", "Option 2", "Option 3"],
            label: "Choose Option"
        )

        DSPicker(
            selection: .constant("United States"),
            options: ["United States", "Canada", "Mexico"],
            label: "Country",
            icon: Image(systemName: "globe")
        )

        DSPicker(
            selection: .constant("Disabled"),
            options: ["Disabled", "Option"],
            label: "Disabled Picker",
            isDisabled: true
        )
    }
    .padding()
}

extension View {
    func anyView() -> AnyView {
        AnyView(self)
    }
}
