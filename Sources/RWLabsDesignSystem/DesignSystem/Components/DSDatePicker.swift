//
//  DSDatePicker.swift
//  RWLabsDesignSystem
//
//  Date and time picker in the same field as the other pickers (DSPickerField). Tapping the
//  field opens the calendar (or time wheel) inline below it, like DSBasePicker.
//  There is no Figma design; it follows the Gender picker's field and surface styling.
//
//  DSDatePicker(selection: $date, label: "Date of event", in: Date()...)
//

import SwiftUI

public struct DSDatePicker: View {

    public enum Style {
        case dateOnly
        case timeOnly
        case dateAndTime
    }

    @Binding var selection: Date
    let style: Style
    let label: String?
    let helper: String?
    let range: ClosedRange<Date>?
    let isDisabled: Bool
    let externalIsExpanded: Binding<Bool>?

    @State private var internalIsExpanded = false

    private var isOpen: Bool {
        get { externalIsExpanded?.wrappedValue ?? internalIsExpanded }
        nonmutating set {
            if let externalIsExpanded { externalIsExpanded.wrappedValue = newValue } else { internalIsExpanded = newValue }
        }
    }

    /// - Parameters:
    ///   - range: Selectable dates; `nil` for no limit.
    ///   - isExpanded: Optional binding to read or drive the open state.
    public init(
        selection: Binding<Date>,
        style: Style = .dateOnly,
        label: String? = nil,
        helper: String? = nil,
        in range: ClosedRange<Date>? = nil,
        isDisabled: Bool = false,
        isExpanded: Binding<Bool>? = nil
    ) {
        self._selection = selection
        self.style = style
        self.label = label
        self.helper = helper
        self.range = range
        self.isDisabled = isDisabled
        self.externalIsExpanded = isExpanded
    }

    private var components: DatePickerComponents {
        switch style {
        case .dateOnly:    .date
        case .timeOnly:    .hourAndMinute
        case .dateAndTime: [.date, .hourAndMinute]
        }
    }

    private var formatted: String {
        switch style {
        case .dateOnly:    selection.formatted(date: .abbreviated, time: .omitted)
        case .timeOnly:    selection.formatted(date: .omitted, time: .shortened)
        case .dateAndTime: selection.formatted(date: .abbreviated, time: .shortened)
        }
    }

    private var icon: Image {
        Image(systemName: style == .timeOnly ? "clock" : "calendar")
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isOpen.toggle() }
            } label: {
                DSPickerField(
                    title: label,
                    helper: isOpen ? nil : helper,
                    status: isDisabled ? .autofill : .normal,
                    icon: icon,
                    isOpen: isOpen
                ) {
                    Text(formatted)
                }
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)

            if isOpen {
                picker
                    .labelsHidden()
                    .tint(.Selection.indicatorFill)
                    .padding(.sm)
                    .background(
                        RoundedRectangle(cornerRadius: .radiusLG)
                            .fill(Color.Selection.surface)
                            .shadow(color: Color.Selection.shadow, radius: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusLG)
                            .strokeBorder(Color.Selection.border, lineWidth: .thin)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private var picker: some View {
        let base = Group {
            if let range {
                DatePicker("", selection: $selection, in: range, displayedComponents: components)
            } else {
                DatePicker("", selection: $selection, displayedComponents: components)
            }
        }
        if style == .timeOnly {
            base.datePickerStyle(.wheel)
        } else {
            base.datePickerStyle(.graphical)
        }
    }
}

// MARK: - Preview
private struct DSDatePickerGallery: View {
    @State private var date = Date()
    @State private var time = Date()
    @State private var event = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                DSDatePicker(selection: $date, label: "Date", helper: "Pick any day")
                DSDatePicker(selection: $time, style: .timeOnly, label: "Time")
                DSDatePicker(selection: $event, style: .dateAndTime, label: "Event", in: Date()...Date().addingTimeInterval(86_400 * 60),
                             isExpanded: .constant(true))
                DSDatePicker(selection: .constant(Date()), label: "Disabled", isDisabled: true)
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSDatePickerGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSDatePickerGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSDatePickerGallery().designSystem()
}
