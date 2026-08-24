//
//  Theme.swift
//  RWLDesignSystem
//
//  Theming system for customizable colors and typography
//

import SwiftUI

public protocol DSColorPalette {
    associatedtype BackgroundColorPalette: DSBackgroundColorPalette
    associatedtype BorderColorPalette:     DSBorderColorPalette
    associatedtype ButtonColorPalette:     DSButtonColorPalette
    associatedtype TextColorPalette:       DSTextColorPalette

    // MARK: - Brand
    var brandPrimary:        Color { get }
    var brandSecondary:      Color { get }
    var brandTertiary:       Color { get }
    var brandAccent:         Color { get }
    // MARK: - Seman
    var semanticError:       Color { get }
    var semanticSuccess:     Color { get }
    var semanticWarning:     Color { get }
    var semanticInfo:        Color { get }
    
    // MARK: - Neutrals
    var neutralBlack:        Color { get }
    var neutralWhite:        Color { get }
    
    // MARK: - Base
    var baseBlack:           Color { get }
    var baseWhite:           Color { get }
    var baseGrayPrimary:     Color { get }
    var baseGraySecondary:   Color { get }
    
    // MARK: - Gray Scale
    var gray100:             Color { get }
    var gray200:             Color { get }
    var gray300:             Color { get }
    var gray400:             Color { get }
    
    var background: BackgroundColorPalette { get }
    var button:     ButtonColorPalette     { get }
    var border:     BorderColorPalette     { get }
    var text:       TextColorPalette       { get }
}


extension DSColorPalette {
    // Semantic Colors
    public var semanticError:             Color { Color(hex: "D32F2F") }
    public var semanticSuccess:           Color { Color(hex: "388E3C") }
    public var semanticWarning:           Color { Color(hex: "F57C00") }
    public var semanticInfo:              Color { Color(hex: "0288D1") }
    public var semanticBlue:              Color {      Color.blue      }

    // Neutral Colors
    public var neutralWhite:              Color { Color(hex: "FFFFFF") }
    public var neutralBlack:              Color { Color(hex: "212121") }
    public var gray100:                   Color { Color(hex: "F5F5F5") }
    public var gray200:                   Color { Color(hex: "E0E0E0") }
    public var gray300:                   Color { Color(hex: "9E9E9E") }
    public var gray400:                   Color { Color(hex: "616161") }
    public var gray500:                   Color { Color(hex: "424242") }
    
    public var baseBlack:                 Color { Color(hex: "000000") }
    public var baseWhite:                 Color { Color(hex: "FFFFFF") }
}

public protocol DSTextColorPalette {
    associatedtype ColorPalette: DSColorPalette
    var palette: ColorPalette { get }
    var primary:     Color { get }
    var secondary:   Color { get }
    var tertiary:    Color { get }
    var brand:       Color { get }
    var disabled:    Color { get }
    var placeholder: Color { get }
    var inverse:     Color { get }
    var error:       Color { get }
}

public protocol DSBorderColorPalette {
    associatedtype ColorPalette: DSColorPalette
    var palette: ColorPalette { get }
    var focused:     Color { get }
    var subtle:      Color { get }
    var active:      Color { get }
    var disabled:    Color { get }
    var inverse:     Color { get }
    var error:       Color { get }
    var dark:        Color { get }
}

public protocol DSButtonColorPalette {
    associatedtype ColorPalette: DSColorPalette
    var palette: ColorPalette { get }
    var primary:         Color { get }
    var primaryText:     Color { get }
    var secondary:       Color { get }
    var secondaryText:   Color { get }
    var disabled:        Color { get }
    var disabledText:    Color { get }
    var outline:         Color { get }
    var outlineText:     Color { get }
    var outlineBorder:   Color { get }
    var linkText:        Color { get }
    var brandLinkText:   Color { get }
    var destructive:     Color { get }
    var destructiveText: Color { get }
}

public protocol DSBackgroundColorPalette {
    associatedtype ColorPalette: DSColorPalette
    var palette: ColorPalette { get }
    var primary:          Color { get }
    var secondary:        Color { get }
    var tertiary:         Color { get }
    var secondaryInverse: Color { get }
    var tertiaryInverse:  Color { get }
    var inverse:          Color { get }
    var brand:            Color { get }
    var brandInverse:     Color { get }
}


// MARK: - Default Color Palette

@MainActor
public struct DefaultColorPalette: @MainActor DSColorPalette {
    public static let `default` = DefaultColorPalette()
    
    public let brandPrimary = Color(
        light: Color(hex: "#EF505F"),
        dark: Color(hex: "#EF505F")
    )

    public let brandSecondary = Color(
        light: Color(hex: "#BD3844"),
        dark: Color(hex: "#BD3844")
    )

    public let brandTertiary = Color(
        light: Color(hex: "#F1929B"),
        dark: Color(hex: "#F1929B")
    )

    public let brandAccent = Color(
        light: Color(hex: "#F9B9BF"),
        dark: Color(hex: "#F9B9BF")
    )


    // MARK: - Semantic Colors
    public let semanticError = Color(
        light: Color(hex: "#FF0101"),
        dark: Color(hex: "#FF0101")
    )

    public let semanticSuccess = Color(
        light: Color(hex: "#3ABB8B"),
        dark: Color(hex: "#3ABB8B")
    )

    public let semanticWarning = Color(
        light: Color(hex: "#F9B9BF"), // fallback (not explicitly defined)
        dark: Color(hex: "#F9B9BF")
    )

    public let semanticInfo = Color(
        light: Color(hex: "#6B7280"), // fallback neutral
        dark: Color(hex: "#6B7280")
    )

    public let semanticBlue = Color(
        light: Color(hex: "#6B7280"), // fallback neutral
        dark: Color(hex: "#6B7280")
    )


    // MARK: - Neutral Colors
    public let neutralWhite = Color(
        light: Color(hex: "FFFFFF"),
        dark: Color(hex: "FFFFFF")
    )

    public let neutralBlack = Color(
        light: Color(hex: "1A1A1A"),
        dark: Color(hex: "1A1A1A")
    )

    public let gray100 = Color(
        light: Color(hex: "F3F3F9"),
        dark: Color(hex: "F3F3F9")
    )

    public let gray200 = Color(
        light: Color(hex: "F3F4F6"),
        dark: Color(hex: "F3F4F6")
    )

    public let gray300 = Color(
        light: Color(hex: "D4D4D4"),
        dark: Color(hex: "D4D4D4")
    )

    public let gray400 = Color(
        light: Color(hex: "6B7280"),
        dark: Color(hex: "6B7280")
    )
    
    public let gray500 = Color(
        light: Color(hex: "374151"),
        dark: Color(hex: "374151")
    )


    // MARK: - Base Colors
    public let baseGrayPrimary = Color(
        light: Color(hex: "595959"),
        dark: Color(hex: "595959")
    )

    public let baseGraySecondary = Color(
        light: Color(hex: "B2B2B2"),
        dark: Color(hex: "B2B2B2")
    )
    
    public let baseBlack = Color(
        light: Color(hex: "000000"),
        dark: Color(hex: "000000")
    )
    
    public let baseWhite = Color(
        light: Color(hex: "FFFFFF"),
        dark: Color(hex: "FFFFFF")
    )
    
    public let background: Background = .default
    public let border: Border = .default
    public let button: Button = .default
    public let text: Text = .default
    
    @MainActor
    public struct Background: @MainActor DSBackgroundColorPalette  {
        @MainActor public var palette: DefaultColorPalette { .default }
        public static let `default` = Background()
    }
    
    @MainActor
    public struct Button: @MainActor DSButtonColorPalette  {
        @MainActor public var palette: DefaultColorPalette { .default }
        public static let `default` = Button()
    }

    @MainActor
    public struct Border: @MainActor DSBorderColorPalette  {
        @MainActor public var palette: DefaultColorPalette { .default }
        public static let `default` = Border()
    }
    
    @MainActor
    public struct Text: @MainActor DSTextColorPalette  {
        @MainActor public var palette: DefaultColorPalette { .default }
        public static let `default` = Text()
    }

}
@MainActor
public struct DefaultColorPalette1: @MainActor DSColorPalette {

    // MARK: - Brand Colors
    public let brandPrimary: Color = Color(hex: "#FF1A1A")   // Main Red
    public let brandSecondary: Color = Color(hex: "#8B0000") // Dark Red
    public let brandTertiary: Color = Color(hex: "#E53E3E")  // Mid red
    public let brandAccent: Color = Color(hex: "#FFD600")    // Yellow


    // MARK: - Semantic Colors
    public let semanticError: Color = Color(hex: "#E53935")
    public let semanticSuccess: Color = Color(hex: "#10A05A")
    public let semanticWarning: Color = Color(hex: "#F4C430")
    public let semanticInfo: Color = Color(hex: "#5AC8FA")
    public let semanticBlue: Color = Color(hex: "#007AFF")

    // MARK: - Neutral Colors
    public let neutralWhite: Color = Color(hex: "#FFFFFF")
    public let neutralBlack: Color = Color(hex: "#1A1A1A")

    public let gray100: Color = Color(hex: "#F5F5F5") //g4
    public let gray200: Color = Color(hex: "#E0E0E0") //g3
    public let gray300: Color = Color(hex: "#C7C7CC") //g2
    public let gray400: Color = Color(hex: "#8E8E93") //g1

    // MARK: - Base Colors
    public let baseGrayPrimary: Color = Color(hex: "#1A1A1A")
    public let baseGraySecondary: Color = Color(hex: "#6E6E73")


    // MARK: - Default Instance
    public static let `default` = DefaultColorPalette()
    
    public var background: DefaultBackgroundColorPalette = .default
    public var border: DefaultBorderColorPalette = .default
    public var button: DefaultButtonColorPalette = .default
    public var text: DefaultTextColorPalette = .default
}

@MainActor
public struct DefaultButtonColorPalette: @MainActor DSButtonColorPalette  {
    @MainActor public var palette: DefaultColorPalette { .default }
    public static let `default` = DefaultButtonColorPalette()
}

@MainActor
public struct DefaultTextColorPalette: @MainActor DSTextColorPalette  {
    @MainActor public var palette: DefaultColorPalette { .default }
    public static let `default` = DefaultTextColorPalette()
}

@MainActor
public struct DefaultBackgroundColorPalette: @MainActor DSBackgroundColorPalette  {
    @MainActor public var palette: DefaultColorPalette { .default }
    public static let `default` = DefaultBackgroundColorPalette()
}

@MainActor
public struct DefaultBorderColorPalette: @MainActor DSBorderColorPalette  {
    @MainActor public var palette: DefaultColorPalette { .default }
    public static let `default` = DefaultBorderColorPalette()
}

@MainActor
extension DSTextColorPalette {
       
    public var brand: Color {
        Color(light: palette.brandPrimary, dark: palette.brandPrimary)
    }
    
    public var primary: Color {
        Color(light: palette.baseBlack, dark: palette.baseWhite)
    }
    
    public var secondary: Color {
        Color(light: palette.gray400, dark: palette.gray100)
    }
    
    public var tertiary: Color {
        Color(light: palette.baseGrayPrimary, dark: palette.baseGraySecondary)
    }
    
    public var disabled: Color {
        Color(light: palette.baseGrayPrimary, dark: palette.baseGraySecondary)
    }
    
    public var placeholder: Color {
        Color(light: palette.gray400, dark: palette.gray100)
    }
    
    public var inverse: Color {
        Color(light: palette.baseWhite, dark: palette.baseBlack)
    }
    
    public var error: Color {
        Color(light: palette.semanticError, dark: palette.semanticError)
    }
}

@MainActor
extension DSButtonColorPalette  {
    public var primary: Color {
        Color(light: palette.brandPrimary, dark: palette.brandPrimary)
    }
    public var primaryText: Color {
        Color(light: palette.baseWhite, dark: palette.baseWhite)
    }
    public var secondary: Color {
        Color(light: palette.brandSecondary, dark: palette.brandSecondary)
    }
    public var secondaryText: Color {
        Color(light: palette.baseWhite, dark: palette.baseWhite)
    }
    public var disabled: Color {
        Color(light: palette.gray300, dark: palette.gray500)
    }
    public var disabledText: Color {
        Color(light: palette.baseGrayPrimary, dark: palette.baseGraySecondary)
    }
    public var outline: Color {
        Color(light: palette.neutralWhite, dark: palette.neutralBlack)
    }
    public var outlineText: Color {
        Color(light: palette.neutralBlack, dark: palette.neutralWhite)
    }
    public var outlineBorder: Color {
        Color(light: palette.neutralBlack, dark: palette.gray500)
    }
    public var linkText: Color {
        Color(light: palette.neutralBlack, dark: palette.neutralWhite)
    }
    public var brandLinkText: Color {
        Color(light: palette.brandSecondary, dark: palette.brandSecondary)
    }
    public var destructive: Color {
        Color(light: palette.semanticError, dark: palette.semanticError)
    }
    public var destructiveText: Color {
        Color(light: palette.neutralWhite, dark: palette.neutralWhite)
    }
}

@MainActor
extension DSBorderColorPalette {
    public var dark: Color {
        Color(light: palette.baseBlack, dark: palette.baseWhite)
    }
    
    public var focused: Color {
        Color(light: palette.baseBlack, dark: palette.baseWhite)
    }
    
    public var subtle: Color {
        Color(light: palette.gray300, dark: palette.gray400)
    }
    
    public var disabled: Color {
        Color(light: palette.baseGrayPrimary, dark: palette.baseGraySecondary)
    }
    
    public var placeholder: Color {
        Color(light: palette.gray400, dark: palette.gray100)
    }
    
    public var inverse: Color {
        Color(light: palette.baseWhite, dark: palette.baseBlack)
    }

    public var active: Color {
        Color(light: palette.brandPrimary, dark: palette.brandPrimary)
    }
    
    public var error: Color {
        Color(light: palette.semanticError, dark: palette.semanticError)
    }
}

@MainActor
extension DSBackgroundColorPalette {
    public var primary: Color {
        Color(light: palette.neutralWhite, dark: palette.neutralBlack)
    }
    
    public var secondary: Color {
        Color(light: palette.gray200, dark: palette.gray400)
    }
    
    public var tertiary: Color {
        Color(light: palette.baseGraySecondary, dark: palette.baseGrayPrimary)
    }
    
    public var secondaryInverse: Color {
        Color(light: palette.gray400, dark: palette.gray200)
    }
    
    public var tertiaryInverse: Color {
        Color(light: palette.baseGrayPrimary, dark: palette.baseGraySecondary)
    }
    
    public var inverse: Color {
        Color(light: palette.neutralBlack, dark: palette.neutralWhite)
    }
    
    public var brand: Color {
        Color(light: palette.brandPrimary, dark: palette.brandSecondary)
    }
    
    public var brandInverse: Color {
        Color(light: palette.brandSecondary, dark: palette.brandPrimary)
    }
}



// MARK: - Typography Scale Protocol
public protocol DSTypographyScale {
    var fontFamily: String? { get }

    // Font Sizes
    var largeTitle: CGFloat { get }
    var title:  CGFloat { get }
    var title1: CGFloat { get }
    var title2: CGFloat { get }
    var title3: CGFloat { get }
    var headline: CGFloat { get }
    var subheadline: CGFloat { get }
    var body: CGFloat { get }
    var bodyMedium: CGFloat { get }
    var bodySmall: CGFloat { get }
    var caption: CGFloat { get }
    var caption2: CGFloat { get }
    var caption3: CGFloat { get }

    // Font Weights
    func font(size: CGFloat, weight: Font.Weight) -> Font
}

extension DSTypographyScale {
    var largeTitle: CGFloat { 34 }
    var title: CGFloat { 26 }
    var title1: CGFloat { 24 }
    var title2: CGFloat { 22 }
    var title3: CGFloat { 20 }
    var headline: CGFloat { 17 }
    var subheadline: CGFloat { 17 }
    var body: CGFloat { 17 }
    var bodyMedium: CGFloat { 15 }
    var bodySmall: CGFloat { 13 }
    var caption: CGFloat { 12 }
    var caption2: CGFloat { 11 }
    var caption3: CGFloat { 10 }
    
    public func font(size: CGFloat, weight: Font.Weight) -> Font {
        guard let family = fontFamily else {
            return .system(size: size, weight: weight)
        }

        let name = mapToFontName(family: family, weight: weight) // e.g. "Inter-SemiBold"
        return .custom(name, size: size)
    }

    private func mapToFontName(family: String, weight: Font.Weight) -> String {
        // Example for Inter — adjust to your actual PostScript names in the bundle
        switch weight {
        case .ultraLight, .thin: return "\(family)-Thin"
        case .light: return "\(family)-Light"
        case .regular: 
            return "\(family)-Regular"
        case .medium: return "\(family)-Medium"
        case .semibold: return "\(family)-SemiBold"
        case .bold: return "\(family)-Bold"
        case .heavy, .black: return "\(family)-Black"
        default: 
            return "\(family)-Regular"
        }
    }
}

// MARK: - Default Typography Scale
@MainActor
public struct DefaultTypographyScale: DSTypographyScale {
    public var fontFamily: String?

    public var largeTitle: CGFloat
    public var title:  CGFloat
    public var title1: CGFloat
    public var title2: CGFloat
    public var title3: CGFloat
    public var headline: CGFloat
    public var subheadline: CGFloat
    public var body: CGFloat
    public var bodyMedium: CGFloat
    public var bodySmall: CGFloat
    public var bodySmallRegular: CGFloat
    public var caption: CGFloat
    public var caption2: CGFloat
    public var caption3: CGFloat

    public init(
        fontFamily: String? = nil,
        largeTitle: CGFloat = 40,
        title: CGFloat = 24,
        title1: CGFloat = 24,
        title2: CGFloat = 20,
        title3: CGFloat = 18,
        headline: CGFloat = 18,
        subheadline: CGFloat = 16,
        body: CGFloat = 16,
        bodyMedium: CGFloat = 14,
        bodySmall: CGFloat = 14,
        bodySmallRegular: CGFloat = 14,
        caption: CGFloat = 12,
        caption2: CGFloat = 11,
        caption3: CGFloat = 10
    ) {
        self.fontFamily = fontFamily
        self.largeTitle = largeTitle
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.subheadline = subheadline
        self.body = body
        self.bodyMedium = bodyMedium
        self.bodySmall = bodySmall
        self.caption = caption
        self.caption2 = caption2
        self.title = title
        self.bodySmallRegular = bodySmallRegular
        self.caption3 = caption3
    }

    public static let `default` = DefaultTypographyScale()
}

// MARK: - Theme Protocol
@MainActor
public protocol DSTheme {
    associatedtype ColorPalette: DSColorPalette
    var colors: ColorPalette { get }
    var typography: DSTypographyScale { get }
    var name: String { get }
}

// MARK: - Default Theme
@MainActor
public struct DefaultTheme: @MainActor DSTheme {
    public var colors: DefaultColorPalette
    public var typography: DSTypographyScale
    public var name: String

    public init(
        name: String = "Default",
        colors: DefaultColorPalette = .default,
        typography: DSTypographyScale = DefaultTypographyScale.default
    ) {
        self.name = name
        self.colors = colors
        self.typography = typography
    }

    public static let `default` = DefaultTheme()
}

// MARK: - Design System Manager
@MainActor
public class DesignSystem: ObservableObject {
    @MainActor
    public static let shared = DesignSystem()

    @Published public var currentTheme: DSTheme

    private init() {
        self.currentTheme = DefaultTheme()
    }

    /// Configure the design system with a custom theme
    @MainActor
    public static func configure(theme: DSTheme) {
        shared.currentTheme = theme
    }

    /// Get the current theme
    @MainActor
    public static var theme: DSTheme {
        shared.currentTheme
    }
}

// MARK: - SwiftUI Environment Support
@MainActor
private struct DSThemeKey: @MainActor EnvironmentKey {
    static let defaultValue: DSTheme? = nil
}

@MainActor
public extension EnvironmentValues {
    var designSystemTheme: DSTheme? {
        get { self[DSThemeKey.self] }
        set { self[DSThemeKey.self] = newValue }
    }
}

// MARK: - View Extension for Theme Access
public extension View {
    /// Apply a custom theme to this view and its children
    func designSystemTheme(_ theme: DSTheme) -> some View {
        self.environment(\.designSystemTheme, theme)
    }
}

// MARK: - Theme Accessor
/// Helper to access the current theme (environment first, then global)
@MainActor
struct ThemeAccessor {
    @Environment(\.designSystemTheme) private var envTheme

    @MainActor
    var theme: DSTheme {
        envTheme ?? DesignSystem.theme
    }
}

public extension Color {
    public func uiColor() -> UIColor {
        UIColor(self)
    }
}
