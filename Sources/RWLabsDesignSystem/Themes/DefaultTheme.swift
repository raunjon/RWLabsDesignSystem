//
//  DefaultTheme.swift
//  RWLDesignSystem
//
//  The theme used until the app calls `DesignSystem.configure(theme:)`: placeholder colors
//  generated from system colors, and the system font.
//

import SwiftUI

// MARK: - Default Theme
@MainActor
public struct DefaultTheme: @MainActor DSTheme {
    public var colors: any DSColorPalette
    public var typography: any DSTypographyScale
    public var name: String

    public init(
        name: String = "Default",
        colors: any DSColorPalette = DSFallbackColorPalette.default,
        typography: any DSTypographyScale = DSSystemTypography.default
    ) {
        self.name = name
        self.colors = colors
        self.typography = typography
    }

    public static let `default` = DefaultTheme()
}
