//
//  DSButton.swift
//  RWLDesignSystem
//
//  Design system button component
//

import SwiftUI

// MARK: - Button Style Variants
public enum DSButtonVariant {
    case primary      // Enabled state
    case secondary    // Pressed state
    case outline      // Outline/Tertiary state
    case disabled     // Disabled state
    case ghost
    case destructive
    case link
    case brandLink

    @MainActor
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .Button.primary
        case .secondary:
            return .Button.secondary
        case .disabled:
            return.Button.disabled
        case .outline:
            return .Button.outline
        case .ghost, .link, .brandLink:
            return .clear
        case .destructive:
            return .Button.destructive
        }
    }

    @MainActor
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .Button.primaryText
        case .secondary:
            return .Button.secondaryText
        case .disabled:
            return .Button.disabledText
        case .outline:
            return .Button.outlineText
        case .destructive:
            return .Button.destructiveText
        case .ghost:
            return .Button.primaryText
        case .link:
            return .Button.linkText
        case .brandLink:
            return .Button.brandLinkText
        }
    }

    @MainActor
    var borderColor: Color? {
        switch self {
        case .outline:
            return .Button.outlineBorder
        default:
            return nil
        }
    }
    
    var isLink:Bool {
        self == .link || self == .brandLink
    }
}

// MARK: - Button Size
public enum DSButtonSize {
    case small
    case medium
    case large

    var padding: EdgeInsets {
        .button
    }

    var fontStyle: DSTypography.Style {
        .body
    }

    var height: CGFloat {
        return 30
    }

    var cornerRadius: CGFloat {
        .xl
    }
}

// MARK: - DSButton Component
public struct DSButton: View {
    let title: String
    let variant: DSButtonVariant
    let size: DSButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let icon: Image?
    let action: () -> Void

    public init(
        title: String,
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: .xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: variant.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }

                    Text(title)
                        .fontStyle(size.fontStyle)
                        .underline(variant.isLink)
                }
            }
            .foregroundColor(variant.foregroundColor)
            .if(!variant.isLink) { view in
                view
                    .frame(maxWidth: .infinity, minHeight: size.height)
                    .padding(size.padding)
                    .background(variant.backgroundColor)
                    .cornerRadius(size.cornerRadius)
                    .border(variant.borderColor ?? .clear, lineWidth: DSBorderWidth.thin, cornerRadius: size.cornerRadius)
            }
        }
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled || isLoading) ? 0.6 : 1.0)
    }
}

// MARK: - Icon Button
public struct DSIconButton: View {
    let icon: Image
    let variant: DSButtonVariant
    let size: CGFloat
    let action: () -> Void

    public init(
        icon: Image,
        variant: DSButtonVariant = .ghost,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.variant = variant
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.5, height: size * 0.5)
                .foregroundColor(variant.foregroundColor)
                .frame(width: size, height: size)
                .background(variant.backgroundColor)
                .cornerRadius(.md)
                .border(variant.borderColor ?? .clear, lineWidth: DSBorderWidth.thin, cornerRadius: .md)
        }
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
struct DSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .md) {
            DSButton(
                title: "config.title",
                variant: .secondary,
                size: .small,
                isLoading: false
            ) {}
            HStack  {
                DSButton(title: "Primary Button", variant: .primary) {}
                DSButton(title: "Secondary Button", variant: .secondary) {}
            }
            DSButton(title: "Secondary Button", variant: .secondary) {}
            DSButton(title: "Outline Button", variant: .outline) {}
            DSButton(title: "Ghost Button", variant: .ghost) {}
            DSButton(title: "Destructive", variant: .destructive) {}
            DSButton(title: "Link Button", variant: .link) {}
            DSButton(title: "Brand Link Button", variant: .brandLink) {}
            DSButton(title: "Loading", variant: .primary, isLoading: true) {}
            DSButton(title: "Disabled", variant: .primary, isDisabled: true) {}
            DSButton(title: "Small", variant: .primary, size: .small) {}
            DSButton(title: "Large", variant: .primary, size: .large) {}

            DSIconButton(icon: Image(systemName: "heart.fill")) {}
        }
        .padding()
    }
}
