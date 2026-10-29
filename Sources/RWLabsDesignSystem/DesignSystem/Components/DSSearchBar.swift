//
//  DSSearchBar.swift
//  RWLabsDesignSystem
//
//  Search bar matching the Figma "Search bar": optional back button, neutral field,
//  search icon and 14px text. DSSearchBarWithFilters adds a row of compact pills.
//

import SwiftUI

// MARK: - DSSearchBar
/// Figma "Search bar": optional back button, then a 45pt field with a search icon.
public struct DSSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    let placeholder: String
    let showsCancelButton: Bool
    let onBack: (() -> Void)?
    let onSubmit: (() -> Void)?
    let onCancel: (() -> Void)?

    /// - Parameters:
    ///   - onBack: Shows Figma's back button before the field when set.
    ///   - showsCancelButton: iOS-style Cancel while searching. Off by default; Figma has none.
    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        showsCancelButton: Bool = false,
        onBack: (() -> Void)? = nil,
        onSubmit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showsCancelButton = showsCancelButton
        self.onBack = onBack
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: .xs) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.Search.backIcon)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.Search.backFill))
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }

            HStack(spacing: .xs) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.Search.icon)
                    .frame(width: 16, height: 16)

                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.Search.placeholder))
                    .fontStyle(.bodySmall)
                    .foregroundColor(.Search.text)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit {
                        isFocused = false
                        onSubmit?()
                    }

                if !text.isEmpty {
                    Button { text = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.Search.icon)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear")
                }
            }
            .padding(.horizontal, .md)
            .frame(height: 45)
            .background(RoundedRectangle(cornerRadius: .radiusMD).fill(Color.Search.field))

            if showsCancelButton && (isFocused || !text.isEmpty) {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    onCancel?()
                }
                .fontStyle(.bodySmall)
                .foregroundColor(.Button.linkText)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

// MARK: - Search Bar with Filters
/// Search bar with a row of compact pills; tapping the selected pill clears the filter.
public struct DSSearchBarWithFilters: View {
    @Binding var text: String
    @Binding var selectedFilter: String?

    let placeholder: String
    let filters: [String]
    let onBack: (() -> Void)?
    let onSubmit: (() -> Void)?

    public init(
        text: Binding<String>,
        selectedFilter: Binding<String?>,
        placeholder: String = "Search",
        filters: [String],
        onBack: (() -> Void)? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._selectedFilter = selectedFilter
        self.placeholder = placeholder
        self.filters = filters
        self.onBack = onBack
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(spacing: .sm) {
            DSSearchBar(text: $text, placeholder: placeholder, onBack: onBack, onSubmit: onSubmit)

            if !filters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .xs) {
                        ForEach(filters, id: \.self) { filter in
                            Toggle(filter, isOn: Binding(
                                get: { selectedFilter == filter },
                                set: { selectedFilter = $0 ? filter : nil }
                            ))
                            .pillStyle(size: .compact)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
private struct DSSearchBarGallery: View {
    @State private var empty = ""
    @State private var filled = "Priya"
    @State private var filter: String? = "Members"

    var body: some View {
        VStack(spacing: .lg) {
            DSSearchBar(text: $empty, placeholder: "Search members", onBack: {})
            DSSearchBar(text: $filled, placeholder: "Search members")
            DSSearchBarWithFilters(text: $empty, selectedFilter: $filter, placeholder: "Search communities",
                                   filters: ["All", "Members", "Events", "Chats"])
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSearchBarGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSearchBarGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSSearchBarGallery().designSystem()
}
