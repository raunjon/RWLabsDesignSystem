//
//  DSHeightPicker.swift
//  RWLabsDesignSystem
//
//  Height wheel matching the Figma "Height picker cm/ft" and "height toggle".
//  One value in inches, shown as feet'inches or centimetres (2 decimals), so switching units
//  never loses precision.
//
//  @State var inches = 70
//  @State var unit: DSHeightUnit = .feet
//
//  DSHeightPickerView(heightInInches: $inches, unit: $unit)    // toggle + wheel
//  DSHeightPicker(heightInInches: $inches, unit: unit)         // wheel only
//

import SwiftUI

// MARK: - Height Unit
public enum DSHeightUnit: String, CaseIterable, Sendable {
    case feet = "ft"
    case cm = "cm"

    @available(*, deprecated, renamed: "feet")
    public static var metric: Self { .feet }

    public var displayName: String {
        switch self {
        case .feet: "Feet"
        case .cm:   "Centimeters"
        }
    }

    public var shortName: String { rawValue }

    /// Formats a height in inches for this unit: `5'10` or `177.80 cm`.
    public func format(inches: Int) -> String {
        switch self {
        case .feet: "\(inches / 12)'\(inches % 12)"
        case .cm:   String(format: "%.2f cm", Double(inches) * 2.54)
        }
    }
}

// MARK: - DSHeightPicker
/// The wheel in its Figma card.
public struct DSHeightPicker: View {
    @Binding var heightInInches: Int
    let unit: DSHeightUnit
    let range: ClosedRange<Int>

    /// - Parameter range: Selectable heights in inches. Figma lists 2'0 (60.96 cm) to 11'11 (363.22 cm).
    public init(heightInInches: Binding<Int>, unit: DSHeightUnit, range: ClosedRange<Int> = 24...143) {
        self._heightInInches = heightInInches
        self.unit = unit
        self.range = range
    }

    /// Bridges the old centimetre binding: `selectedHeight` is read and written in whole centimetres.
    @available(*, deprecated, message: "Use init(heightInInches:unit:range:)")
    public init(
        unit: Binding<DSHeightUnit>,
        selectedHeight: Binding<Int>,
        selectedMetricHeight: Binding<(Int, Int)> = .constant((5, 11)),
        label: String? = nil,
        isDisabled: Bool = false
    ) {
        self.init(
            heightInInches: Binding(
                get: { Int((Double(selectedHeight.wrappedValue) / 2.54).rounded()) },
                set: { selectedHeight.wrappedValue = Int((Double($0) * 2.54).rounded()) }
            ),
            unit: unit.wrappedValue
        )
    }

    public var body: some View {
        DSWheelPicker(selection: $heightInInches, options: Array(range)) { inches in
            Text(unit.format(inches: inches))
        }
        .id(unit)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: unit)
        .dsWheelCard()
    }
}

// MARK: - Height Unit Toggle
/// Figma "height toggle": ft | cm with a sliding thumb.
public struct DSHeightUnitToggle: View {
    @Binding var unit: DSHeightUnit

    public init(unit: Binding<DSHeightUnit>) {
        self._unit = unit
    }

    public var body: some View {
        DSPillToggle(selection: $unit, options: [.feet, .cm]) { Text($0.shortName) }
    }
}

// MARK: - DSHeightPickerView
/// Toggle above the wheel, right-aligned as in the onboarding screen.
public struct DSHeightPickerView: View {
    @Binding var heightInInches: Int
    @Binding var unit: DSHeightUnit
    let range: ClosedRange<Int>

    public init(heightInInches: Binding<Int>, unit: Binding<DSHeightUnit>, range: ClosedRange<Int> = 24...143) {
        self._heightInInches = heightInInches
        self._unit = unit
        self.range = range
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: .sm) {
            DSHeightUnitToggle(unit: $unit)
            DSHeightPicker(heightInInches: $heightInInches, unit: unit, range: range)
        }
    }
}

// MARK: - Preview
private struct DSHeightPickerGallery: View {
    @State private var inches = 84
    @State private var unit: DSHeightUnit = .cm

    var body: some View {
        VStack(spacing: .lg) {
            DSHeightPickerView(heightInInches: $inches, unit: $unit)
            DSHeightPicker(heightInInches: $inches, unit: .feet)
            HStack {
                DSHeightUnitToggle(unit: .constant(.feet))
                DSHeightUnitToggle(unit: .constant(.cm))
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSHeightPickerGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSHeightPickerGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSHeightPickerGallery().designSystem()
}
