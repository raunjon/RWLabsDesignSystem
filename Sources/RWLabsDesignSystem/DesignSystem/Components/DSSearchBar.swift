//
//  DSSearchBar.swift
//  RWLDesignSystem
//
//  Standalone search bar component
//

import SwiftUI

// MARK: - DSSearchBar

public struct DSSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    let placeholder: String
    let showsCancelButton: Bool
    let onSubmit: (() -> Void)?
    let onCancel: (() -> Void)?

    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        showsCancelButton: Bool = true,
        onSubmit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showsCancelButton = showsCancelButton
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: .sm) {
            // Search field
            HStack(spacing: .xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.Text.tertiary)
                    .font(.system(size: 16))

                TextField(placeholder, text: $text)
                    .fontStyle(.body)
                    .foregroundColor(Color.Text.primary)
                    .focused($isFocused)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        // Dismiss keyboard after submit to prevent session issues
                        isFocused = false
                        onSubmit?()
                    }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.Text.tertiary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, .sm)
            .padding(.vertical, .xs)
            .background(Color.Background.secondary)
            .cornerRadius(.md)

            // Cancel button
            if showsCancelButton && (isFocused || !text.isEmpty) {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    onCancel?()
                }
                .fontStyle(.body)
                .foregroundColor(Color.Button.primary)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

// MARK: - Search Bar with Filters

public struct DSSearchBarWithFilters: View {
    @Binding var text: String
    @Binding var selectedFilter: String?
    @FocusState private var isFocused: Bool

    let placeholder: String
    let filters: [String]
    let onSubmit: (() -> Void)?

    public init(
        text: Binding<String>,
        selectedFilter: Binding<String?>,
        placeholder: String = "Search...",
        filters: [String],
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._selectedFilter = selectedFilter
        self.placeholder = placeholder
        self.filters = filters
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(spacing: .sm) {
            DSSearchBar(
                text: $text,
                placeholder: placeholder,
                showsCancelButton: true,
                onSubmit: onSubmit
            )

            // Filters
            if !filters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .sm) {
                        ForEach(filters, id: \.self) { filter in
                            Button(action: {
                                if selectedFilter == filter {
                                    selectedFilter = nil
                                } else {
                                    selectedFilter = filter
                                }
                            }) {
                                DSText(filter, style: .bodySmallMedium, color: selectedFilter == filter ? .Background.primary : .Text.primary)
                                    .padding(.horizontal, .sm)
                                    .padding(.vertical, .xs)
                                    .background(
                                        selectedFilter == filter
                                            ? Color.Background.brand
                                            : Color.Background.secondary
                                    )
                                    .cornerRadius(.radiusFull)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic Search Bar") {
    struct PreviewWrapper: View {
        @State private var searchText = ""

        var body: some View {
            VStack(spacing: .xl) {
                DSSearchBar(
                    text: $searchText,
                    onSubmit: {
                        print("Search: \(searchText)")
                    }
                )

                if !searchText.isEmpty {
                    DSText("Searching for: \"\(searchText)\"", style: .label, color: .Text.secondary)
                }

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Search with Filters") {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        @State private var selectedFilter: String? = nil

        let filters = ["All", "Products", "Users", "Orders", "Settings"]

        var body: some View {
            VStack(spacing: .xl) {
                DSSearchBarWithFilters(
                    text: $searchText,
                    selectedFilter: $selectedFilter,
                    filters: filters,
                    onSubmit: {
                        print("Search: \(searchText), Filter: \(selectedFilter ?? "All")")
                    }
                )

                VStack(alignment: .leading, spacing: .xs) {
                    if !searchText.isEmpty {
                        DSText("Query: \"\(searchText)\"", style: .bodySmallMedium, color: .Text.secondary)
                    }

                    if let filter = selectedFilter {
                        DSText("Filter: \(filter)", style: .bodySmallMedium, color: .Text.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Search Results") {
    struct PreviewWrapper: View {
        @State private var searchText = ""

        let mockResults = [
            "iPhone 15 Pro",
            "iPhone 15 Pro Max",
            "iPhone 15",
            "MacBook Pro 16\"",
            "MacBook Air M2"
        ]

        var filteredResults: [String] {
            if searchText.isEmpty {
                return mockResults
            }
            return mockResults.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }

        var body: some View {
            VStack(spacing: 0) {
                DSSearchBar(text: $searchText)
                    .padding()

                Divider()

                if filteredResults.isEmpty {
                    VStack(spacing: .md) {
                        Spacer()

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(Color.Text.tertiary)

                        DSText("No results found", style: .heading3, color: .Text.primary)

                        Spacer()
                    }
                } else {
                    List(filteredResults, id: \.self) { result in
                        DSText(result, style: .body, color: .Text.primary)
                    }
                    .listStyle(.plain)
                }
            }
        }
    }

    return PreviewWrapper()
}
