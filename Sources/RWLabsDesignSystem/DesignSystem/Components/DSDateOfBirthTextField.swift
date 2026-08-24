//
//  DSDateOfBirthTextField.swift
//  RWLDesignSystem
//
//  Date of birth text field component with auto-switching fields
//

import SwiftUI

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
        
        if let date = text.wrappedValue.toDate(format: .yyyyMMdd) {
            
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

    private var currentState: DSTextFieldState {
        if isDisabled {
            return .disabled
        } else if errorMessage != nil {
            return .error
        } else if focusedField != nil {
            return .focused
        } else {
            return .default
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
        VStack(alignment: .leading, spacing: .xs) {
            // Label
            if let label = label {
                DSText(label, style: .bodySmall, color: Color.Text.secondary)
            }

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

                DSText("/", style: .body, color: Color.Text.secondary)
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

                DSText("/", style: .body, color: Color.Text.secondary)
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
            .padding(.input)
            .background(currentState.backgroundColor)
            .cornerRadius(.radiusXL)
            .border(currentState.borderColor, lineWidth: .medium, cornerRadius: .radiusXL)
            .onChange(of: isDisabled) { _, newValue in
                if newValue {
                    focusedField = nil
                }
            }

            // Helper or Error Text
            if let errorMessage = errorMessage {
                HStack(spacing: .xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color.Semantic.error)
                        .font(.system(size: 12))
                    DSText(errorMessage, style: .caption, color: Color.Semantic.error)
                }
            } else if let helperText = helperText {
                DSText(helperText, style: .caption, color: Color.Text.tertiary)
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

enum DateFormat: String {
    
    // MARK: - ISO Formats
    
    /// 2026-05-10T11:53:24Z
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    /// 2026-05-10T11:53:24.883Z
    case iso8601Milliseconds = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    // MARK: - Standard Date Formats
    
    /// 2026-05-10
    case yyyyMMdd = "yyyy-MM-dd"
    
    /// 10/05/2026
    case ddMMyyyy = "dd/MM/yyyy"
    
    /// 05/10/2026
    case mmddyyyy = "MM/dd/yyyy"
    
    /// 10 May 2026
    case ddMMMYYYY = "dd MMM yyyy"
    
    /// 10 May, 2026
    case ddMMMCommaYYYY = "dd MMM, yyyy"
    
    /// 10 May 2026, Sunday
    case ddMMMMYYYYEEEE = "dd MMMM yyyy, EEEE"
    
    /// 10 May 2026
    case ddMMMMYYYY = "dd MMMM yyyy"
    
    
    // MARK: - Time Formats
    
    /// 23:45
    case time24Hour = "HH:mm"
    
    /// 11:45 PM
    case time12Hour = "hh:mm a"
    
    /// 23:45:12
    case fullTime24Hour = "HH:mm:ss"
    
    /// 11:45:12 PM
    case fullTime12Hour = "hh:mm:ss a"
    
    
    // MARK: - Date & Time
    
    /// 2026-05-10 23:45:12
    case fullDateTime24 = "yyyy-MM-dd HH:mm:ss"
    
    /// 10 May 2026 11:45 PM
    case fullDateTime12 = "dd MMM yyyy hh:mm a"
    
    /// 10 May 2026 • 11:45 PM
    case feedDate = "dd MMM yyyy • hh:mm a"
    
    /// Sunday, 10 May 2026 • 11:45 PM
    case detailedFeedDate = "EEEE, dd MMM yyyy • hh:mm a"
    
    
    // MARK: - Chat / Messaging
    
    /// 11:45 PM
    case chatTimestamp = "hh:hh:mm a"
    
    /// Yesterday
    case relativeDay = "relative"
    
    /// 10 May, 11:45 PM
    case messageDate = "dd MMM, hh:mm a"
    
    /// Sun
    case shortWeekday = "EEE"
    
    /// Sunday
    case weekday = "EEEE"
    
    
    // MARK: - Month / Year
    
    /// May 2026
    case monthYear = "MMMM yyyy"
    
    /// May
    case monthOnly = "MMMM"
    
    /// May 10
    case monthDay = "MMMM dd"
    
    /// May 10, 2026
    case monthDayYear = "MMMM dd, yyyy"
    
    /// May 2026
    case shortMonthYear = "MMM yyyy"
    
    
    // MARK: - API / Backend
    
    /// 20260510114512
    case backendTimestamp = "yyyyMMddHHmmss"
    
    /// 2026_05_10
    case backendDateUnderscore = "yyyy_MM_dd"
    
    /// 1746874404
    case unixTimestamp = "unix"
}

extension Date {
    
    func formatted(
        _ format: DateFormat,
        timeZone: TimeZone = .current,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = timeZone
        formatter.locale = locale
        
        return formatter.string(from: self)
    }
}

extension String {
    
    func toDate(
        format: DateFormat = .iso8601Milliseconds,
        timeZone: TimeZone = .autoupdatingCurrent,
        locale: Locale = .current
    ) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = timeZone
        formatter.locale = locale
        return formatter.date(from: self)
    }
}

extension Int {
    func toString() -> String {
        return "\(self)"
    }
}
