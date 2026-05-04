//
//  DSModalPicker.swift
//  RWLDesignSystem
//
//  Modal picker with searchbar - supports single and multiselect
//

import SwiftUI

// MARK: - DSModalPickerSingle

public struct DSModalPickerSingle<T: Identifiable & Equatable & Hashable>: View {
    @Binding var isPresented: Bool
    @Binding var selection: T?
    let options: [T]
    let label: String?
    let placeholder: String?
    let icon: Image?
    let displayText: (T) -> String
    let searchFilter: (T, String) -> Bool
    let onSelectionChange: (T?, T?) -> Void

    @State private var searchQuery: String = ""

    private var filteredOptions: [T] {
        if searchQuery.isEmpty {
            return options
        }
        return options.filter { searchFilter($0, searchQuery) }
    }

    private var displayValue: String {
        return selection.map(displayText) ?? placeholder ?? ""
    }

    private var hasSelection: Bool {
        selection != nil
    }
    
    public init(isPresented: Binding<Bool>,
                selection: Binding<T?>,
                options: [T],
                label: String? = nil,
                placeholder: String? = nil,
                icon: Image? = nil,
                displayText: @escaping (T) -> String,
                searchFilter: @escaping (T, String) -> Bool = {_,_ in true},
                onSelectionChange: @escaping (T?, T?) -> Void = { _,_ in})   {
            
            self._isPresented = isPresented
            self._selection = selection
            self.options = options
            self.label = label
            self.placeholder = placeholder
            self.icon = icon
            self.displayText = displayText
            self.searchFilter = searchFilter
            self.onSelectionChange = onSelectionChange
    }
    
    public var body: some View {
        if #available(iOS 17.0, *) {
            ModalPickerContent(
                selection: $selection,
                oldValue: nil,
                multiSelection: Binding.constant([]),
                isPresented: $isPresented,
                isMultiSelect: false,
                options: options,
                title: label ?? "Select",
                searchQuery: $searchQuery,
                filteredOptions: filteredOptions,
                displayText: displayText,
                onSelectionChange: onSelectionChange
            )
            .onChange(of: selection) { oldValue, newValue in
                onSelectionChange(oldValue, newValue)
            }
        } else {
            ModalPickerContent(
                selection: $selection,
                oldValue: nil,
                multiSelection: Binding.constant([]),
                isPresented: $isPresented,
                isMultiSelect: false,
                options: options,
                title: label ?? "Select",
                searchQuery: $searchQuery,
                filteredOptions: filteredOptions,
                displayText: displayText,
                onSelectionChange: onSelectionChange
            )
        }
    }
}

// MARK: - DSModalPicker

public struct DSModalPicker<T: Identifiable & Equatable & Hashable>: View where T.ID == String {
    @Binding var selection: T?
    @Binding var multiSelection: Set<T>
    @Binding var isPresented: Bool

    let options: [T]
    let label: String?
    let placeholder: String
    let icon: Image?
    let isMultiSelect: Bool
    let displayText: (T) -> String
    let multiDisplayText: (Set<T>) -> String
    let searchFilter: (T, String) -> Bool

    @State private var searchQuery: String = ""

    // Single select initializer
    public init(
        selection: Binding<T?>,
        isPresented: Binding<Bool>,
        options: [T],
        label: String? = nil,
        placeholder: String = "Select an option",
        icon: Image? = nil,
        displayText: @escaping (T) -> String,
        searchFilter: @escaping (T, String) -> Bool
    ) {
        self._selection = selection
        self._multiSelection = .constant([])
        self._isPresented = isPresented
        self.options = options
        self.label = label
        self.placeholder = placeholder
        self.icon = icon
        self.isMultiSelect = false
        self.displayText = displayText
        self.multiDisplayText = { _ in "" }
        self.searchFilter = searchFilter
    }

    // Multi select initializer
    public init(
        multiSelection: Binding<Set<T>>,
        isPresented: Binding<Bool>,
        options: [T],
        label: String? = nil,
        placeholder: String = "Select options",
        icon: Image? = nil,
        displayText: @escaping (T) -> String,
        multiDisplayText: @escaping (Set<T>) -> String = { set in
            "\(set.count) selected"
        },
        searchFilter: @escaping (T, String) -> Bool
    ) {
        self._selection = .constant(nil)
        self._multiSelection = multiSelection
        self._isPresented = isPresented
        self.options = options
        self.label = label
        self.placeholder = placeholder
        self.icon = icon
        self.isMultiSelect = true
        self.displayText = displayText
        self.multiDisplayText = multiDisplayText
        self.searchFilter = searchFilter
    }

    private var filteredOptions: [T] {
        if searchQuery.isEmpty {
            return options
        }
        return options.filter { searchFilter($0, searchQuery) }
    }

    private var displayValue: String {
        if isMultiSelect {
            return multiSelection.isEmpty ? placeholder : multiDisplayText(multiSelection)
        } else {
            return selection.map(displayText) ?? placeholder
        }
    }

    private var hasSelection: Bool {
        isMultiSelect ? !multiSelection.isEmpty : selection != nil
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            // Label
            if let label = label {
                Text(label)
                    .fontStyle(.bodySmall)
                    .foregroundColor(Color.Text.secondary)
            }

            // Trigger Button
            Button(action: {
                isPresented = true
            }) {
                HStack {
                    if let icon = icon {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.Text.tertiary)
                    }

                    Text(displayValue)
                        .fontStyle(.body)
                        .foregroundColor(hasSelection ? Color.Text.primary : Color.Text.tertiary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(Color.Text.tertiary)
                }
                .padding(.md)
                .background(Color.Background.secondary)
                .cornerRadius(.radiusMD)
                .border(.Border.default, lineWidth: 1)
            }
        }
        .sheet(isPresented: $isPresented) {
            ModalPickerContent(
                selection: $selection,
                oldValue: nil,
                multiSelection: $multiSelection,
                isPresented: $isPresented,
                isMultiSelect: isMultiSelect,
                options: options,
                title: label ?? "Select",
                searchQuery: $searchQuery,
                filteredOptions: filteredOptions,
                displayText: displayText,
                onSelectionChange: {_,_ in }
            )
        }
    }
}



// MARK: - Modal Content

private struct ModalPickerContent<T: Identifiable & Equatable & Hashable>: View  {
    @Binding var selection: T?
    let oldValue: T?
    @Binding var multiSelection: Set<T>
    @Binding var isPresented: Bool
    let isMultiSelect: Bool
    let options: [T]
    let title: String
    @Binding var searchQuery: String
    let filteredOptions: [T]
    let displayText: (T) -> String
    let onSelectionChange: (T?, T?) -> Void
    @State var toChange: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(searchQuery: $searchQuery)

            Divider()

            if filteredOptions.isEmpty {
                EmptySearchState()
            } else {
                List {
                    ForEach(filteredOptions) { option in
                        Button(action: {
                            handleSelection(option)
                        }) {
                            HStack {
                                Text(displayText(option))
                                    .fontStyle(.body)
                                    .foregroundColor(Color.Text.primary)

                                Spacer()

                                selectionIndicator(for: option)
                            }
                            .contentShape(Rectangle())
                            .id(option)
                        }
                        .listRowBackground(Color.Background.primary)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isMultiSelect && !multiSelection.isEmpty {
                    Button("Clear") {
                        multiSelection.removeAll()
                    }
                    .foregroundColor(Color.Semantic.error)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    isPresented = false
                    dismiss()
                }
                .foregroundColor(Color.Button.primary)
            }
        }
    }

    private func handleSelection(_ option: T) {
        if isMultiSelect {
            if multiSelection.contains(option) {
                multiSelection.remove(option)
            } else {
                multiSelection.insert(option)
            }
        } else {
            selection = option
//            dismiss()
            toChange.toggle()
        }
    }

    @ViewBuilder
    private func selectionIndicator(for option: T) -> some View {
        if isMultiSelect {
            if multiSelection.contains(option) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.Icon.brand)
                    .font(.system(size: 20))
            } else {
                Image(systemName: "circle")
                    .foregroundColor(Color.Icon.brand)
                    .font(.system(size: 20))
            }
        } else {
            if selection?.id == option.id {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.Icon.brand)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
}

// MARK: - Shared Components

private struct SearchBar: View {
    @Binding var searchQuery: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.Text.tertiary)

            TextField("Search...", text: $searchQuery)
                .fontStyle(.body)
                .foregroundColor(Color.Text.primary)
                .foregroundColor(Color.Text.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.Text.tertiary)
                }
            }
        }
        .padding(.md)
        .background(Color.Background.secondary)
        .cornerRadius(.radiusMD)
        .padding()
    }
}

private struct EmptySearchState: View {
    var body: some View {
        VStack(spacing: .md) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Color.Text.tertiary)

            Text("No results found")
                .fontStyle(.headline)
                .foregroundColor(Color.Text.primary)

            Text("Try adjusting your search")
                .fontStyle(.body)
                .foregroundColor(Color.Text.secondary)

            Spacer()
        }
    }
}

// MARK: - String-based Convenience Initializers

public extension DSModalPicker where T == PickerOption {
    // Single select
    init(
        selection: Binding<String?>,
        isPresented: Binding<Bool>,
        options: [String],
        label: String? = nil,
        placeholder: String = "Select an option",
        icon: Image? = nil
    ) {
        let pickerOptions = options.map { PickerOption(id: $0, value: $0) }
        let selectedOption = selection.wrappedValue.map { value in
            pickerOptions.first { $0.value == value }
        } ?? nil

        self.init(
            selection: Binding(
                get: { selectedOption },
                set: { selection.wrappedValue = $0?.value }
            ),
            isPresented: isPresented,
            options: pickerOptions,
            label: label,
            placeholder: placeholder,
            icon: icon,
            displayText: { $0.value },
            searchFilter: { option, query in
                option.value.localizedCaseInsensitiveContains(query)
            }
        )
    }

    // Multi select
    init(
        multiSelection: Binding<Set<String>>,
        isPresented: Binding<Bool>,
        options: [String],
        label: String? = nil,
        placeholder: String = "Select options",
        icon: Image? = nil
    ) {
        let pickerOptions = options.map { PickerOption(id: $0, value: $0) }

        self.init(
            multiSelection: Binding(
                get: {
                    Set(pickerOptions.filter { multiSelection.wrappedValue.contains($0.value) })
                },
                set: { newSet in
                    multiSelection.wrappedValue = Set(newSet.map { $0.value })
                }
            ),
            isPresented: isPresented,
            options: pickerOptions,
            label: label,
            placeholder: placeholder,
            icon: icon,
            displayText: { $0.value },
            multiDisplayText: { set in
                set.isEmpty ? placeholder : "\(set.count) selected"
            },
            searchFilter: { option, query in
                option.value.localizedCaseInsensitiveContains(query)
            }
        )
    }
}

// MARK: - Helper Model

public struct PickerOption: Identifiable, Equatable, Hashable {
    public let id: String
    public let value: String

    public init(id: String, value: String) {
        self.id = id
        self.value = value
    }
}

// MARK: - Previews

#Preview("Single Select") {
    struct PreviewWrapper: View {
        @State private var selectedCity: String? = "New York"
        @State private var isPresented = false

        let cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"]

        var body: some View {
            VStack(spacing: .lg) {
                DSModalPicker(
                    selection: $selectedCity,
                    isPresented: $isPresented,
                    options: cities,
                    label: "City",
                    placeholder: "Select a city",
                    icon: Image(systemName: "building.2")
                )

                if let city = selectedCity {
                    Text("Selected: \(city)")
                        .fontStyle(.caption)
                }

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Multi Select") {
    struct PreviewWrapper: View {
        @State private var selectedCities: Set<String> = ["New York", "Chicago"]
        @State private var isPresented = false

        let cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
                      "San Francisco", "Boston", "Seattle", "Denver", "Austin"]

        var body: some View {
            VStack(spacing: .lg) {
                DSModalPicker(
                    multiSelection: $selectedCities,
                    isPresented: $isPresented,
                    options: cities,
                    label: "Cities",
                    placeholder: "Select cities",
                    icon: Image(systemName: "building.2")
                )

                if !selectedCities.isEmpty {
                    VStack(alignment: .leading, spacing: .xs) {
                        Text("Selected cities:")
                            .fontStyle(.caption)
                            .foregroundColor(Color.Text.secondary)

                        ForEach(Array(selectedCities).sorted(), id: \.self) { city in
                            Text("• \(city)")
                                .fontStyle(.bodySmall)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
