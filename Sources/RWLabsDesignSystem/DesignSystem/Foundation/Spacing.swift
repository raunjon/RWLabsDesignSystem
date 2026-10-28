//
//  Spacing.swift
//  RWLDesignSystem
//
//  Design system spacing and layout tokens
//

import SwiftUI

// MARK: - Spacing System
public struct DSSpacing {

    /// 4pt spacing
    public static let xxs: CGFloat = 4

    /// 8pt spacing
    public static let xs: CGFloat = 8

    /// 12pt spacing
    public static let sm: CGFloat = 12

    /// 16pt spacing
    public static let md: CGFloat = 16

    /// 24pt spacing
    public static let lg: CGFloat = 24

    /// 32pt spacing
    public static let xl: CGFloat = 32

    /// 48pt spacing
    public static let xxl: CGFloat = 48

    /// 64pt spacing
    public static let xxxl: CGFloat = 64

    // MARK: - Component-specific spacing
    public struct Component {
        /// Button internal padding
        public static let buttonPadding = EdgeInsets(
            top: DSSpacing.sm,
            leading: DSSpacing.lg,
            bottom: DSSpacing.sm,
            trailing: DSSpacing.lg
        )

        /// Small button internal padding
        public static let buttonPaddingSmall = EdgeInsets(
            top: DSSpacing.xs,
            leading: DSSpacing.md,
            bottom: DSSpacing.xs,
            trailing: DSSpacing.md
        )

        /// Card padding
        public static let cardPadding = DSSpacing.md

        /// Input field padding
        public static let inputPadding = CGFloat.s20

        /// Alert padding
        public static let alertPadding = DSSpacing.md
    }

    // MARK: - Layout spacing
    public struct Layout {
        /// Screen edge margins
        public static let screenMargin = DSSpacing.md

        /// Section spacing
        public static let sectionSpacing = DSSpacing.lg

        /// Item spacing in lists
        public static let itemSpacing = DSSpacing.md

        /// Minimum touch target size (44pt)
        public static let minTouchTarget: CGFloat = 44
    }
}

// MARK: - Border Radius
/// Names match the Figma radius scale (none, xs, sm, md, lg, xl, 2xl, 3xl, full).
public struct DSRadius {

    /// none (0pt)
    public static let none: CGFloat = 0

    /// xs (4pt)
    public static let xs: CGFloat = 4

    /// sm (8pt)
    public static let sm: CGFloat = 8

    /// md (12pt)
    public static let md: CGFloat = 12

    /// lg (16pt)
    public static let lg: CGFloat = 16

    /// xl (20pt)
    public static let xl: CGFloat = 20

    /// 2xl (24pt)
    public static let xxl: CGFloat = 24

    /// 3xl (32pt)
    public static let xxxl: CGFloat = 32

    /// full: circle/pill
    public static let full: CGFloat = 999
}

// MARK: - Border Width
public struct DSBorderWidth {

    /// Thin border (1pt)
    public static let thin: CGFloat = 1

    /// Medium border (2pt)
    public static let medium: CGFloat = 2

    /// Thick border (3pt)
    public static let thick: CGFloat = 3
}

public extension CGFloat {
    // MARK: - Border Width
    static let thin   = DSBorderWidth.thin
    static let medium = DSBorderWidth.medium
    static let thick  = DSBorderWidth.thick
}

public extension View {
    func border(_ color: Color, lineWidth: CGFloat = .thin, cornerRadius: CGFloat = 0) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: lineWidth)
        )
    }
}

// MARK: - Shadows
public struct DSShadow {

    public struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        
        @MainActor public static let sm:   Self = DSShadow.sm
        @MainActor public static let md:   Self = DSShadow.md
        @MainActor public static let lg:   Self = DSShadow.lg
        @MainActor public static let none: Self = DSShadow.none
    }

    /// Small elevation shadow
    @MainActor
    public static var sm: ShadowStyle {
        ShadowStyle(
            color: Color.Shadow.primary.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
    }

    /// Medium elevation shadow
    @MainActor
    public static var md: ShadowStyle {
        ShadowStyle(
            color: Color.Shadow.primary.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    /// Large elevation shadow
    @MainActor
    public static var lg: ShadowStyle {
        ShadowStyle(
            color: Color.Shadow.primary.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    /// no shadow
    @MainActor
    public static var none: ShadowStyle {
        ShadowStyle(
            color: Color.Shadow.primary.opacity(0.0),
            radius: 0,
            x: 0,
            y: 0
        )
    }
}

// MARK: - View Extension for Shadows
public extension View {
    func shadow(_ style: DSShadow.ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}

public enum Spacing: CGFloat, CaseIterable {
    case s0 = 0
    case s4 = 4
    case s8 = 8
    case s12 = 12
    case s16 = 16
    case s18 = 18
    case s20 = 20
    case s24 = 24
    case s32 = 32
    case s40 = 40
    case s48 = 48
    case s56 = 56
    case s64 = 64
    case s80 = 80
    case s96 = 96
    case s128 = 128
    
    public var value: CGFloat {
        rawValue
    }
}

public extension CGFloat {
    static var s0:  CGFloat { Spacing.s0.value }
    static var s4:  CGFloat { Spacing.s4.value }
    static var s8:  CGFloat { Spacing.s8.value }
    static var s12: CGFloat { Spacing.s12.value }
    static var s16: CGFloat { Spacing.s16.value }
    static var s18: CGFloat { Spacing.s18.value }
    static var s20: CGFloat { Spacing.s20.value }
    static var s24: CGFloat { Spacing.s24.value }
    static var s32: CGFloat { Spacing.s32.value }
    static var s40: CGFloat { Spacing.s40.value }
    static var s48: CGFloat { Spacing.s48.value }
    static var s56: CGFloat { Spacing.s56.value }
    static var s64: CGFloat { Spacing.s64.value }
    static var s80: CGFloat { Spacing.s80.value }
    static var s96: CGFloat { Spacing.s96.value }
    static var s128: CGFloat { Spacing.s128.value }
}

public enum CornerRadius: CGFloat, CaseIterable {
    case r0  = 0
    case r4  = 4
    case r8  = 8
    case r12 = 12
    case r16 = 16
    case r20 = 20
    case r24 = 24
    case r32 = 32
    
    public var value: CGFloat {
        rawValue
    }
}

public extension CGFloat {
    static var r0:  CGFloat { CornerRadius.r0.value }
    static var r4:  CGFloat { CornerRadius.r4.value }
    static var r8:  CGFloat { CornerRadius.r8.value }
    static var r12: CGFloat { CornerRadius.r12.value }
    static var r16: CGFloat { CornerRadius.r16.value }
    static var r20: CGFloat { CornerRadius.r20.value }
    static var r24: CGFloat { CornerRadius.r24.value }
    static var r32: CGFloat { CornerRadius.r32.value }
}

public extension View {
    func cornerRadius(_ radius: CornerRadius) -> some View {
        self.cornerRadius(radius.value)
    }
}

public extension CGFloat {

    // MARK: - Spacing
    /// 4px
    static let xxs = DSSpacing.xxs
    /// 8px
    static let xs  = DSSpacing.xs
    /// 12px
    static let sm  = DSSpacing.sm
    /// 16px
    static let md  = DSSpacing.md
    /// 23px
    static let lg  = DSSpacing.lg
    /// 32px
    static let xl  = DSSpacing.xl
    /// 48px
    static let xxl = DSSpacing.xxl
    /// 64px
    static let xxxl = DSSpacing.xxxl

    // MARK: - Radius
    /// 0px
    static let radiusNone = DSRadius.none
    /// 4px
    static let radiusXS   = DSRadius.xs
    /// 8px
    static let radiusSM   = DSRadius.sm
    /// 12px
    static let radiusMD   = DSRadius.md
    /// 16px
    static let radiusLG   = DSRadius.lg
    /// 20px
    static let radiusXL   = DSRadius.xl
    /// 24px (Figma 2xl)
    static let radiusXXL  = DSRadius.xxl
    /// 32px (Figma 3xl)
    static let radiusXXXL = DSRadius.xxxl
    /// 999
    static let radiusFull = DSRadius.full

    // MARK: - Border Width
    /// 1px
    static let borderThin   = DSBorderWidth.thin
    /// 2px
    static let borderMedium = DSBorderWidth.medium
    /// 3px
    static let borderThick  = DSBorderWidth.thick

    // MARK: - Layout
    /// 16px
    static let screenMargin = DSSpacing.Layout.screenMargin
    /// 24px
    static let sectionSpacing = DSSpacing.Layout.sectionSpacing
    /// 16px
    static let itemSpacing = DSSpacing.Layout.itemSpacing
    /// 44px
    static let minTouchTarget = DSSpacing.Layout.minTouchTarget
}

public extension EdgeInsets {

    // MARK: - Uniform Insets
    init(all value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    // MARK: - Horizontal / Vertical
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }

    // MARK: - Component Tokens
    static let button = DSSpacing.Component.buttonPadding
    static let buttonSmall = DSSpacing.Component.buttonPaddingSmall

    static let card = EdgeInsets(all: DSSpacing.Component.cardPadding)
    static let input = EdgeInsets(all: DSSpacing.Component.inputPadding)
    static let alert = EdgeInsets(all: DSSpacing.Component.alertPadding)
    
    static let zero = EdgeInsets(all: 0)
}
