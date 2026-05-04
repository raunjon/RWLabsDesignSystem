//
//  DSChip.swift
//  RWLDesignSystem
//
//  Chip/tag component for selection and filtering
//

import SwiftUI

// MARK: - DSChip

public struct DSChip: View {

    // MARK: - Variant

    public enum Variant {
        case filled
        case outlined
    }

    // MARK: - Properties

    let title: String
    let icon: Image?
    @Binding var isSelected: Bool
    let isDismissible: Bool
    let variant: Variant
    let onDismiss: (() -> Void)?

    // MARK: - Initialization

    public init(
        title: String,
        icon: Image? = nil,
        isSelected: Binding<Bool> = .constant(false),
        isDismissible: Bool = false,
        variant: Variant = .filled,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self._isSelected = isSelected
        self.isDismissible = isDismissible
        self.variant = variant
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: .xs) {
            if let icon = icon {
                icon
                    .font(.system(size: 12))
                    .foregroundColor(textColor)
            }

            Text(title)
                .fontStyle(.bodySmall)
                .foregroundColor(textColor)

            if isDismissible {
                Button(action: {
                    onDismiss?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(textColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, .sm)
        .padding(.vertical, .xs)
        .background(backgroundColor)
        .cornerRadius(.radiusFull)
        .border(borderColor, lineWidth: variant == .outlined ? .thin : 0, cornerRadius: .radiusFull)
        .onTapGesture {
            isSelected.toggle()
        }
    }

    // MARK: - Styling

    private var backgroundColor: Color {
        switch variant {
        case .filled:
            return isSelected ? Color.Background.brand : Color.Background.secondary
        case .outlined:
            return isSelected ? Color.Text.brand.opacity(0.1) : Color.clear
        }
    }

    private var borderColor: Color {
        switch variant {
        case .filled:
            return isSelected ? .clear : Color.Border.active
        case .outlined:
            return isSelected ? Color.Border.active : Color.Border.default
        }
    }

    private var textColor: Color {
        if variant == .filled && isSelected {
            return .white
        }
        return isSelected ? Color.Text.brand : Color.Text.primary
    }
}

// MARK: - Preview

#Preview("Chip") {
    VStack(spacing: .lg) {
        HStack {
            DSChip(title: "React", isSelected: .constant(true))
            DSChip(title: "Vue", isSelected: .constant(false))
            DSChip(title: "Angular")
        }

        HStack {
            DSChip(title: "With Icon", icon: Image(systemName: "star.fill"), isSelected: .constant(true))
            DSChip(title: "Dismissible", isDismissible: true, onDismiss: { print("Dismissed") })
        }

        HStack {
            DSChip(title: "Outlined", isSelected: .constant(true), variant: .outlined)
            DSChip(title: "Outlined", isSelected: .constant(false), variant: .outlined)
        }
    }
    .padding()
}
