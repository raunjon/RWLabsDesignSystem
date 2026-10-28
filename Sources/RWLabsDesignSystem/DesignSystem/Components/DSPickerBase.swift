//
//  DSPickerBase.swift
//  RWLabsDesignSystem
//
//  Shared picker pieces, matching the Figma "Gender picker":
//    DSSelectionIndicator  gray ring when off, brand check square when on
//    DSOptionRow           52pt option row with the indicator on the right
//    DSPickerField         the closed field: title, value or placeholder, chevron
//    DSBasePicker          generic picker built from the three above
//
//  DSBasePicker("Gender", selection: $gender, options: Gender.allCases, placeholder: "Select") { gender in
//      Text(gender.title)
//  }
//
//  Presentation: .inline expands the option rows under the field (Figma), .menu uses the system menu.
//

import SwiftUI

// MARK: - Selection Indicator
/// The selection mark drawn by option rows, selection cards and `DSCheckbox`.
/// Display only: the row or button around it handles taps.
public struct DSSelectionIndicator: View {
    let isSelected: Bool
    let size: CGFloat

    public init(isSelected: Bool, size: CGFloat = .s18) {
        self.isSelected = isSelected
        self.size = size
    }

    public var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.Selection.indicatorFill)
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(.Selection.indicatorCheck)
            } else {
                Circle()
                    .strokeBorder(Color.Selection.indicatorBorder, lineWidth: 1.5)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityHidden(true)
    }
}

// MARK: - Option Row
/// A 52pt row: your content on the left, the selection mark on the right.
/// Selected rows take the raised surface with a soft shadow.
public struct DSOptionRow<Content: View>: View {
    @State var isSelected: Bool
    let content: Content

    public init(isSelected: Bool, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: .xs) {
            content
                .fontStyle(.body)
                .foregroundColor(.Input.text)
            Spacer(minLength: 0)
            DSSelectionIndicator(isSelected: isSelected)
                .frame(width: 40)
        }
        .padding(.leading, .md)
        .padding(.trailing, .sm)
        .frame(minHeight: 52)
        .background(
            RoundedRectangle(cornerRadius: .radiusLG)
                .fill(isSelected ? Color.Selection.surfaceSelected : Color.Selection.surface)
                .shadow(color: isSelected ? Color.Selection.shadow : .clear, radius: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLG)
                .strokeBorder(isSelected ? Color.Selection.borderSelected : Color.Selection.border, lineWidth: .thin)
        )
        .contentShape(RoundedRectangle(cornerRadius: .radiusLG))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Picker Field
/// The closed picker: an input field showing the value (or placeholder) and a chevron
/// that flips while the picker is open.
public struct DSPickerField<Value: View>: View {
    let title: String?
    let helper: String?
    let status: DSInputFieldStatus
    let icon: Image?
    let isOpen: Bool
    let value: Value?
    let placeholder: String

    public init(
        title: String? = nil,
        helper: String? = nil,
        status: DSInputFieldStatus = .normal,
        icon: Image? = nil,
        isOpen: Bool = false,
        placeholder: String = "Select",
        @ViewBuilder value: () -> Value?
    ) {
        self.title = title
        self.helper = helper
        self.status = status
        self.icon = icon
        self.isOpen = isOpen
        self.placeholder = placeholder
        self.value = value()
    }

    public var body: some View {
        DSInputField(title: title, helper: helper, status: status, isFocused: isOpen) {
            HStack(spacing: .xs) {
                if let icon {
                    icon.foregroundColor(.Input.icon)
                }
                if let value {
                    value
                } else {
                    Text(placeholder).foregroundColor(.Input.placeholder)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.system(size: DSInputFieldSize.large.iconSize, weight: .medium))
                    .foregroundColor(.Input.icon)
                    .rotationEffect(.degrees(isOpen ? 180 : 0))
            }
            .lineLimit(1)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Base Picker
public enum DSPickerPresentation: Sendable {
    /// Option rows expand under the field (Figma "Gender picker")
    case inline
    /// System menu anchored to the field
    case menu
}

/// Generic single-choice picker. You supply the options and how each one is drawn; the base
/// handles the field, the open/closed state and selection.
public struct DSBasePicker<Value: Hashable, OptionLabel: View>: View {
    @Binding var selection: Value?
    let options: [Value]
    let title: String?
    let placeholder: String
    let helper: String?
    let status: DSInputFieldStatus
    let icon: Image?
    let presentation: DSPickerPresentation
    let allowsDeselection: Bool
    let optionLabel: (Value) -> OptionLabel
    let externalIsExpanded: Binding<Bool>?

    @State private var internalIsExpanded = false
    @Environment(\.isEnabled) private var isEnabled

    private var isOpen: Bool {
        get { externalIsExpanded?.wrappedValue ?? internalIsExpanded }
        nonmutating set {
            if let externalIsExpanded { externalIsExpanded.wrappedValue = newValue } else { internalIsExpanded = newValue }
        }
    }

    /// - Parameters:
    ///   - allowsDeselection: Tapping the selected option again clears the selection.
    ///   - isExpanded: Optional binding to read or drive the inline open state.
    ///   - optionLabel: How an option looks, in the rows and in the closed field.
    public init(
        _ title: String? = nil,
        selection: Binding<Value?>,
        options: [Value],
        placeholder: String = "Select",
        helper: String? = nil,
        status: DSInputFieldStatus = .normal,
        icon: Image? = nil,
        presentation: DSPickerPresentation = .inline,
        allowsDeselection: Bool = false,
        isExpanded: Binding<Bool>? = nil,
        @ViewBuilder optionLabel: @escaping (Value) -> OptionLabel
    ) {
        self.externalIsExpanded = isExpanded
        self._selection = selection
        self.options = options
        self.title = title
        self.placeholder = placeholder
        self.helper = helper
        self.status = status
        self.icon = icon
        self.presentation = presentation
        self.allowsDeselection = allowsDeselection
        self.optionLabel = optionLabel
    }

    public var body: some View {
        switch presentation {
        case .inline: inlineBody
        case .menu:   menuBody
        }
    }

    private var field: some View {
        DSPickerField(
            title: title,
            helper: isOpen ? nil : helper,
            status: isEnabled ? status : .autofill,
            icon: icon,
            isOpen: isOpen,
            placeholder: placeholder
        ) {
            selection.map(optionLabel)
        }
    }

    private var inlineBody: some View {
        VStack(alignment: .leading, spacing: .xs) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isOpen.toggle() }
            } label: {
                field
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: .xs) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            select(option)
                            withAnimation(.easeInOut(duration: 0.2)) { isOpen = false }
                        } label: {
                            DSOptionRow(isSelected: option == selection) { optionLabel(option) }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var menuBody: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button { select(option) } label: {
                    if option == selection {
                        Label { optionLabel(option) } icon: { Image(systemName: "checkmark") }
                    } else {
                        optionLabel(option)
                    }
                }
            }
        } label: {
            field
        }
        .buttonStyle(.plain)
    }

    private func select(_ option: Value) {
        selection = (allowsDeselection && option == selection) ? nil : option
    }
}

public extension DSBasePicker where OptionLabel == Text {
    /// Options drawn with their `description`.
    init(
        _ title: String? = nil,
        selection: Binding<Value?>,
        options: [Value],
        placeholder: String = "Select",
        helper: String? = nil,
        status: DSInputFieldStatus = .normal,
        icon: Image? = nil,
        presentation: DSPickerPresentation = .inline,
        allowsDeselection: Bool = false,
        isExpanded: Binding<Bool>? = nil
    ) where Value: CustomStringConvertible {
        self.init(
            title,
            selection: selection,
            options: options,
            placeholder: placeholder,
            helper: helper,
            status: status,
            icon: icon,
            presentation: presentation,
            allowsDeselection: allowsDeselection,
            isExpanded: isExpanded
        ) { Text($0.description) }
    }
}

// MARK: - Preview
/// Mirrors the Figma Gender picker sheet: closed empty, closed with a value, open.
private struct DSBasePickerGallery: View {
    @State private var empty: String?
    @State private var gender: String? = "Female"
    @State private var menu: String? = "Male"
    private let genders = ["Male", "Female", "Others"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                DSBasePicker("Gender", selection: $empty, options: genders, placeholder: "")
                DSBasePicker("Gender", selection: $gender, options: genders)
                DSBasePicker("Gender (open)", selection: $gender, options: genders, isExpanded: .constant(true))
                DSBasePicker("Gender (menu)", selection: $menu, options: genders, presentation: .menu)
                DSBasePicker("Disabled", selection: $gender, options: genders).disabled(true)
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSBasePickerGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSBasePickerGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSBasePickerGallery().designSystem()
}
