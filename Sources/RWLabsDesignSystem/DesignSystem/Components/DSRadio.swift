//
//  DSRadio.swift
//  RWLDesignSystem
//
//  Radio button component for single selection
//

import SwiftUI

public struct DSRadio: View {
    @Binding var isSelected: Bool
    let isEnabled: Bool

    public init(isSelected: Binding<Bool>, isEnabled: Bool = true) {
        self._isSelected = isSelected
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Button(action: {
            if isEnabled {
                isSelected = true
            }
        }) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color.Border.subtle,
                        lineWidth: 2
                    )
                    .background(
                        Circle().fill(Color.Background.primary)
                    )

                if isSelected {
                    Circle()
                        .fill(Color.Background.brand)
                        .padding(4)
                }
            }
            .frame(width: 20, height: 20)
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        DSRadio(isSelected: .constant(false))
        DSRadio(isSelected: .constant(true))
        DSRadio(isSelected: .constant(false), isEnabled: false)
        DSRadio(isSelected: .constant(true), isEnabled: false)
    }
    .padding()
}
