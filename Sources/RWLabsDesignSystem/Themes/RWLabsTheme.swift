//
//  RWLabsTheme.swift
//  RWLDesignSystem
//
//  RWLabs brand theme, from the PlusOne Figma color system
//  (light: "Colours and rules", dark: "Dark Mode — Color Palette").
//
//  Lives here for testing; it is meant to move into the app, which then calls
//  `DesignSystem.configure(theme: RWLabsTheme())`.
//

import SwiftUI

// MARK: - RWLabs Theme
@MainActor
public struct RWLabsTheme: @MainActor DSTheme {
    public var colors: any DSColorPalette = RWLabsColor.default
    /// Figma uses Inter. Falls back to the system font until the Inter faces are bundled.
    public var typography: any DSTypographyScale = DSCustomFontTypography(family: "Inter")
    public var name: String = "RWLabs"

    public static let `default` = RWLabsTheme()

    public init() {}
}

// MARK: - RWLabs Color Palette
/// Dark scales are the light scales inverted, with 500 shared by both modes.
public struct RWLabsColor: DSColorPalette {
    public let primary: any DSColorScale = RWLabsColor.scale(
        light: ["FEF0F1", "FDD8DB", "FABFC4", "F79AA1", "F37480", "EF505F", "D93D4C", "B82C3A", "8F1E29", "631219"],
        dark:  ["1F070A", "3A0E12", "5A1820", "7D2330", "A63040", "EF505F", "F37480", "F79AA1", "FABFC4", "FEF0F1"]
    )

    public let secondary: any DSColorScale = RWLabsColor.scale(
        light: ["F9ECEC", "F2D0D2", "E8AEB1", "D9878B", "CB6168", "BD3844", "A62D38", "8A222C", "6B181F", "480E14"],
        dark:  ["160508", "2B0A0F", "471219", "661C25", "8A2830", "BD3844", "CB6168", "D9878B", "E8AEB1", "F9ECEC"]
    )

    public let neutral: any DSColorScale = RWLabsColor.scale(
        light: ["F7F8F9", "EEF0F3", "D8DCE3", "BCC3CE", "9AA4B2", "7A8594", "5E6A78", "45515E", "2E3844", "1A2330"],
        dark:  ["111820", "1A2330", "2E3844", "45515E", "5E6A78", "7A8594", "9AA4B2", "BCC3CE", "D8DCE3", "F7F8F9"]
    )

    public let success: any DSColorScale = RWLabsColor.scale(
        light: ["EDFAF4", "D1F3E4", "A3E7C9", "6DD6AB", "3DC28E", "1AAD74", "13945F", "0D7349", "095234", "053320"],
        dark:  ["041A10", "07291A", "0D4B2E", "116640", "158A56", "1AAD74", "3DC28E", "6DD6AB", "A3E7C9", "EDFAF4"]
    )

    public let warning: any DSColorScale = RWLabsColor.scale(
        light: ["FFFBEB", "FEF4C7", "FDE68A", "FBD14E", "F8BC1E", "EFA700", "CC8A00", "A36C00", "7A5000", "4F3200"],
        dark:  ["1A1100", "2E1F00", "4F3500", "7A5200", "A36E00", "EFA700", "F8BC1E", "FBD14E", "FDE68A", "FFFBEB"]
    )

    public let error: any DSColorScale = RWLabsColor.scale(
        light: ["FEF1F2", "FDD9DC", "FBB0B6", "F7818A", "F25260", "E8293A", "C9202F", "A11824", "78101A", "4E0910"],
        dark:  ["1A0406", "310810", "530F1A", "7A1622", "A1202E", "E8293A", "F25260", "F7818A", "FBB0B6", "FEF1F2"]
    )

    public let info: any DSColorScale = RWLabsColor.scale(
        light: ["EEF5FF", "D5E8FE", "ABCFFC", "76AFF8", "4490F3", "1F72E8", "1559C4", "0D419A", "082B6E", "041944"],
        dark:  ["020C1E", "041632", "082B6E", "0D419A", "1559C4", "1F72E8", "4490F3", "76AFF8", "ABCFFC", "EEF5FF"]
    )

    public static let `default` = RWLabsColor()

    /// Builds an adaptive scale from ten hex values per mode, ordered 50 → 900.
    private static func scale(light: [String], dark: [String]) -> DSAdaptiveColorScale {
        DSAdaptiveColorScale(light: values(light), dark: values(dark))
    }

    private static func values(_ hex: [String]) -> DSStaticColorScale {
        precondition(hex.count == 10, "A color scale needs 10 steps (50–900)")
        return DSStaticColorScale(
            shade50:  Color(hex: hex[0]),
            shade100: Color(hex: hex[1]),
            shade200: Color(hex: hex[2]),
            shade300: Color(hex: hex[3]),
            shade400: Color(hex: hex[4]),
            shade500: Color(hex: hex[5]),
            shade600: Color(hex: hex[6]),
            shade700: Color(hex: hex[7]),
            shade800: Color(hex: hex[8]),
            shade900: Color(hex: hex[9])
        )
    }
}
