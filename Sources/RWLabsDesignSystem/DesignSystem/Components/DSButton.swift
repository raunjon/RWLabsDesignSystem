//
//  DSButton.swift
//  RWLDesignSystem
//
//  Design system button component, matching the Figma "CTA Button" component.
//
//  Figma states map onto variants plus interaction state:
//    Primary   → .primary
//    Pressed   → .primary while pressed
//    Secondary → .secondary
//    Tertiary  → .tertiary
//    Disabled  → any filled variant while disabled
//

import SwiftUI

// MARK: - Button Style Variants
public enum DSButtonVariant: CaseIterable, Sendable {
    /// Brand fill, white label
    case primary
    /// Neutral fill, muted label
    case secondary
    /// Surface fill with a 1pt border
    case tertiary
    /// Error fill, white label
    case destructive
    /// Dark neutral fill, light label (Figma popup cards)
    case inverse
    /// No fill, primary text color
    case ghost
    /// Underlined text, no fill
    case link
    /// Underlined text in the brand color, no fill
    case brandLink

    var isLink: Bool {
        self == .link || self == .brandLink
    }

    /// Variants that switch to the disabled fill when disabled; the rest fade instead.
    var usesDisabledFill: Bool {
        self == .primary || self == .destructive || self == .inverse
    }

    @MainActor
    func backgroundColor(isPressed: Bool) -> Color {
        switch self {
        case .primary:     isPressed ? .Button.primaryPressed     : .Button.primary
        case .secondary:   isPressed ? .Button.secondaryPressed   : .Button.secondary
        case .tertiary:    isPressed ? .Button.tertiaryPressed    : .Button.tertiary
        case .destructive: isPressed ? .Button.destructivePressed : .Button.destructive
        case .inverse:     isPressed ? .Button.inversePressed     : .Button.inverse
        case .ghost:       isPressed ? .Button.secondary          : .clear
        case .link, .brandLink: .clear
        }
    }

    @MainActor
    var foregroundColor: Color {
        switch self {
        case .primary:      .Button.primaryText
        case .secondary:    .Button.secondaryText
        case .tertiary:     .Button.tertiaryText
        case .destructive:  .Button.destructiveText
        case .inverse:      .Button.inverseText
        case .ghost, .link: .Button.linkText
        case .brandLink:    .Button.brandLinkText
        }
    }

    @MainActor
    var borderColor: Color? {
        self == .tertiary ? .Button.tertiaryBorder : nil
    }
}

// MARK: - Button Size
public enum DSButtonSize: CaseIterable, Sendable {
    /// 56pt, full width. The default call-to-action.
    case large
    /// 46pt
    case medium
    /// 38pt
    case small
    /// 36pt
    case tiny

    var height: CGFloat {
        switch self {
        case .large:  56
        case .medium: 46
        case .small:  38
        case .tiny:   36
        }
    }

    /// Large stretches to fill the width; the others hug their content above a minimum width.
    var minWidth: CGFloat? {
        switch self {
        case .large:  nil
        case .medium: 154
        case .small:  138
        case .tiny:   106
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .large, .medium: .lg
        case .small:          .s20
        case .tiny:           .sm
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large:          .radiusLG
        case .medium, .small: .radiusMD
        case .tiny:           .radiusSM
        }
    }

    var fontStyle: DSTypography.Style {
        switch self {
        case .large:          .body
        case .medium, .small: .bodySmall
        case .tiny:           .label
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .large:  17
        case .medium: 16
        case .small:  14
        case .tiny:   12
        }
    }

    var spacing: CGFloat {
        self == .tiny ? .xxs : .xs
    }
}

// MARK: - Icon Placement
public enum DSButtonIconPlacement: Sendable {
    case leading
    case trailing
}

// MARK: - Button Style
/// Renders a variant and size, including pressed and disabled states, around any label.
/// The size's text style is a default; a `.font` set inside the label wins.
public struct DSButtonStyle: ButtonStyle {
    let variant: DSButtonVariant
    let size: DSButtonSize

    @Environment(\.isEnabled) private var isEnabled

    public init(variant: DSButtonVariant = .primary, size: DSButtonSize = .large) {
        self.variant = variant
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        let showsDisabledFill = !isEnabled && variant.usesDisabledFill

        if variant.isLink {
            configuration.label
                .fontStyle(size.fontStyle)
                .underline()
                .foregroundColor(variant.foregroundColor)
                .opacity(isEnabled ? (configuration.isPressed ? 0.6 : 1) : 0.4)
        } else {
            configuration.label
                .fontStyle(size.fontStyle)
                .foregroundColor(showsDisabledFill ? .Button.disabledText : variant.foregroundColor)
                .padding(.horizontal, size.horizontalPadding)
                .frame(minWidth: size.minWidth, maxWidth: size.minWidth == nil ? .infinity : nil)
                .frame(minHeight: size.height)
                .background(
                    showsDisabledFill ? .Button.disabled : variant.backgroundColor(isPressed: configuration.isPressed)
                )
                .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
                .border(variant.borderColor ?? .clear, lineWidth: .thin, cornerRadius: size.cornerRadius)
                .opacity(isEnabled || showsDisabledFill ? 1 : 0.5)
                .contentShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        }
    }
}

// MARK: - Button Style Helpers
/// Style any `Button` while keeping full control of its label:
///
/// ```swift
/// Button {
///     submit()
/// } label: {
///     HStack {
///         Text("Continue")
///         Image(systemName: "arrow.right")
///     }
/// }
/// .primaryButtonStyle()
///
/// Button("Skip") { skip() }
///     .tertiaryButtonStyle(size: .small)
/// ```
public extension View {
    func dsButtonStyle(_ variant: DSButtonVariant, size: DSButtonSize = .large) -> some View {
        buttonStyle(DSButtonStyle(variant: variant, size: size))
    }

    /// Brand fill. Figma "Primary", pressed shows "Pressed".
    func primaryButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.primary, size: size)
    }

    /// Neutral fill. Figma "Secondary".
    func secondaryButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.secondary, size: size)
    }

    /// Surface fill with a border. Figma "Tertiary".
    func tertiaryButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.tertiary, size: size)
    }

    /// Error fill.
    func destructiveButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.destructive, size: size)
    }

    /// Dark neutral fill, as on the Figma popup cards.
    func inverseButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.inverse, size: size)
    }

    /// No fill until pressed.
    func ghostButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.ghost, size: size)
    }

    /// Underlined text.
    func linkButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.link, size: size)
    }

    /// Underlined text in the brand color.
    func brandLinkButtonStyle(size: DSButtonSize = .large) -> some View {
        dsButtonStyle(.brandLink, size: size)
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
    let iconPlacement: DSButtonIconPlacement
    let action: () -> Void

    public init(
        title: String,
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: Image? = nil,
        iconPlacement: DSButtonIconPlacement = .trailing,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.icon = icon
        self.iconPlacement = iconPlacement
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: size.spacing) {
                if isLoading {
                    ProgressView()
                        .tint(variant.foregroundColor)
                        .controlSize(size == .large ? .regular : .small)
                } else {
                    if iconPlacement == .leading { iconView }
                    Text(title)
                        .lineLimit(1)
                    if iconPlacement == .trailing { iconView }
                }
            }
        }
        .buttonStyle(DSButtonStyle(variant: variant, size: size))
        .disabled(isDisabled || isLoading)
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: size.iconSize, height: size.iconSize)
        }
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
                .background(variant.backgroundColor(isPressed: false))
                .cornerRadius(.radiusMD)
                .border(variant.borderColor ?? .clear, lineWidth: DSBorderWidth.thin, cornerRadius: .radiusMD)
        }
    }
}

// MARK: - Preview
/// Mirrors the Figma CTA Button sheet: one group per size, one row per state.
private struct DSButtonGallery: View {
    private let arrow = Image(systemName: "arrow.right")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                ForEach(DSButtonSize.allCases, id: \.self) { size in
                    VStack(alignment: .leading, spacing: .sm) {
                        DSButton(title: "Button", size: size, isDisabled: true, icon: arrow) {}
                        DSButton(title: "Button", variant: .tertiary, size: size, icon: arrow) {}
                        DSButton(title: "Button", variant: .primary, size: size, icon: arrow) {}
                        DSButton(title: "Button", variant: .secondary, size: size, icon: arrow) {}
                    }
                }

                VStack(alignment: .leading, spacing: .sm) {
                    DSButton(title: "Destructive", variant: .destructive) {}
                    DSButton(title: "Loading", isLoading: true) {}
                    DSButton(title: "Ghost", variant: .ghost, size: .medium) {}
                    DSButton(title: "Link", variant: .link) {}
                    DSButton(title: "Brand link", variant: .brandLink) {}
                    DSIconButton(icon: Image(systemName: "heart.fill")) {}
                }

                VStack(alignment: .leading, spacing: .sm) {
                    Button {} label: {
                        HStack(spacing: .xs) {
                            Image(systemName: "heart.fill")
                            Text("Custom label")
                            Text("New")
                                .font(.caption.bold())
                                .padding(.horizontal, .xs)
                                .background(.white.opacity(0.25), in: Capsule())
                        }
                    }
                    .primaryButtonStyle()

                    Button("Skip for now") {}
                        .tertiaryButtonStyle(size: .small)

                    Button {} label: {
                        VStack(spacing: .xxs) {
                            Text("Two-line label")
                            Text("grows past the minimum height").fontStyle(.label)
                        }
                        .padding(.vertical, .xs)
                    }
                    .secondaryButtonStyle()

                    Button("Disabled") {}
                        .primaryButtonStyle()
                        .disabled(true)
                }
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSButtonGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSButtonGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSButtonGallery().designSystem()
}

#Preview("BW Dark") {
    DesignSystem.configure(theme: BWTheme())
    return DSButtonGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("Default") {
    DesignSystem.configure(theme: BWTheme())
    return DSButtonGallery().designSystem()
}

#Preview("Default Dark") {
    DesignSystem.configure(theme: BWTheme())
    return DSButtonGallery().designSystem()
}
