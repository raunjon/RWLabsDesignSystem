//
//  ThemeConfiguration.swift
//  RWLDesignSystem
//
//  Theme configuration for the Design System
//  This file bridges the Architecture layer with the Design System layer
//

import Foundation
import SwiftUI

// MARK: - Main Theme

// MARK: - BW Theme Implementation
@MainActor
public struct BWTheme: @MainActor DSTheme {
    public var colors: any DSColorPalette = BWColor.default
    public var typography: any DSTypographyScale = DSSystemTypography.default
    public var name: String = "BW"

    public static let `default` = BWTheme()

    public init() {}
}

// MARK: - BW Color Palette
/// Black and white. Every family except error is a grayscale ramp that inverts in dark mode,
/// so brand fills are black on white in light mode and white on black in dark mode. Error
/// stays red so validation errors stand out.
public struct BWColor: DSColorPalette {
    private static let mono = Self.grayscale(base: "000000", darkBase: "FFFFFF")

    public let primary:   any DSColorScale = BWColor.mono
    public let secondary: any DSColorScale = BWColor.grayscale(base: "262626", darkBase: "E5E5E5")
    public let neutral:   any DSColorScale = BWColor.grayscale(base: "737373", darkBase: "8C8C8C")
    public let success:   any DSColorScale = BWColor.mono
    public let warning:   any DSColorScale = BWColor.mono
    public let error:     any DSColorScale = DSGeneratedColorScale(base: .red)
    public let info:      any DSColorScale = BWColor.mono

    public var button: any DSButtonColors { BWButtonColors(palette: self) }
    public var input:  any DSInputColors  { BWInputColors(palette: self) }
    public var selection: any DSSelectionColors { BWSelectionColors(palette: self) }
    public var badge: any DSBadgeColors { BWBadgeColors(palette: self) }

    public static let `default` = BWColor()

    /// White → black ramp in light mode, black → white in dark mode; `base` is the 500 step.
    private static func grayscale(base: String, darkBase: String) -> DSAdaptiveColorScale {
        DSAdaptiveColorScale(
            light: DSStaticColorScale(
                shade50:  Color(hex: "FFFFFF"),
                shade100: Color(hex: "F5F5F5"),
                shade200: Color(hex: "E5E5E5"),
                shade300: Color(hex: "D4D4D4"),
                shade400: Color(hex: "A3A3A3"),
                shade500: Color(hex: base),
                shade600: Color(hex: "525252"),
                shade700: Color(hex: "404040"),
                shade800: Color(hex: "262626"),
                shade900: Color(hex: "000000")
            ),
            dark: DSStaticColorScale(
                shade50:  Color(hex: "000000"),
                shade100: Color(hex: "171717"),
                shade200: Color(hex: "262626"),
                shade300: Color(hex: "404040"),
                shade400: Color(hex: "525252"),
                shade500: Color(hex: darkBase),
                shade600: Color(hex: "A3A3A3"),
                shade700: Color(hex: "D4D4D4"),
                shade800: Color(hex: "E5E5E5"),
                shade900: Color(hex: "FFFFFF")
            )
        )
    }
}

/// The primary fill inverts with the appearance, so its label uses the surface color instead
/// of the fixed white the default mapping uses. The disabled fill is a light gray in light
/// mode, so its label uses mid gray. Destructive buttons stay red and keep white labels.
struct BWButtonColors: DSButtonColors {
    let palette: any DSColorPalette

    var primaryText:  Color { palette.neutral.shade50 }
    var disabledText: Color { palette.neutral.shade500 }
}

/// BW's lightest step is pure white, the same as the field background, so the autofill
/// fill steps up one shade to stay visible.
struct BWInputColors: DSInputColors {
    let palette: any DSColorPalette

    var autofillBackground: Color { palette.neutral.shade100 }
}

/// BW's brand fill flips between black and white, so the checkmark flips with it.
/// Its lightest gray is pure white, so selected surfaces step up to neutral 100.
struct BWSelectionColors: DSSelectionColors {
    let palette: any DSColorPalette

    var indicatorCheck:  Color { palette.neutral.shade50 }
    var surfaceSelected: Color { palette.neutral.shade100 }
}

/// BW's lightest secondary shade is white, so the brand badge uses a gray fill instead.
struct BWBadgeColors: DSBadgeColors {
    let palette: any DSColorPalette

    var brandFill: Color { palette.neutral.shade100 }
}
