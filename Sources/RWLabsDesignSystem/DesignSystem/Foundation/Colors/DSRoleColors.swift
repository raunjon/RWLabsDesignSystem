//
//  DSRoleColors.swift
//  RWLDesignSystem
//
//  Role colors used by components. Each role protocol has a default mapping onto the
//  palette's scales; a palette can return its own conformance to change any of them.
//

import SwiftUI

// MARK: - Text
public protocol DSTextColors: Sendable {
    var palette: any DSColorPalette { get }
    var primary:     Color { get }
    var secondary:   Color { get }
    var tertiary:    Color { get }
    var brand:       Color { get }
    var disabled:    Color { get }
    var placeholder: Color { get }
    var inverse:     Color { get }
    var error:       Color { get }
}

public extension DSTextColors {
    var primary:     Color { palette.neutral.shade900 }
    var secondary:   Color { palette.neutral.shade600 }
    var tertiary:    Color { palette.neutral.base }
    var brand:       Color { palette.primary.base }
    var disabled:    Color { palette.neutral.shade400 }
    var placeholder: Color { palette.neutral.shade400 }
    var inverse:     Color { palette.neutral.shade50 }
    var error:       Color { palette.error.base }
}

// MARK: - Background
public protocol DSBackgroundColors: Sendable {
    var palette: any DSColorPalette { get }
    var primary:          Color { get }
    var secondary:        Color { get }
    var tertiary:         Color { get }
    var secondaryInverse: Color { get }
    var tertiaryInverse:  Color { get }
    var inverse:          Color { get }
    var brand:            Color { get }
    var brandInverse:     Color { get }
}

public extension DSBackgroundColors {
    /// Page background: white in light mode (Figma frames), neutral 50 in dark.
    var primary:          Color { Color(light: palette.white, dark: palette.neutral.shade50) }
    var secondary:        Color { palette.neutral.shade100 }
    var tertiary:         Color { palette.neutral.shade200 }
    var secondaryInverse: Color { palette.neutral.shade800 }
    var tertiaryInverse:  Color { palette.neutral.shade700 }
    var inverse:          Color { palette.neutral.shade900 }
    var brand:            Color { palette.primary.base }
    var brandInverse:     Color { palette.secondary.base }
}

// MARK: - Border
public protocol DSBorderColors: Sendable {
    var palette: any DSColorPalette { get }
    var focused:     Color { get }
    var subtle:      Color { get }
    var active:      Color { get }
    var disabled:    Color { get }
    var placeholder: Color { get }
    var inverse:     Color { get }
    var error:       Color { get }
}

public extension DSBorderColors {
    var focused:     Color { palette.neutral.shade900 }
    var subtle:      Color { palette.neutral.shade300 }
    var active:      Color { palette.primary.base }
    var disabled:    Color { palette.neutral.shade300 }
    var placeholder: Color { palette.neutral.shade400 }
    var inverse:     Color { palette.neutral.shade50 }
    var error:       Color { palette.error.base }
}

// MARK: - Button
/// Fills and labels for `DSButton`, following the Figma CTA button states.
public protocol DSButtonColors: Sendable {
    var palette: any DSColorPalette { get }
    var primary:            Color { get }
    var primaryText:        Color { get }
    var primaryPressed:     Color { get }
    var secondary:          Color { get }
    var secondaryText:      Color { get }
    var secondaryPressed:   Color { get }
    var tertiary:           Color { get }
    var tertiaryText:       Color { get }
    var tertiaryBorder:     Color { get }
    var tertiaryPressed:    Color { get }
    var disabled:           Color { get }
    var disabledText:       Color { get }
    var destructive:        Color { get }
    var destructiveText:    Color { get }
    var destructivePressed: Color { get }
    var linkText:           Color { get }
    var brandLinkText:      Color { get }
}

public extension DSButtonColors {
    var primary:            Color { palette.primary.base }
    var primaryText:        Color { palette.white }
    var primaryPressed:     Color { palette.secondary.base }
    var secondary:          Color { palette.neutral.shade100 }
    var secondaryText:      Color { palette.neutral.shade700 }
    var secondaryPressed:   Color { palette.neutral.shade200 }
    var tertiary:           Color { Color(light: palette.white, dark: palette.neutral.shade50) }
    var tertiaryText:       Color { palette.neutral.shade900 }
    var tertiaryBorder:     Color { palette.neutral.shade900 }
    var tertiaryPressed:    Color { palette.neutral.shade100 }
    var disabled:           Color { palette.primary.shade200 }
    var disabledText:       Color { palette.white }
    var destructive:        Color { palette.error.base }
    var destructiveText:    Color { palette.white }
    var destructivePressed: Color { palette.error.shade600 }
    var linkText:           Color { palette.neutral.shade900 }
    var brandLinkText:      Color { palette.secondary.base }
}

// MARK: - Input
/// Text fields, phone and OTP inputs, following the Figma input field states.
public protocol DSInputColors: Sendable {
    var palette: any DSColorPalette { get }
    var text:               Color { get }
    var placeholder:        Color { get }
    var title:              Color { get }
    var helper:             Color { get }
    var helperError:        Color { get }
    var background:         Color { get }
    var border:             Color { get }
    var borderFocused:      Color { get }
    var borderError:        Color { get }
    var autofillBackground: Color { get }
    var autofillText:       Color { get }
    var otpBorderEmpty:     Color { get }
    var icon:               Color { get }
}

public extension DSInputColors {
    var text:               Color { palette.neutral.shade900 }
    var placeholder:        Color { palette.neutral.shade500 }
    var title:              Color { palette.neutral.shade900 }
    var helper:             Color { palette.info.shade800 }
    /// Figma uses error 400 in light mode; in the inverted dark scale the same red is 600.
    var helperError:        Color { Color(light: palette.error.shade400, dark: palette.error.shade600) }
    var background:         Color { Color(light: palette.white, dark: palette.neutral.shade50) }
    var border:             Color { palette.neutral.shade200 }
    var borderFocused:      Color { palette.neutral.shade900 }
    var borderError:        Color { palette.error.base }
    /// Dark mode steps up to neutral 100 so the fill stays visible against the field background.
    var autofillBackground: Color { Color(light: palette.neutral.shade50, dark: palette.neutral.shade100) }
    var autofillText:       Color { palette.neutral.shade600 }
    var otpBorderEmpty:     Color { palette.neutral.shade600 }
    var icon:               Color { palette.neutral.shade900 }
}

// MARK: - Progress
public protocol DSProgressColors: Sendable {
    var palette: any DSColorPalette { get }
    /// Completed part of the bar, and the spinner arc
    var fill:         Color { get }
    /// Remaining part of the bar
    var track:        Color { get }
    /// Full ring behind the spinner arc
    var spinnerTrack: Color { get }
    /// Dots loader
    var dots:         Color { get }
}

public extension DSProgressColors {
    var fill:         Color { palette.primary.base }
    var track:        Color { palette.neutral.shade200 }
    var spinnerTrack: Color { palette.primary.shade100 }
    /// Figma draws the dots at 60% opacity
    var dots:         Color { palette.primary.shade300.opacity(0.6) }
}

// MARK: - Selection
/// Pickers, option rows, selection cards, wheels and segmented toggles.
public protocol DSSelectionColors: Sendable {
    var palette: any DSColorPalette { get }
    /// Unselected ring of the selection mark
    var indicatorBorder: Color { get }
    /// Selected fill of the selection mark
    var indicatorFill:   Color { get }
    /// Checkmark on the selected fill
    var indicatorCheck:  Color { get }
    /// Option row / card surface
    var surface:         Color { get }
    var surfaceSelected: Color { get }
    var border:          Color { get }
    var borderSelected:  Color { get }
    /// Soft glow around cards and selected rows
    var shadow:          Color { get }
    /// Circle behind a selection card's icon
    var iconBackground:  Color { get }
    /// Band behind the centered wheel row
    var wheelHighlight:  Color { get }
    var toggleTrack:     Color { get }
    var toggleThumb:     Color { get }
}

public extension DSSelectionColors {
    var indicatorBorder: Color { palette.neutral.shade300 }
    var indicatorFill:   Color { palette.primary.base }
    var indicatorCheck:  Color { palette.white }
    var surface:         Color { Color(light: palette.white, dark: palette.neutral.shade50) }
    var surfaceSelected: Color { Color(light: palette.neutral.shade50, dark: palette.neutral.shade100) }
    var border:          Color { palette.neutral.shade200 }
    var borderSelected:  Color { palette.neutral.shade100 }
    var shadow:          Color { palette.neutral.shade200 }
    var iconBackground:  Color { palette.neutral.shade100 }
    /// Figma: neutral 300 at 30%
    var wheelHighlight:  Color { palette.neutral.shade300.opacity(0.3) }
    var toggleTrack:     Color { palette.neutral.shade100 }
    var toggleThumb:     Color { Color(light: palette.white, dark: palette.neutral.shade300) }
}

// MARK: - Pill
public protocol DSPillColors: Sendable {
    var palette: any DSColorPalette { get }
    var text:              Color { get }
    /// Large pill (Figma "Pill")
    var border:            Color { get }
    var selectedFill:      Color { get }
    var removeFill:        Color { get }
    var removeIcon:        Color { get }
    /// Small pill (Figma "Long Pill")
    var compactBorder:     Color { get }
    var compactSelectedFill: Color { get }
    var compactSelectedText: Color { get }
    var infoFill:          Color { get }
    var infoBorder:        Color { get }
}

public extension DSPillColors {
    var text:                Color { palette.neutral.shade900 }
    var border:              Color { palette.neutral.shade100 }
    /// Dark mode steps up to neutral 100 so the pill separates from the page.
    var selectedFill:        Color { Color(light: palette.neutral.shade50, dark: palette.neutral.shade100) }
    var removeFill:          Color { palette.neutral.shade900 }
    var removeIcon:          Color { Color(light: palette.white, dark: palette.neutral.shade50) }
    var compactBorder:       Color { palette.neutral.shade200 }
    var compactSelectedFill: Color { palette.neutral.shade800 }
    var compactSelectedText: Color { palette.neutral.shade50 }
    var infoFill:            Color { palette.neutral.shade50 }
    var infoBorder:          Color { palette.neutral.shade100 }
}

// MARK: - Badge
public protocol DSBadgeColors: Sendable {
    var palette: any DSColorPalette { get }
    /// "Recommended" tab
    var highlightFill: Color { get }
    var highlightText: Color { get }
    /// "ID verified"
    var brandFill:     Color { get }
    var brandText:     Color { get }
    var brandIcon:     Color { get }
    /// "Photo verified"
    var neutralFill:   Color { get }
    var neutralText:   Color { get }
}

public extension DSBadgeColors {
    var highlightFill: Color { palette.neutral.shade900 }
    var highlightText: Color { Color(light: palette.white, dark: palette.neutral.shade50) }
    var brandFill:     Color { palette.secondary.shade50 }
    var brandText:     Color { palette.secondary.shade900 }
    var brandIcon:     Color { palette.secondary.base }
    var neutralFill:   Color { palette.neutral.shade100 }
    var neutralText:   Color { palette.neutral.shade900 }
}

// MARK: - Icon
public protocol DSIconColors: Sendable {
    var palette: any DSColorPalette { get }
    var primary:        Color { get }
    var secondary:      Color { get }
    var inverse:        Color { get }
    var brand:          Color { get }
    var brandSecondary: Color { get }
    var brandTertiary:  Color { get }
    var brandAccent:    Color { get }
    var placeholder:    Color { get }
}

public extension DSIconColors {
    var primary:        Color { palette.neutral.shade50 }
    var secondary:      Color { palette.neutral.shade600 }
    var inverse:        Color { palette.neutral.shade900 }
    var brand:          Color { palette.primary.base }
    var brandSecondary: Color { palette.secondary.base }
    var brandTertiary:  Color { palette.primary.shade300 }
    var brandAccent:    Color { palette.primary.shade200 }
    var placeholder:    Color { palette.neutral.base }
}

// MARK: - Default Conformances
public struct DSDefaultTextColors: DSTextColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultBackgroundColors: DSBackgroundColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultBorderColors: DSBorderColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultButtonColors: DSButtonColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultInputColors: DSInputColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultProgressColors: DSProgressColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultSelectionColors: DSSelectionColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultPillColors: DSPillColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultBadgeColors: DSBadgeColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}

public struct DSDefaultIconColors: DSIconColors {
    public let palette: any DSColorPalette
    public init(palette: any DSColorPalette) { self.palette = palette }
}
