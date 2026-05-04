//
//  DSDatePicker.swift
//  RWLDesignSystem
//
//  Date picker component with label support
//

import SwiftUI

// MARK: - DSDatePicker

public struct DSDatePicker: View {

    // MARK: - Style

    public enum Style {
        case dateOnly
        case timeOnly
        case dateAndTime
    }

    // MARK: - Properties

    @Binding var selection: Date
    let style: Style
    let label: String?
    let displayedComponents: DatePickerComponents
    let isDisabled: Bool

    // MARK: - Initialization

    public init(
        selection: Binding<Date>,
        style: Style = .dateOnly,
        label: String? = nil,
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.style = style
        self.label = label
        self.isDisabled = isDisabled

        switch style {
        case .dateOnly:
            self.displayedComponents = .date
        case .timeOnly:
            self.displayedComponents = .hourAndMinute
        case .dateAndTime:
            self.displayedComponents = [.date, .hourAndMinute]
        }
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            if let label = label {
                Text(label)
                    .fontStyle(.bodyMedium)
                    .foregroundColor(isDisabled ? Color.Text.tertiary : Color.Text.primary)
            }

            DatePicker(
                "",
                selection: $selection,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
            .accentColor(Color.Text.brand)
        }
    }
}

// MARK: - Preview

#Preview("Date Picker") {
    VStack(spacing: .xl) {
        DSDatePicker(
            selection: .constant(Date()),
            style: .dateOnly,
            label: "Select Date"
        )

        DSDatePicker(
            selection: .constant(Date()),
            style: .timeOnly,
            label: "Select Time"
        )

        DSDatePicker(
            selection: .constant(Date()),
            style: .dateAndTime,
            label: "Select Date & Time"
        )

        DSDatePicker(
            selection: .constant(Date()),
            label: "Disabled",
            isDisabled: true
        )
    }
    .padding()
}
