//
//  DSColorScale.swift
//  RWLDesignSystem
//
//  A 50–900 tonal scale for one color family (Primary, Neutral, Error, …).
//
//  The dark-mode scale is the light scale inverted (50 is the darkest surface, 900 the
//  lightest foreground) with 500 kept as the shared base. Because of that, a role mapped to
//  a step — e.g. text on neutral 900 — reads correctly in both modes.
//
//  How to read the scale:
//    50–200   surfaces, cards, containers
//    300–400  borders, dividers, subtle UI
//    500      usually the base (see `base`), same in light and dark
//    600–700  interactive states, hover, icons
//    800–900  text, labels, high-contrast foreground
//

import SwiftUI

public protocol DSColorScale: Sendable {
    var shade50:  Color { get }
    var shade100: Color { get }
    var shade200: Color { get }
    var shade300: Color { get }
    var shade400: Color { get }
    var shade500: Color { get }
    var shade600: Color { get }
    var shade700: Color { get }
    var shade800: Color { get }
    var shade900: Color { get }

    /// The family's base color, used for brand fills, semantic colors and other "main"
    /// uses of the family. Usually the 500 step, which is the default.
    var base: Color { get }
}

public extension DSColorScale {
    var base: Color { shade500 }
}

// MARK: - Fixed Scale
/// A scale for a single appearance. Pair two of them with `DSAdaptiveColorScale`.
public struct DSStaticColorScale: DSColorScale {
    public let shade50:  Color
    public let shade100: Color
    public let shade200: Color
    public let shade300: Color
    public let shade400: Color
    public let shade500: Color
    public let shade600: Color
    public let shade700: Color
    public let shade800: Color
    public let shade900: Color
    public let base:     Color

    /// `base` defaults to `shade500`.
    public init(
        shade50:  Color,
        shade100: Color,
        shade200: Color,
        shade300: Color,
        shade400: Color,
        shade500: Color,
        shade600: Color,
        shade700: Color,
        shade800: Color,
        shade900: Color,
        base:     Color? = nil
    ) {
        self.shade50  = shade50
        self.shade100 = shade100
        self.shade200 = shade200
        self.shade300 = shade300
        self.shade400 = shade400
        self.shade500 = shade500
        self.shade600 = shade600
        self.shade700 = shade700
        self.shade800 = shade800
        self.shade900 = shade900
        self.base     = base ?? shade500
    }
}

// MARK: - Adaptive Scale
/// Resolves each step to the light or dark scale depending on the current appearance.
public struct DSAdaptiveColorScale: DSColorScale {
    public let light: any DSColorScale
    public let dark:  any DSColorScale

    public init(light: any DSColorScale, dark: any DSColorScale) {
        self.light = light
        self.dark = dark
    }

    public var shade50:  Color { Color(light: light.shade50,  dark: dark.shade50)  }
    public var shade100: Color { Color(light: light.shade100, dark: dark.shade100) }
    public var shade200: Color { Color(light: light.shade200, dark: dark.shade200) }
    public var shade300: Color { Color(light: light.shade300, dark: dark.shade300) }
    public var shade400: Color { Color(light: light.shade400, dark: dark.shade400) }
    public var shade500: Color { Color(light: light.shade500, dark: dark.shade500) }
    public var shade600: Color { Color(light: light.shade600, dark: dark.shade600) }
    public var shade700: Color { Color(light: light.shade700, dark: dark.shade700) }
    public var shade800: Color { Color(light: light.shade800, dark: dark.shade800) }
    public var shade900: Color { Color(light: light.shade900, dark: dark.shade900) }
    public var base:     Color { Color(light: light.base,     dark: dark.base)     }
}

// MARK: - Generated Scale
/// Approximates an adaptive scale from a single base color by tinting toward white and
/// shading toward black. Used for the fallback palette and for quick prototyping.
public struct DSGeneratedColorScale: DSColorScale {
    public let base: Color

    public init(base: Color) {
        self.base = base
    }

    /// `step` runs from -5 (50) to +4 (900) around the 500 base.
    private func shade(_ step: Int) -> Color {
        Color(light: tone(step), dark: tone(-step))
    }

    private func tone(_ step: Int) -> Color {
        switch step {
        case ..<0: base.mix(with: .white, by: Double(-step) * 0.18)
        case 0:    base
        default:   base.mix(with: .black, by: Double(step) * 0.17)
        }
    }

    public var shade50:  Color { shade(-5) }
    public var shade100: Color { shade(-4) }
    public var shade200: Color { shade(-3) }
    public var shade300: Color { shade(-2) }
    public var shade400: Color { shade(-1) }
    public var shade500: Color { base }
    public var shade600: Color { shade(1) }
    public var shade700: Color { shade(2) }
    public var shade800: Color { shade(3) }
    public var shade900: Color { shade(4) }
}
