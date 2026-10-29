//
//  DSDateOfBirthTextField.swift
//  RWLDesignSystem
//
//  Date of birth text field component with auto-switching fields
//

import SwiftUI
import RWLabsFoundation

// MARK: - DSDateOfBirthTextField Component
public struct DSDateOfBirthTextField: View {
    @Binding var text: String
    @FocusState private var focusedField: DateField?

    @State private var day: String = ""
    @State private var month: String = ""
    @State private var year: String = ""

    let label: String?
    let helperText: String?
    let errorMessage: String?
    let isDisabled: Bool

    enum DateField {
        case day, month, year
    }

    public init(
        text: Binding<String>,
        label: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self._text = text
        self.label = label
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
        
        if let date = text.wrappedValue.toDate(.yyyyMMdd) {
            
            let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
            
            _day = State(initialValue:components.day?.toString() ?? "")
            _month = State(initialValue:components.month?.toString() ?? "")
            _year = State(initialValue:components.year?.toString() ?? "")
        } else {
            let components = text.wrappedValue.split(separator: "/")
            if components.count == 3 {
                self._day = State(initialValue: String(components[0]))
                self._month = State(initialValue: String(components[1]))
                self._year = State(initialValue: String(components[2]))
            }
        }
    }

    private func updateTextBinding() {
        let formattedDate = "\(year)-\(month)-\(day)"
        text = formattedDate
    }

    private func handleDayInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }

        if filtered.count <= 2 {
            day = filtered

            // Auto-switch to month when 2 digits entered
            if filtered.count == 2 {
                focusedField = .month
            }
        }

        updateTextBinding()
    }

    private func handleMonthInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }

        if filtered.count <= 2 {
            month = filtered

            // Auto-switch to year when 2 digits entered
            if filtered.count == 2 {
                focusedField = .year
            }
        }

        updateTextBinding()
    }

    private func handleYearInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }

        if filtered.count <= 4 {
            year = filtered
        }

        updateTextBinding()
    }

    public var body: some View {
        DSInputField(
            title: label,
            helper: errorMessage ?? helperText,
            status: errorMessage != nil ? .error : .normal,
            isFocused: focusedField != nil
        ) {
            // Input Fields
            HStack(spacing: .sm) {
                // Day Field
                TextField("DD", text: $day)
                    .onChange(of: day) { _, newValue in
                        handleDayInput(newValue)
                    }
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .day)
                    .disabled(isDisabled)
                    .frame(maxWidth: 40)
                    .multilineTextAlignment(.center)

                Text("/").foregroundColor(.Input.placeholder)
                    .frame(maxWidth: 10)

                // Month Field
                TextField("MM", text: $month)
                    .onChange(of: month) { _, newValue in
                        handleMonthInput(newValue)
                    }
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .month)
                    .disabled(isDisabled)
                    .frame(maxWidth: 40)
                    .multilineTextAlignment(.center)

                Text("/").foregroundColor(.Input.placeholder)
                    .frame(maxWidth: 10)

                // Year Field
                TextField("YYYY", text: $year)
                    .onChange(of: year) { _, newValue in
                        handleYearInput(newValue)
                    }
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .year)
                    .disabled(isDisabled)
                    .frame(maxWidth: 60)
                    .multilineTextAlignment(.center)

                Spacer()
            }
        }
        .disabled(isDisabled)
        .onChange(of: isDisabled) { _, newValue in
            if newValue {
                focusedField = nil
            }
        }
    }
}

#Preview {
    @State var dateOfBirth = ""

    return VStack(spacing: .lg) {
        DSDateOfBirthTextField(
            text: $dateOfBirth,
            label: "Date of Birth",
            helperText: "Format: DD/MM/YYYY"
        )

        DSDateOfBirthTextField(
            text: $dateOfBirth,
            label: "Date of Birth with Error",
            errorMessage: "Invalid date format"
        )

        DSDateOfBirthTextField(
            text: $dateOfBirth,
            label: "Disabled",
            isDisabled: true
        )
    }
    .padding()
}
