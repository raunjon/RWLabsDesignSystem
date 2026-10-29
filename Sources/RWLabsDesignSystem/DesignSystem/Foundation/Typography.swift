//
//  Typography.swift
//  RWLDesignSystem
//
//  Typography tokens matching the Figma type scale (Headings, Body, Labels).
//
//  The design system renders text in the system font. An app swaps the font by giving its
//  theme a different `DSTypographyScale`, either `DSCustomFontTypography(family:)` for a
//  bundled font family or its own conformance:
//
//  DesignSystem.configure(typography: DSCustomFontTypography(family: "Inter"))
//
//  Usage:
//  - `Text("Hello").typography(.heading2)` applies font, letter spacing, line height and color
//  - `Text("Hello").fontStyle(.body)` applies font, letter spacing and line height only
//

import SwiftUI

// MARK: - Text Metrics
/// Size, weight and spacing for one text style.
public struct DSTextMetrics: Sendable, Equatable {
    public var size:          CGFloat
    public var weight:        Font.Weight
    public var lineHeight:    CGFloat
    public var letterSpacing: CGFloat

    public init(size: CGFloat, weight: Font.Weight, lineHeight: CGFloat, letterSpacing: CGFloat = -0.15) {
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}

// MARK: - Typography Scale Protocol
/// Supplies the fonts and metrics behind every `DSTypography.Style`.
/// Both requirements have defaults: the system font and the Figma metrics.
public protocol DSTypographyScale: Sendable {
    /// The font for a size and weight. Defaults to the system font.
    func uiFont(size: CGFloat, weight: Font.Weight) -> UIFont

    /// Size, weight, line height and letter spacing for a style. Defaults to the Figma scale.
    func metrics(for style: DSTypography.Style) -> DSTextMetrics
}

public extension DSTypographyScale {
    func uiFont(size: CGFloat, weight: Font.Weight) -> UIFont {
        .systemFont(ofSize: size, weight: weight.uiFontWeight)
    }

    func metrics(for style: DSTypography.Style) -> DSTextMetrics {
        style.defaultMetrics
    }

    func uiFont(for style: DSTypography.Style) -> UIFont {
        let metrics = metrics(for: style)
        return uiFont(size: metrics.size, weight: metrics.weight)
    }

    func font(for style: DSTypography.Style) -> Font {
        Font(uiFont(for: style))
    }
}

// MARK: - System Typography
/// The default: system font with the Figma metrics.
public struct DSSystemTypography: DSTypographyScale {
    public static let `default` = DSSystemTypography()

    public init() {}
}

// MARK: - Custom Font Typography
/// A bundled font family, resolved as `<family>-<Weight>` PostScript names
/// (e.g. "Inter-SemiBold"). Falls back to the system font when a face is missing.
public struct DSCustomFontTypography: DSTypographyScale {
    public let family: String

    public init(family: String) {
        self.family = family
    }

    public func uiFont(size: CGFloat, weight: Font.Weight) -> UIFont {
        UIFont(name: "\(family)-\(weight.postScriptSuffix)", size: size)
            ?? .systemFont(ofSize: size, weight: weight.uiFontWeight)
    }
}

// MARK: - Typography Styles
public struct DSTypography {

    /// The Figma type scale. Names match Figma's dev mode.
    public enum Style: String, CaseIterable, Sendable {
        /// Heading 1: 40px SemiBold
        case heading1
        /// Heading 2: 24px SemiBold
        case heading2
        /// Heading 3: 20px SemiBold
        case heading3
        /// Body Medium 16: 16px Medium
        case bodyMedium
        /// Body Regular 16: 16px Regular
        case body
        /// Body Medium 14: 14px Medium
        case bodySmallMedium
        /// Body Regular 14: 14px Regular
        case bodySmall
        /// Label: 12px Regular
        case label
        /// Body Medium 12: 12px SemiBold (chat list unread previews)
        case labelMedium
        /// Label 10px: 10px Regular (timestamps, nav bar titles)
        case caption

        /// Metrics from Figma. Heading 1 uses a 48px line height; Figma's 20px would make
        /// multi-line headings overlap.
        public var defaultMetrics: DSTextMetrics {
            switch self {
            case .heading1:        DSTextMetrics(size: 40, weight: .semibold, lineHeight: 48)
            case .heading2:        DSTextMetrics(size: 24, weight: .semibold, lineHeight: 25)
            case .heading3:        DSTextMetrics(size: 20, weight: .semibold, lineHeight: 20)
            case .bodyMedium:      DSTextMetrics(size: 16, weight: .medium,   lineHeight: 25)
            case .body:            DSTextMetrics(size: 16, weight: .regular,  lineHeight: 24)
            case .bodySmallMedium: DSTextMetrics(size: 14, weight: .medium,   lineHeight: 20)
            case .bodySmall:       DSTextMetrics(size: 14, weight: .regular,  lineHeight: 22)
            case .label:           DSTextMetrics(size: 12, weight: .regular,  lineHeight: 20)
            case .labelMedium:     DSTextMetrics(size: 12, weight: .semibold, lineHeight: 20)
            case .caption:         DSTextMetrics(size: 10, weight: .regular,  lineHeight: 20)
            }
        }

        @MainActor
        public var metrics: DSTextMetrics {
            DesignSystem.theme.typography.metrics(for: self)
        }

        @MainActor
        public var font: Font {
            DesignSystem.theme.typography.font(for: self)
        }

        /// Extra spacing between lines so the rendered line height matches `metrics.lineHeight`.
        @MainActor
        var lineSpacing: CGFloat {
            max(0, metrics.lineHeight - DesignSystem.theme.typography.uiFont(for: self).lineHeight)
        }
    }
}

// MARK: - View Extension for Typography
public extension View {
    /// Apply a style's font, letter spacing and line height.
    ///
    /// ```swift
    /// Text("Hello World")
    ///     .fontStyle(.heading2)
    /// ```
    @MainActor
    func fontStyle(_ style: DSTypography.Style) -> some View {
        self
            .font(style.font)
            .tracking(style.metrics.letterSpacing)
            .lineSpacing(style.lineSpacing)
    }

    /// Apply a style plus a text color (defaults to `Color.Text.primary`).
    ///
    /// ```swift
    /// Text("Body text")
    ///     .typography(.body, color: .Text.secondary)
    /// ```
    @MainActor
    func typography(_ style: DSTypography.Style, color: Color? = nil) -> some View {
        self
            .fontStyle(style)
            .foregroundColor(color ?? Color.Text.primary)
    }
}

// MARK: - Weight Mapping
extension Font.Weight {
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin:       .thin
        case .light:      .light
        case .medium:     .medium
        case .semibold:   .semibold
        case .bold:       .bold
        case .heavy:      .heavy
        case .black:      .black
        default:          .regular
        }
    }

    var postScriptSuffix: String {
        switch self {
        case .ultraLight: "ExtraLight"
        case .thin:       "Thin"
        case .light:      "Light"
        case .medium:     "Medium"
        case .semibold:   "SemiBold"
        case .bold:       "Bold"
        case .heavy:      "ExtraBold"
        case .black:      "Black"
        default:          "Regular"
        }
    }
}
