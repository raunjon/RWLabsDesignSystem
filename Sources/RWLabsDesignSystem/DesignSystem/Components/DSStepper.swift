//
//  DSStepper.swift
//  RWLDesignSystem
//
//  Increment/decrement stepper with optional text input
//

import SwiftUI

// MARK: - DSStepper

public struct DSStepper: View {

    // MARK: - Properties

    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let label: String?
    let showTextField: Bool
    let isDisabled: Bool
    let valueFormatter: ((Int) -> String)?

    // MARK: - Initialization

    public init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        label: String? = nil,
        showTextField: Bool = false,
        isDisabled: Bool = false,
        valueFormatter: ((Int) -> String)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.showTextField = showTextField
        self.isDisabled = isDisabled
        self.valueFormatter = valueFormatter
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            if let label = label {
                DSText(label, style: .bodyMedium, color: isDisabled ? Color.Text.tertiary : Color.Text.primary)
            }

            HStack(spacing: .sm) {
                // Decrement button
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(canDecrement ? Color.Icon.brand : Color.Icon.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.Background.secondary)
                        .cornerRadius(.radiusMD)
                        .border(Color.Border.default, lineWidth: .thin, cornerRadius: .radiusMD)
                }
                .disabled(!canDecrement || isDisabled)

                // Value display or text field
                if showTextField {
                    TextField("", value: $value, format: .number)
                        .fontStyle(.bodyMedium)
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 60)
                        .padding(.horizontal, .sm)
                        .padding(.vertical, .xs)
                        .background(Color.Background.secondary)
                        .cornerRadius(.radiusMD)
                        .border(Color.Border.default, lineWidth: .thin, cornerRadius: .radiusMD)
                        .disabled(isDisabled)
                } else {
                    DSText(formattedValue, style: .bodyMedium, color: Color.Text.primary)
                        .frame(minWidth: 60)
                }

                // Increment button
                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(canIncrement ? Color.Icon.brand : Color.Icon.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.Background.secondary)
                        .cornerRadius(.radiusMD)
                        .border(Color.Border.default, lineWidth: .thin, cornerRadius: .radiusMD)
                }
                .disabled(!canIncrement || isDisabled)
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Helpers

    private var canIncrement: Bool {
        value + step <= range.upperBound
    }

    private var canDecrement: Bool {
        value - step >= range.lowerBound
    }

    private func increment() {
        if canIncrement {
            value += step
        }
    }

    private func decrement() {
        if canDecrement {
            value -= step
        }
    }

    private var formattedValue: String {
        if let formatter = valueFormatter {
            return formatter(value)
        }
        return "\(value)"
    }
}

// MARK: - Preview

#Preview("Stepper") {
    VStack(spacing: .xl) {
        DSStepper(
            value: .constant(5),
            range: 0...10,
            label: "Quantity"
        )

        DSStepper(
            value: .constant(3),
            range: 1...5,
            label: "With Text Field",
            showTextField: true
        )

        DSStepper(
            value: .constant(50),
            range: 0...100,
            step: 10,
            label: "Step by 10"
        )

        DSStepper(
            value: .constant(5),
            label: "Disabled",
            isDisabled: true
        )
    }
    .padding()
}
