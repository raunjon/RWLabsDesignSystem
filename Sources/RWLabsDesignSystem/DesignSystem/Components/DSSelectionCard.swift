//
//  DSSelectionCard.swift
//  RWLDesignSystem
//
//  Selection card component supporting single and multiple selection modes
//

import SwiftUI

public enum DSSelectionMode {
    case singleSelect
    case multiSelect
}

public protocol DSSelectionCardInfo {
    var icon: Image? { get }
    var title: String { get }
}

extension DSSelectionCardInfo   {
    static var mock: MockSelectionCardInfo {
        MockSelectionCardInfo()
    }
}

public struct DSSelectionCard<T:DSSelectionCardInfo>: View {
    @Binding var isSelected: Bool
    let info: T
    let mode: DSSelectionMode
    let isEnabled: Bool
    let height: CGFloat
    let hideShadow: Bool
    let onTap:(Bool) -> Void

    public init(
        info: T,
        isSelected: Binding<Bool>,
        mode: DSSelectionMode = .singleSelect,
        isEnabled: Bool = true,
        height: CGFloat = 72,
        hideShadow: Bool = false,
        onTap: @escaping (Bool) -> Void = {_ in}
    ) {
        self._isSelected = isSelected
        self.info = info
        self.mode = mode
        self.isEnabled = isEnabled
        self.height = height
        self.hideShadow = hideShadow
        self.onTap = onTap
    }

    public var body: some View {
        DSCard(elevation: hideShadow ? .flat : .medium, backgroundColor: isSelected ? Color.Background.secondary : Color.Background.primary, cornerRadius: .radiusXL) {
            Button(action: {
                if isEnabled {
                    isSelected.toggle()
                }
                self.onTap(self.isSelected)
            }) {
                HStack(spacing: .s20) {
                    // Icon and Label
                    if let icon = info.icon {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                            .padding(.xs)
                            .cornerRadius(.radiusLG)
                            .foregroundStyle(isSelected ? Color.Background.primary : Color.Background.secondary)
                    }
                    
                    DSText(info.title, style: .body, color: Color.Text.primary)
                        .lineLimit(1)
     
                
                Spacer()
                
                // Selection Control
                switch mode {
                case .singleSelect:
                    DSRadio(isSelected: $isSelected, isEnabled: isEnabled)
                case .multiSelect:
                    DSCheckbox(isChecked: $isSelected, isEnabled: isEnabled)
                }
            }
                .padding(.xxs)
        }
                .frame(height: height)
                .cornerRadius(.radiusLG)
                .opacity(isEnabled ? 1 : 0.5)
            .disabled(!isEnabled)

        }
    }
}

struct MockSelectionCardInfo: DSSelectionCardInfo {
    let icon: Image? = Image(systemName: "person.fill")
    let title: String = "Male"
}

#Preview {
    VStack(spacing: .md) {
        // Single Select - Unselected
        DSSelectionCard(
            info: MockSelectionCardInfo(),
            isSelected: .constant(false),
        )

        // Single Select - Selected
        DSSelectionCard(
            info: MockSelectionCardInfo(),
            isSelected: .constant(true),
        )

        // Multi Select - Unselected
        DSSelectionCard(
            info: MockSelectionCardInfo(),
            isSelected: .constant(false),
            mode: .multiSelect
        )

        // Multi Select - Selected
        DSSelectionCard(
            info: MockSelectionCardInfo(),
            isSelected: .constant(true),
            mode: .multiSelect
        )
    }
    .padding()
}
