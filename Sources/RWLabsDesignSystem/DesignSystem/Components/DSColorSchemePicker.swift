//
//  DSColorSchemePicker.swift
//  RWLabsDesignSystem
//
//  A component for selecting the app's color scheme (light, dark, or system)
//

import SwiftUI

// MARK: - Color Scheme Picker
public struct DSColorSchemePicker: View {
    @ObservedObject private var schemeManager = DSColorSchemeManager.shared

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: .md) {
            DSText("Appearance", style: .headline, color: .Text.primary)

            HStack(spacing: .md) {
                ForEach(DSColorSchemePreference.allCases) { scheme in
                    ColorSchemeButton(
                        scheme: scheme,
                        isSelected: schemeManager.selectedScheme == scheme
                    ) {
                        schemeManager.setScheme(scheme)
                    }
                }
            }
        }
    }
}

// MARK: - Color Scheme Button
private struct ColorSchemeButton: View {
    let scheme: DSColorSchemePreference
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: .sm) {
                Image(systemName: scheme.icon)
                    .fontStyle(.title1)
                    .foregroundColor(isSelected ? Color.Text.brand: Color.Text.secondary)

                DSText(scheme.displayName, style: .caption, color: isSelected ? .Text.brand : .Text.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.md)
            .background(
                RoundedRectangle(cornerRadius: .md)
                    .fill(isSelected ? Color.Background.brand.opacity(0.1) : Color.clear)
                    .border(isSelected ? Color.Border.active : Color.Border.default, lineWidth: isSelected ? 2 : 1, cornerRadius: .md)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Version (Segmented Control Style)
public struct DSColorSchemePickerCompact: View {
    @ObservedObject private var schemeManager = DSColorSchemeManager.shared

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(DSColorSchemePreference.allCases) { scheme in
                Button(action: {
                    schemeManager.setScheme(scheme)
                }) {
                    HStack(spacing: .xs) {
                        Image(systemName: scheme.icon)
                            .fontStyle(.body)

                        DSText(scheme.displayName, style: .bodySmall, color: schemeManager.selectedScheme == scheme ? .white : .Text.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .sm)
                    .background(
                        schemeManager.selectedScheme == scheme
                            ? Color.Background.brand
                            : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.Background.secondary)
        .cornerRadius(.sm)
        .border(.Border.default, lineWidth: 1)
    }
}

// MARK: - Menu Style (for toolbar/navigation bar)
public struct DSColorSchemeMenu: View {
    @ObservedObject private var schemeManager = DSColorSchemeManager.shared

    public init() {}

    public var body: some View {
        Menu {
            ForEach(DSColorSchemePreference.allCases) { scheme in
                Button(action: {
                    schemeManager.setScheme(scheme)
                }) {
                    Label(
                        scheme.displayName,
                        systemImage: scheme.icon
                    )

                    if schemeManager.selectedScheme == scheme {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Image(systemName: schemeManager.selectedScheme.icon)
                .foregroundColor(Color.Icon.brand)
        }
    }
}

// MARK: - Previews
#Preview("Standard Picker") {
    VStack(spacing: 32) {
        DSColorSchemePicker()
    }
    .padding()
}

#Preview("Compact Picker") {
    VStack(spacing: 32) {
        DSColorSchemePickerCompact()
    }
    .padding()
}

#Preview("Menu Style") {
    NavigationView {
        VStack {
            DSText("Content", style: .body, color: .Text.primary)
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                DSColorSchemeMenu()
            }
        }
    }
}
