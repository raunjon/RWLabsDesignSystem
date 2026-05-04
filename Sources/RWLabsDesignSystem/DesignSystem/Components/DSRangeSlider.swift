//
//  DSRangeSlider.swift
//  RWLDesignSystem
//
//  Dual-handle range slider for selecting min-max range
//

import SwiftUI

// MARK: - DSRangeSlider

public struct DSRangeSlider: View {

    // MARK: - Properties

    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let range: ClosedRange<Double>
    let step: Double?
    let label: String?
    let showValues: Bool
    let isDisabled: Bool
    let valueFormatter: ((Double) -> String)?

    @State private var isDraggingLower = false
    @State private var isDraggingUpper = false

    // MARK: - Initialization

    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        label: String? = nil,
        showValues: Bool = true,
        isDisabled: Bool = false,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.step = step
        self.label = label
        self.showValues = showValues
        self.isDisabled = isDisabled
        self.valueFormatter = valueFormatter
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            // Label
            if let label = label {
                Text(label)
                    .fontStyle(.bodyMedium)
                    .foregroundColor(isDisabled ? Color.Text.tertiary : Color.Text.primary)
            }

            // Range display
            if showValues {
                HStack {
                    Text("\(formattedValue(lowerValue)) - \(formattedValue(upperValue))")
                        .fontStyle(.bodyMedium)
                        .foregroundColor(isDisabled ? Color.Text.tertiary : Color.Text.brand)
                }
            }

            // Range Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Rectangle()
                        .fill(Color.Background.secondary)
                        .frame(height: 4)
                        .cornerRadius(2)

                    // Active range track
                    Rectangle()
                        .fill(isDisabled ? Color.Text.disabled : Color.Text.brand)
                        .frame(width: activeRangeWidth(geometry.size.width), height: 4)
                        .offset(x: lowerThumbPosition(geometry.size.width))
                        .cornerRadius(2)

                    // Lower thumb
                    Circle()
                        .fill(isDisabled ? Color.Text.disabled : Color.Text.brand)
                        .frame(width: 20, height: 20)
                        .offset(x: lowerThumbPosition(geometry.size.width) - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isDisabled {
                                        isDraggingLower = true
                                        updateLowerValue(value.location.x, width: geometry.size.width)
                                    }
                                }
                                .onEnded { _ in
                                    isDraggingLower = false
                                }
                        )
                        .shadow(.lg)

                    // Upper thumb
                    Circle()
                        .fill(isDisabled ? Color.Text.disabled : Color.Text.brand)
                        .frame(width: 20, height: 20)
                        .offset(x: upperThumbPosition(geometry.size.width) - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isDisabled {
                                        isDraggingUpper = true
                                        updateUpperValue(value.location.x, width: geometry.size.width)
                                    }
                                }
                                .onEnded { _ in
                                    isDraggingUpper = false
                                }
                        )
                        .shadow(.lg)
                }
                .frame(height: 20)
            }
            .frame(height: 20)
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Helpers

    private func lowerThumbPosition(_ width: Double) -> Double {
        let percentage = (lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        return width * percentage
    }

    private func upperThumbPosition(_ width: Double) -> Double {
        let percentage = (upperValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        return width * percentage
    }

    private func activeRangeWidth(_ totalWidth: Double) -> Double {
        return upperThumbPosition(totalWidth) - lowerThumbPosition(totalWidth)
    }

    private func updateLowerValue(_ x: Double, width: Double) {
        let percentage = max(0, min(1, x / width))
        var newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)

        if let step = step {
            newValue = round(newValue / step) * step
        }

        // Ensure lower doesn't exceed upper
        lowerValue = min(newValue, upperValue)
    }

    private func updateUpperValue(_ x: Double, width: Double) {
        let percentage = max(0, min(1, x / width))
        var newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)

        if let step = step {
            newValue = round(newValue / step) * step
        }

        // Ensure upper doesn't go below lower
        upperValue = max(newValue, lowerValue)
    }

    private func formattedValue(_ value: Double) -> String {
        if let formatter = valueFormatter {
            return formatter(value)
        }
        return String(format: "%.0f", value)
    }
}

// MARK: - Preview

#Preview("Range Slider") {
    VStack(spacing: .xl) {
        DSRangeSlider(
            lowerValue: .constant(25),
            upperValue: .constant(75),
            label: "Price Range"
        )

        DSRangeSlider(
            lowerValue: .constant(1000),
            upperValue: .constant(4000),
            range: 0...5000,
            step: 100,
            label: "Budget",
            valueFormatter: { "$\(Int($0))" }
        )

        DSRangeSlider(
            lowerValue: .constant(30),
            upperValue: .constant(70),
            label: "Disabled Range",
            isDisabled: true
        )
    }
    .padding()
}
