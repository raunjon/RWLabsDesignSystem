//
//  DSHeightPicker.swift
//  RWLabsDesignSystem
//
//  Wheel-style height picker component
//

import SwiftUI

// MARK: - DSHeightPicker

public struct DSHeightPickerView: View {

    // MARK: - Properties
    @Binding var selectedHeight: Int
    @Binding var selectedMetricHeight: (Int, Int)
    @State var unit: DSHeightUnit
    let label: String?
    let isDisabled: Bool

    // MARK: - Initialization

   

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            // Label and Unit Toggle
            VStack {
                DSHeightUnitToggle(unit: $unit, isDisabled: isDisabled)
                    .disabled(isDisabled)
                DSHeightPicker(unit: $unit, selectedHeight: $selectedHeight, selectedMetricHeight: $selectedMetricHeight, isDisabled: isDisabled)
            }
        }
    }
}

// MARK: - Height Unit

public struct DSHeightPicker: View {
    @Binding public var selectedHeight: Int
    @Binding public var selectedMetricHeight: (Int, Int)
    @Binding public var unit: DSHeightUnit
    @State public var label: String?
    @State public var isDisabled: Bool
    
    public init(
        unit: Binding<DSHeightUnit>,
        selectedHeight: Binding<Int>,
        selectedMetricHeight: Binding<(Int, Int)> = .constant((5,11)),
        label: String? = nil,
        isDisabled: Bool = false
    ) {
        self._selectedHeight = selectedHeight
        self._selectedMetricHeight = selectedMetricHeight
        self._unit = unit
        self.label = label
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        DSCard {
            ZStack {
                switch unit {

                case .cm:
                    Picker("Height", selection: $selectedHeight) {
                        ForEach(heightOptions, id: \.self) { height in
                            DSText(formatHeight(height, unit: .cm))
                                .tag(height)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 212)
                    .disabled(isDisabled)
                    .id("cm")
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    

                case .inches:
                    Picker("Height", selection: $selectedHeight) {
                        ForEach(heightOptions, id: \.self) { height in
                            DSText(formatHeight(height, unit: .inches))
                                .tag(height)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 212)
                    .disabled(isDisabled)
                    .id("inches")
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                case .metric:
                    HStack {
                        Picker("Feet", selection: $selectedMetricHeight.0) {
                            ForEach(feetOptions, id: \.self) { height in
                                DSText(formatHeight(height))
                                    .tag(height)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 212)

                        Picker("Inches", selection: $selectedMetricHeight.1) {
                            ForEach(inchesOptions, id: \.self) { height in
                                DSText(formatHeight(height, unit: .inches))
                                    .tag(height)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 212)
                    }
                    .disabled(isDisabled)
                    .id("feet")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: unit)
    }
    
    // MARK: - Helpers

    private var heightOptions: [Int] {
        var options: [Int] = []
        var current = 60 // Start from 60.96 cm (24 inches)
        while current <= 363 { // End at 363.22 cm (143 inches)
            options.append(current)
            current += 1 // Increment by 2.54 cm (1 inch)
        }
        return options
    }
    
    private var feetOptions: [Int] {
        var options: [Int] = []
        var current = 2 // Start from 60.96 cm (24 inches)
        while current <= 12 { // End at 363.22 cm (143 inches)
            options.append(current)
            current += 1 // Increment by 2.54 cm (1 inch)
        }
        return options
    }
    
    private var inchesOptions: [Int] {
        var options: [Int] = []
        var current = 1 // Start from 60.96 cm (24 inches)
        while current <= 12 { // End at 363.22 cm (143 inches)
            options.append(current)
            current += 1 // Increment by 2.54 cm (1 inch)
        }
        return options
    }

    private func formatHeight(_ height: Int, unit: DSHeightUnit? = nil) -> String {
        switch unit {
        case .cm:
            return "\(height) cm"
        case .inches:
            let inches = height
            return "\(height)\""
        case .metric:
            let totalInches = height
            let feet = Int(totalInches / 12)
            let inches = 0//Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\""
            
        default:
            return "\(height)'"
        }
    }
}
public enum DSHeightUnit: String, CaseIterable {
    case cm = "cm"
    case inches = "in"
    case metric = "ft"

    var displayName: String {
        switch self {
        case .cm:
            return "Centimeters"
        case .inches:
            return "Inches"
        case .metric:
            return "Feet"
        }
    }

    var shortName: String {
        switch self {
        case .cm:
            return "cm"
        case .inches:
            return "in"
        case .metric:
            return "ft"
        }
    }
}

// MARK: - Height Unit Toggle

public struct DSHeightUnitToggle: View {
    @Binding public var unit: DSHeightUnit
    @State public var isDisabled: Bool = false
    @State public var label: String?
    @Namespace private var namespace
    
    public init(unit: Binding<DSHeightUnit>, isDisabled: Bool = false, label: String? = nil) {
        self._unit = unit
        self.isDisabled = isDisabled
        self.label = label
    }
    
    public var body: some View {
        VStack {
            if let label {
                DSText(label, style: .bodyMedium, color: isDisabled ? .Text.tertiary : .Text.primary)
            }
            HStack(spacing: .xxs) {
                ForEach([DSHeightUnit.metric, DSHeightUnit.cm], id: \.self) { option in
                    ZStack {
                        if unit == option {
                            RoundedRectangle(cornerRadius: .radiusLG)
                                .fill(Color.Background.primary)
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                        
                        DSText(
                            option.shortName,
                            style: .caption,
                            color: .Text.primary
                        )
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            unit = option
                        }
                    }
                }
                .frame(width: 28)
                .frame(height: 22)
                .animation(.easeInOut(duration: 0.2), value: unit)
            }
            .frame(height: 27)
            .padding(.horizontal, .xs)
            .padding(.vertical, .xxs)
            .background(Color.Background.secondary)
            .cornerRadius(.radiusFull)
            .shadow(.sm)
        }
    }
}

// MARK: - Preview

#Preview("Height Picker - CM") {
    struct PreviewWrapper: View {
        @State private var selectedHeight: Int = 170
        @State private var selectedMetricHeight: (Int,Int) = (5,11)
        @State private var unit: DSHeightUnit = .cm

        var body: some View {
            ZStack {
                Color.Background.primary.ignoresSafeArea()

                VStack(spacing: .xl) {
                    DSHeightUnitToggle(unit: $unit)
                    DSHeightPicker(
                        unit: $unit, selectedHeight: $selectedHeight,
                        selectedMetricHeight: $selectedMetricHeight,
                        label: "Select Height",
                        isDisabled: false
                    )

                    VStack(spacing: .sm) {
                        DSText("Selected Height:", style: .bodySmall, color: .Text.secondary)
                        DSText(String(format: "%d cm", selectedHeight), style: .title3, color: .Text.primary)
                        DSText(String(format: "%d cm", selectedMetricHeight.1), style: .title3, color: .Text.primary)
                        DSText(unit.shortName, style: .title3, color: .Text.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()
                }
                .padding()
            }
            .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}

#Preview("Height Picker - Disabled") {
    ZStack {
        Color.Background.primary.ignoresSafeArea()

        VStack(spacing: .xl) {
            DSHeightPicker(
                unit: .constant(.metric), selectedHeight: .constant(170),
                selectedMetricHeight: .constant((5,11)),
                label: "Select Height",
                isDisabled: true
            )

            Spacer()
        }
        .padding()
    }
    .preferredColorScheme(.light)
}

#Preview("Height Picker - Inches") {
    struct PreviewWrapper: View {
        @State private var selectedHeight: Int = 170
        @State private var selectedMetricHeight: (Int, Int) = (5,11)

        var body: some View {
            ZStack {
                Color.Background.primary.ignoresSafeArea()

                VStack(spacing: .xl) {
                    DSHeightPicker(
                        unit: .constant(.inches),
                        selectedHeight: $selectedHeight,
                        selectedMetricHeight: $selectedMetricHeight,
                        label: "Select Height",
                        isDisabled: false
                    )

                    Spacer()
                }
                .padding()
            }
            .preferredColorScheme(.light)
        }
    }

    return PreviewWrapper()
}
