//
//  DSCheckbox.swift
//  RWLDesignSystem
//
//  Checkbox component for multiple selections
//

import SwiftUI

/// Tappable checkbox. Draws `DSSelectionIndicator`, so it matches option rows and selection cards.
public struct DSCheckbox: View {
    @Binding var isChecked: Bool
    let isEnabled: Bool
    let size: CGFloat

    public init(isChecked: Binding<Bool>, isEnabled: Bool = true, size: CGFloat = .s18) {
        self._isChecked = isChecked
        self.isEnabled = isEnabled
        self.size = size
    }

    public var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            DSSelectionIndicator(isSelected: isChecked, size: size)
                .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 16) {
        DSCheckbox(isChecked: .constant(false))
        DSCheckbox(isChecked: .constant(true))
        DSCheckbox(isChecked: .constant(false), isEnabled: false)
        DSCheckbox(isChecked: .constant(true), isEnabled: false)
    }
    .padding()
}
