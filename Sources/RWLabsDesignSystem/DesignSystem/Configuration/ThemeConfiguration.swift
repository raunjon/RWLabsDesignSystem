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
    public var colors: BWColor = BWColor.default
    public var typography: DSTypographyScale = BWFont.default
    public var name: String = "BW"

    public static let `default` = DefaultTheme()

    public init() {}
}

// MARK: - BW Color Palette

@MainActor
public struct BWColor: @MainActor DSColorPalette {
    public var background: DefaultBackgroundColorPalette = .default
    public var border: DefaultBorderColorPalette = .default
    public var button: DefaultButtonColorPalette = .default
    public var text: DefaultTextColorPalette = .default
    public var brandTertiary: Color {
        Color.gray
    }
    
    public var baseGrayPrimary: Color {
        Color.gray
    }
    
    public var baseGraySecondary: Color {
        Color.gray
    }
    
    public var brandPrimary: Color {
        Color.black
    }

    public var brandSecondary: Color {
        Color.white
    }

    public var brandAccent: Color {
        Color.blue
    }

    @MainActor public static let `default` = BWColor()
}

// MARK: - BW Font Scale

struct BWFont: DSTypographyScale {
    var fontFamily: String? {
        return UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName
    }

    public static let `default` = BWFont()
}
