//
//  DSSegmentedControl.swift
//  RWLabsDesignSystem
//
//  Tab matching the Figma "Tab" (Tab 1 / Tab 2): an outlined track with 12pt corners and a dark
//  28pt pill behind the selected option, which slides when the selection changes.
//  Options share the width equally; give the control a width (Figma: 228) or let it fill.
//
//  DSSegmentedControl(selection: $filter, options: [("joined", "Joined"), ("created", "Created")])
//      .frame(width: 228)
//

import SwiftUI

// MARK: - DSSegmentedControl
public struct DSSegmentedControl<T: Hashable>: View {
    @Binding var selection: T
    let options: [(value: T, label: String, icon: Image?)]
    let isDisabled: Bool

    @Environment(\.isEnabled) private var isEnabled
    @Namespace private var pill

    /// - Parameter isDisabled: Same as `.disabled(true)`.
    public init(
        selection: Binding<T>,
        options: [(value: T, label: String, icon: Image?)] = [],
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.options = options
        self.isDisabled = isDisabled
    }

    public init(
        selection: Binding<T>,
        options: [(value: T, label: String)],
        isDisabled: Bool = false
    ) {
        self.init(selection: selection, options: options.map { ($0.value, $0.label, nil) }, isDisabled: isDisabled)
    }

    private var enabled: Bool { isEnabled && !isDisabled }

    public var body: some View {
        HStack(spacing: .xs) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                segment(option)
            }
        }
        .padding(.horizontal, .xs)
        .padding(.vertical, .xxs)
        .overlay(
            RoundedRectangle(cornerRadius: .radiusMD)
                .strokeBorder(Color.Tab.border, lineWidth: .thin)
        )
        .opacity(enabled ? 1 : 0.5)
        .disabled(!enabled)
    }

    private func segment(_ option: (value: T, label: String, icon: Image?)) -> some View {
        let isSelected = selection == option.value

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { selection = option.value }
        } label: {
            HStack(spacing: .xxs) {
                option.icon?.font(.system(size: 14))
                Text(option.label)
                    .fontStyle(.bodySmall)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .Tab.selectedText : .Tab.text)
            .padding(.horizontal, .xs)
            .frame(maxWidth: .infinity, minHeight: 28)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: .radiusSM)
                        .fill(Color.Tab.selectedFill)
                        .matchedGeometryEffect(id: "pill", in: pill)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview
/// Mirrors the Figma Tab sheet (Tab 1, Tab 2), then three options with icons and a disabled tab.
private struct DSSegmentedControlGallery: View {
    @State private var tab = "joined"
    @State private var view = 1

    var body: some View {
        VStack(spacing: .lg) {
            DSSegmentedControl(selection: .constant("joined"), options: [("joined", "Joined"), ("created", "Created")])
                .frame(width: 228)
            DSSegmentedControl(selection: .constant("created"), options: [("joined", "Joined"), ("created", "Created")])
                .frame(width: 228)
            DSSegmentedControl(selection: $tab, options: [("joined", "Joined"), ("created", "Created")])
            DSSegmentedControl(selection: $view, options: [
                (value: 1, label: "Map", icon: Image(systemName: "map")),
                (value: 2, label: "List", icon: Image(systemName: "list.bullet")),
                (value: 3, label: "Grid", icon: Image(systemName: "square.grid.2x2")),
            ])
            DSSegmentedControl(selection: .constant("a"), options: [("a", "Option 1"), ("b", "Option 2")])
                .disabled(true)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSegmentedControlGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSegmentedControlGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSSegmentedControlGallery().designSystem()
}
