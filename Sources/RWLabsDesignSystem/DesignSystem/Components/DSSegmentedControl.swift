//
//  DSSegmentedControl.swift
//  RWLDesignSystem
//
//  Segmented control for inline selection
//

import SwiftUI

// MARK: - DSSegmentedControl

public struct DSSegmentedControl<T: Hashable>: View {

    // MARK: - Properties

    @Binding var selection: T
    let options: [(value: T, label: String, icon: Image?)]
    let isDisabled: Bool

    // MARK: - Initialization

    public init(
        selection: Binding<T>,
        options: [(value: T, label: String, icon: Image?)] = [],
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.options = options
        self.isDisabled = isDisabled
    }

    // Convenience init without icons
    public init(
        selection: Binding<T>,
        options: [(value: T, label: String)],
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.options = options.map { ($0.value, $0.label, nil) }
        self.isDisabled = isDisabled
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                segmentButton(for: option, isFirst: index == 0, isLast: index == options.count - 1)
            }
        }
        .background(Color.Background.secondary)
        .cornerRadius(.radiusMD)
        .border(Color.Border.default, lineWidth: .thin, cornerRadius: .radiusMD)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Segment Button

    @ViewBuilder
    private func segmentButton(for option: (value: T, label: String, icon: Image?), isFirst: Bool, isLast: Bool) -> some View {
        let isSelected = selection == option.value

        Button(action: {
            if !isDisabled {
                selection = option.value
            }
        }) {
            HStack(spacing: .xs) {
                if let icon = option.icon {
                    icon
                        .font(.system(size: 14))
                }

                DSText(option.label, style: .bodyMedium, color: isSelected ? Color.Text.primary : Color.Text.secondary)
            }
            .padding(.horizontal, .md)
            .padding(.vertical, .sm)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.Background.primary : Color.clear)
            .cornerRadius(.sm)
            .padding(2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

// MARK: - Preview

#Preview("Segmented Control") {
    VStack(spacing: .xl) {
        DSSegmentedControl(
            selection: .constant("map"),
            options: [
                ("map", "Map"),
                ("list", "List"),
                ("grid", "Grid")
            ]
        )

        DSSegmentedControl(
            selection: .constant(1),
            options: [
                (value: 1, label: "Map", icon: Image(systemName: "map")),
                (value: 2, label: "List", icon: Image(systemName: "list.bullet")),
                (value: 3, label: "Grid", icon: Image(systemName: "square.grid.2x2"))
            ]
        )

        DSSegmentedControl(
            selection: .constant("option1"),
            options: [
                ("option1", "Option 1"),
                ("option2", "Option 2")
            ],
            isDisabled: true
        )
    }
    .padding()
}
