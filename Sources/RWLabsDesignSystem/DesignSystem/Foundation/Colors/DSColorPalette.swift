//
//  DSColorPalette.swift
//  RWLDesignSystem
//
//  The protocol a host app conforms to in order to supply colors to the design system.
//
//  The app provides the seven color families as 50–900 scales. Every role group used by
//  components (text, background, border, button, icon, input, progress, selection, pill, badge) is derived from those scales, and
//  any of them can be overridden by the palette.
//
//  struct AppColors: DSColorPalette {
//      let primary: any DSColorScale = DSAdaptiveColorScale(
//          light: DSStaticColorScale(shade50: Color(hex: "#FEF0F1"), …, shade900: Color(hex: "#631219")),
//          dark:  DSStaticColorScale(shade50: Color(hex: "#1F070A"), …, shade900: Color(hex: "#FEF0F1"))
//      )
//      let secondary: any DSColorScale = …
//      let neutral:   any DSColorScale = …
//      let success:   any DSColorScale = …
//      let warning:   any DSColorScale = …
//      let error:     any DSColorScale = …
//      let info:      any DSColorScale = …
//  }
//
//  DesignSystem.configure(colors: AppColors())
//

import SwiftUI

public protocol DSColorPalette: Sendable {

    // MARK: - Color Families
    var primary:   any DSColorScale { get }
    var secondary: any DSColorScale { get }
    var neutral:   any DSColorScale { get }
    var success:   any DSColorScale { get }
    var warning:   any DSColorScale { get }
    var error:     any DSColorScale { get }
    var info:      any DSColorScale { get }

    // MARK: - Fixed
    /// Pure white, e.g. text on a brand fill. Does not change with appearance.
    var white:  Color { get }
    /// Pure black. Does not change with appearance.
    var black:  Color { get }
    var shadow: Color { get }

    // MARK: - Roles
    var text:       any DSTextColors       { get }
    var background: any DSBackgroundColors { get }
    var border:     any DSBorderColors     { get }
    var button:     any DSButtonColors     { get }
    var icon:       any DSIconColors       { get }
    var input:      any DSInputColors      { get }
    var progress:   any DSProgressColors   { get }
    var selection:  any DSSelectionColors  { get }
    var pill:       any DSPillColors       { get }
    var badge:      any DSBadgeColors      { get }
}

// MARK: - Defaults
public extension DSColorPalette {
    var white:  Color { .white }
    var black:  Color { .black }
    var shadow: Color { .black }

    var text:       any DSTextColors       { DSDefaultTextColors(palette: self) }
    var background: any DSBackgroundColors { DSDefaultBackgroundColors(palette: self) }
    var border:     any DSBorderColors     { DSDefaultBorderColors(palette: self) }
    var button:     any DSButtonColors     { DSDefaultButtonColors(palette: self) }
    var icon:       any DSIconColors       { DSDefaultIconColors(palette: self) }
    var input:      any DSInputColors      { DSDefaultInputColors(palette: self) }
    var progress:   any DSProgressColors   { DSDefaultProgressColors(palette: self) }
    var selection:  any DSSelectionColors  { DSDefaultSelectionColors(palette: self) }
    var pill:       any DSPillColors       { DSDefaultPillColors(palette: self) }
    var badge:      any DSBadgeColors      { DSDefaultBadgeColors(palette: self) }
}

// MARK: - Fallback Palette
/// Used until the app calls `DesignSystem.configure(colors:)`. Scales are generated from
/// system colors, so it is only a placeholder for previews and tests.
public struct DSFallbackColorPalette: DSColorPalette {
    public static let `default` = DSFallbackColorPalette()

    public let primary:   any DSColorScale = DSGeneratedColorScale(base: .red)
    public let secondary: any DSColorScale = DSGeneratedColorScale(base: .pink)
    public let neutral:   any DSColorScale = DSGeneratedColorScale(base: .gray)
    public let success:   any DSColorScale = DSGeneratedColorScale(base: .green)
    public let warning:   any DSColorScale = DSGeneratedColorScale(base: .orange)
    public let error:     any DSColorScale = DSGeneratedColorScale(base: .red)
    public let info:      any DSColorScale = DSGeneratedColorScale(base: .blue)

    public init() {}
}
