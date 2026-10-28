//
//  DSSlider.swift
//  RWLDesignSystem
//
//  Slider component with labels and value display
//

import SwiftUI

// MARK: - DSSlider

public struct DSSlider: View {

    // MARK: - Properties

    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double?
    let label: String?
    let showValue: Bool
    let showMinMax: Bool
    let isDisabled: Bool
    let valueFormatter: ((Double) -> String)?

    // MARK: - Initialization

    public init(
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        label: String? = nil,
        showValue: Bool = true,
        showMinMax: Bool = true,
        isDisabled: Bool = false,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.showValue = showValue
        self.showMinMax = showMinMax
        self.isDisabled = isDisabled
        self.valueFormatter = valueFormatter
        
        UISlider.appearance().minimumTrackTintColor = Color.Background.brand.uiColor()
        UISlider.appearance().maximumTrackTintColor = Color.Background.secondary.uiColor()

    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            // Label and value
            if label != nil || showValue {
                HStack {
                    if let label = label {
                        DSText(label, style: .bodySmallMedium, color: isDisabled ? Color.Text.secondary : Color.Text.primary)
                    }

                    Spacer()

                    if showValue {
                        DSText(formattedValue, style: .bodySmallMedium, color: isDisabled ? Color.Text.secondary : Color.Text.brand)
                    }
                }
            }

            // Slider
            HStack(spacing: .sm) {
                if showMinMax {
                    DSText(formattedMinValue, style: .label, color: Color.Text.secondary)
                        .frame(minWidth: 30, alignment: .trailing)
                }

                if let step = step {
                    Slider(value: $value, in: range, step: step)
                        .tint(Color.Background.brand)
                        .accentColor(.blue)
                        .disabled(isDisabled)
                } else {
                    Slider(value: $value, in: range)
                        .tint(Color.Background.brand)
                        .disabled(isDisabled)
                }

                if showMinMax {
                    DSText(formattedMaxValue, style: .label, color: Color.Text.secondary)
                        .frame(minWidth: 30, alignment: .leading)
                }
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Helpers

    private var formattedValue: String {
        if let formatter = valueFormatter {
            return formatter(value)
        }
        return String(format: "%.0f", value)
    }

    private var formattedMinValue: String {
        if let formatter = valueFormatter {
            return formatter(range.lowerBound)
        }
        return String(format: "%.0f", range.lowerBound)
    }

    private var formattedMaxValue: String {
        if let formatter = valueFormatter {
            return formatter(range.upperBound)
        }
        return String(format: "%.0f", range.upperBound)
    }
}

// MARK: - Preview

#Preview("Basic Slider") {
    VStack(spacing: .xl) {
        DSSlider(
            value: .constant(50),
            label: "Volume"
        )

        DSSlider(
            value: .constant(75),
            range: 0...100,
            step: 5,
            label: "Brightness",
            showValue: true
        )

        DSSlider(
            value: .constant(30),
            label: "Disabled Slider",
            isDisabled: true
        )

        DSSlider(
            value: .constant(2500),
            range: 0...5000,
            label: "Price",
            valueFormatter: { "$\(Int($0))" }
        )
    }
    .padding()
}
