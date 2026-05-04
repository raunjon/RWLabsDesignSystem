//
//  Typography.swift
//  RWLDesignSystem
//
//  Design system typography tokens with theme-aware sizing and weight management.
//  Provides predefined font styles, helper methods, and view extensions for consistent
//  typography across the application.
//
//  Usage:
//  - Use .fontStyle(.title) on Text views for clean, theme-aware typography
//  - Access helper methods like DSTypography.body for font properties
//  - All styles automatically respect the configured theme's font family and sizing
//

import SwiftUI

// MARK: - Typography System (Theme-Aware)
/// Central typography system providing theme-aware font styles, weights, and sizing.
/// All typography is automatically calculated based on the current design system theme,
/// ensuring consistency across the application and supporting dynamic type scaling.
public struct DSTypography {

    // MARK: - Font Weights
    /// Standard font weight options matching SwiftUI Font.Weight values
    public enum FontWeight {
        /// Regular weight (400) - default text weight
        case regular
        /// Medium weight (500) - slightly heavier than regular
        case medium
        /// SemiBold weight (600) - emphasized text
        case semibold
        /// Bold weight (700) - strong emphasis
        case bold

        var value: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }

    // MARK: - Font Styles (Typography Scale)
    /// Predefined typography styles for consistent text hierarchy across the application.
    /// Each style defines a specific size, weight combination and is theme-aware.
    /// Use .fontStyle(_:) extension on View for easy application.
    public enum Style: String {
        /// Large display heading - 40px, Bold weight
        case largeTitle
        /// Main heading - 24px, Bold weight
        case title
        /// Title level 1 - 24px, Semibold weight
        case title1
        /// Title level 2 - 20px, SemiBold weight
        case title2
        /// Title level 3 - 18px, SemiBold weight
        case title3
        /// Title level 4 - 18px, Regular weight
        case title4
        /// Subheading - 18px, Bold weight
        case headline
        /// Bold subheading - 16px, SemiBold weight
        case subheadiline
        /// Body text - 16px, Regular weight - use for main content
        case body
        /// Body medium - 16px, Medium weight
        case bodyMedium
        /// Small body text - 14px, Medium weight
        case bodySmall
        /// Small body text - 14px, Regular weight
        case bodySmallRegular
        /// Caption text - 12px, Regular weight - use for secondary text
        case caption
        /// Small caption - 11px, Regular weight - use for helper text
        case caption2
        /// Caption 3 - 10px, Regular weight - use for helper text
        case caption3
        /// CaptionSemi - 12px, SemiBold weight - use for helper text
        case captionSemi
        /// Caption3Semi - 10px, SemiBold weight - use for helper text
        case caption3Semi
        
        @MainActor
        public var font: Font {
            let typography = DesignSystem.theme.typography

            switch self {
            case .largeTitle:
                return typography.font(size: typography.largeTitle, weight: .heavy)
            case .title:
                return typography.font(size: typography.title, weight: .bold)
            case .title1:
                return typography.font(size: typography.title1, weight: .semibold)
            case .title2:
                return typography.font(size: typography.title2, weight: .semibold)
            case .title3:
                return typography.font(size: typography.title3, weight: .semibold)
            case .title4:
                return typography.font(size: typography.title3, weight: .semibold)
            case .headline:
                return typography.font(size: typography.headline, weight: .bold)
            case .subheadiline:
                return typography.font(size: typography.subheadline, weight: .semibold)
            case .body:
                return typography.font(size: typography.body, weight: .regular)
            case .bodyMedium:
                return typography.font(size: typography.bodyMedium, weight: .medium)
            case .bodySmall:
                return typography.font(size: typography.bodySmall, weight: .medium)
            case .bodySmallRegular:
                return typography.font(size: typography.bodySmall, weight: .regular)
            case .caption:
                return typography.font(size: typography.caption, weight: .regular)
            case .caption2:
                return typography.font(size: typography.caption2, weight: .regular)
            case .caption3:
                return typography.font(size: typography.caption3, weight: .regular)
            case .caption3Semi:
                return typography.font(size: typography.caption3, weight: .semibold)
            case .captionSemi:
                return typography.font(size: typography.caption, weight: .semibold)
            }
        }

        @MainActor
        var lineHeight: CGFloat {
            let typography = DesignSystem.theme.typography

            switch self {
            case .largeTitle: return typography.largeTitle * 1.2
            case .title, .title1: return typography.title1 * 1.2
            case .title2: return typography.title2 * 1.3
            case .title3, .title4: return typography.title3 * 1.25
            case .headline, .subheadiline: return typography.headline * 1.3
            case .body: return typography.body * 1.3
            case .bodyMedium: return typography.bodyMedium * 1.3
            case .bodySmall, .bodySmallRegular: return typography.bodySmall * 1.4
            case .caption: return typography.caption * 1.3
            case .caption2, .captionSemi: return typography.caption2 * 1.2
            case .caption3, .caption3Semi: return typography.caption3 * 1.2
            }
        }
    }
}

// MARK: - View Extension for Typography
/// View extension providing easy access to typography styles.
/// Use .fontStyle() for quick font application, or typography() for full styling with color and line spacing.
public extension View {
    /// Apply a typography style to the view with font
    /// - Parameter style: The DSTypography.Style to apply (e.g., .title, .body, .caption)
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello World")
    ///     .fontStyle(.title)  // 24px, Bold weight
    /// ```
    @MainActor
    func fontStyle(_ style: DSTypography.Style) -> some View {
        self.font(style.font)
    }

    /// Apply a typography style with full styling including color and line spacing.
    /// Use this for comprehensive typography control with all design system properties.
    /// - Parameters:
    ///   - style: The DSTypography.Style to apply
    ///   - color: Optional text color (defaults to Text.primary from design system)
    ///
    /// Usage:
    /// ```swift
    /// Text("Body text")
    ///     .typography(.body, color: .red)
    /// ```
    @MainActor
    func typography(_ style: DSTypography.Style, color: Color? = nil) -> some View {
        let textColor = color ?? Color.Text.primary
        return self
            .font(style.font)
            .lineSpacing(style.lineHeight - style.font.lineHeight)
            .foregroundColor(textColor)
    }
}

// MARK: - Font Extension Helper
/// Internal helper for calculating approximate line heights based on font metrics.
/// Used internally by typography methods to ensure proper line spacing across all typography styles.
private extension Font {
    var lineHeight: CGFloat {
        // Approximate line height based on font size - used for calculating proper line spacing
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        default: return 17
        }
    }
}
