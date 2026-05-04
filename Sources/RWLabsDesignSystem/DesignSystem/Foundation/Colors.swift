//
//  Colors.swift
//  RWLDesignSystem
//
//  Design system color tokens
//

import SwiftUI

// MARK: - Color Extension for Hex Support
public extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Create an adaptive color that changes between light and dark mode
    public init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(dynamicProvider: { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        }))
    }
}

// MARK: - Design System Colors (Theme-Aware)
public extension Color {

    // MARK: - Brand Colors
    @MainActor
    private struct Brand {
        public static var primary:   Color { DesignSystem.theme.colors.brandPrimary }
        public static var secondary: Color { DesignSystem.theme.colors.brandSecondary }
        public static var tertiary:  Color { DesignSystem.theme.colors.brandTertiary }
        public static var accent:    Color { DesignSystem.theme.colors.brandAccent }
    }

    // MARK: - Semantic Colors
    @MainActor
    public struct Semantic {
        public static var error:   Color { DesignSystem.theme.colors.semanticError }
        public static var success: Color { DesignSystem.theme.colors.semanticSuccess }
        public static var warning: Color { DesignSystem.theme.colors.semanticWarning }
        public static var info:    Color { DesignSystem.theme.colors.semanticInfo }
        public static var blue:    Color { DesignSystem.theme.colors.semanticBlue }
    }

    // MARK: - Neutral Colors
    @MainActor
    private struct Neutral {
        public static var white:         Color { DesignSystem.theme.colors.neutralWhite }
        public static var black:         Color { DesignSystem.theme.colors.neutralBlack }
        public static var grayPrimary:   Color { DesignSystem.theme.colors.baseGrayPrimary }
        public static var graySecondary: Color { DesignSystem.theme.colors.baseGraySecondary }
        public static var gray100:       Color { DesignSystem.theme.colors.gray100 }
        public static var gray200:       Color { DesignSystem.theme.colors.gray200 }
        public static var gray300:       Color { DesignSystem.theme.colors.gray300 }
        public static var gray400:       Color { DesignSystem.theme.colors.gray400 }
        public static var gray500:       Color { DesignSystem.theme.colors.gray500 }
    }
    // MARK: - Convenience Aliases (Adaptive for Dark Mode)
    @MainActor
    public struct Text {
        public static var brand:       Color { DesignSystem.theme.colors.text.brand       }
        public static var primary:     Color { DesignSystem.theme.colors.text.primary     }
        public static var secondary:   Color { DesignSystem.theme.colors.text.secondary   }
        public static var tertiary:    Color { DesignSystem.theme.colors.text.tertiary    }
        public static var disabled:    Color { DesignSystem.theme.colors.text.disabled    }
        public static var inverse:     Color { DesignSystem.theme.colors.text.inverse     }
        public static var placeholder: Color { DesignSystem.theme.colors.text.placeholder }
        public static var error:       Color { DesignSystem.theme.colors.text.error       }
        public static var white:       Color { DesignSystem.theme.colors.neutralWhite     }
        public static var black:       Color { DesignSystem.theme.colors.neutralBlack     }
    }

    @MainActor
    public struct Background {
        public static var primary:             Color { DesignSystem.theme.colors.background.primary             }
        public static var secondary:           Color { DesignSystem.theme.colors.background.secondary           }
        public static var tertiary:            Color { DesignSystem.theme.colors.background.tertiary            }
        public static var secondaryInverse:    Color { DesignSystem.theme.colors.background.secondaryInverse    }
        public static var tertiaryInverse:     Color { DesignSystem.theme.colors.background.tertiaryInverse     }
        public static var inverse:             Color { DesignSystem.theme.colors.background.inverse             }
        public static var brand:               Color { DesignSystem.theme.colors.background.brand               }
        public static var brandInverse:        Color { DesignSystem.theme.colors.background.brandInverse        }
    }

    @MainActor
    public struct Border {
        public static var `default`:    Color { DesignSystem.theme.colors.border.subtle }
        public static var dark :        Color { DesignSystem.theme.colors.border.focused }
        public static var focused:      Color { DesignSystem.theme.colors.border.focused }
        public static var subtle:       Color { DesignSystem.theme.colors.border.subtle }
        public static var inverse:      Color { DesignSystem.theme.colors.border.inverse }
        public static var disabled:     Color { DesignSystem.theme.colors.border.disabled }
        public static var placeholder:  Color { DesignSystem.theme.colors.border.placeholder }
        public static var active:       Color { DesignSystem.theme.colors.border.active }
        public static var error:        Color { DesignSystem.theme.colors.border.error }
    }
    
    @MainActor
    public struct Button {
        public static var primary:         Color { DesignSystem.theme.colors.button.primary }
        public static var primaryText:     Color { DesignSystem.theme.colors.button.primaryText }
        public static var secondary:       Color { DesignSystem.theme.colors.button.secondary }
        public static var secondaryText:   Color { DesignSystem.theme.colors.button.secondaryText }
        public static var disabled:        Color { DesignSystem.theme.colors.button.disabled }
        public static var disabledText:    Color { DesignSystem.theme.colors.button.disabledText }
        public static var destructive:     Color { DesignSystem.theme.colors.button.destructive }
        public static var destructiveText: Color { DesignSystem.theme.colors.button.destructiveText }
        public static var outline:         Color { DesignSystem.theme.colors.button.outline }
        public static var outlineText:     Color { DesignSystem.theme.colors.button.outlineText }
        public static var outlineBorder:   Color { DesignSystem.theme.colors.button.outlineBorder }
        public static var linkText:        Color { DesignSystem.theme.colors.button.linkText }
        public static var brandLinkText:   Color { DesignSystem.theme.colors.button.brandLinkText }
    }
    
    @MainActor
    public struct Icon {
        public static var primary:        Color { Color(light: DesignSystem.theme.colors.neutralWhite, dark: DesignSystem.theme.colors.neutralBlack) }
        public static var secondary:      Color { Color(light: DesignSystem.theme.colors.baseGrayPrimary, dark: DesignSystem.theme.colors.baseGraySecondary)  }
        public static var inverse:        Color { Color(light: DesignSystem.theme.colors.neutralBlack, dark: DesignSystem.theme.colors.neutralWhite) }
        public static var brand:          Color { Color(light: DesignSystem.theme.colors.brandPrimary, dark: DesignSystem.theme.colors.brandPrimary) }
        public static var brandSecondary: Color { Color(light: DesignSystem.theme.colors.brandSecondary, dark: DesignSystem.theme.colors.brandSecondary) }
        public static var brandTertiary:  Color { Color(light: DesignSystem.theme.colors.brandTertiary, dark: DesignSystem.theme.colors.brandTertiary) }
        public static var brandAccent:    Color { Color(light: DesignSystem.theme.colors.brandAccent, dark: DesignSystem.theme.colors.brandAccent) }
        public static var placeholder:    Color { Color(light: DesignSystem.theme.colors.gray400, dark: DesignSystem.theme.colors.gray100) }
        public static var white:          Color { DesignSystem.theme.colors.neutralWhite     }
        public static var black:          Color { DesignSystem.theme.colors.neutralBlack     }

    }
    
    @MainActor
    public struct Shadow {
        public static var primary: Color { Color(light: DesignSystem.theme.colors.baseBlack, dark: DesignSystem.theme.colors.neutralBlack) }
    }
}

@MainActor
public extension Color {
    public static var brand:   Color { .Brand.primary    }
    public static var success: Color { .Semantic.success }
    public static var error:   Color { .Semantic.error   }
    public static var text:    Color { .Text.primary     }
}
