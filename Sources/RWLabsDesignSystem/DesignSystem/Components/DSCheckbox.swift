//
//  DSCheckbox.swift
//  RWLDesignSystem
//
//  Checkbox component for multiple selections
//

import SwiftUI

public struct DSCheckbox: View {
    @Binding var isChecked: Bool
    let isEnabled: Bool

    public init(isChecked: Binding<Bool>, isEnabled: Bool = true) {
        self._isChecked = isChecked
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Button(action: {
            if isEnabled {
                isChecked.toggle()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(
                        isChecked ? Color.Border.active : Color.Border.default,
                        lineWidth: isChecked ? 0 : 2
                    )
                    .background(
                        isChecked
                            ? RoundedRectangle(cornerRadius: 2).fill(Color.Background.brand)
                            : RoundedRectangle(cornerRadius: 2).fill(Color.Background.primary)
                    )

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 18, height: 18)
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
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
