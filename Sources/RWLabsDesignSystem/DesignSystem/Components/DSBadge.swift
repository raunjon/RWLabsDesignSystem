//
//  DSBadge.swift
//  RWLabsDesignSystem
//
//  Badges matching the Figma "Badges":
//    DSRecommendedBadge  dark tab with 8pt top corners and a looping sheen
//    DSLabelBadge        icon + text pill; presets .idVerified and .photoVerified
//
//  DSBadge (count / dot) has no Figma design and keeps its existing look.
//

import SwiftUI

// MARK: - DSBadge

public struct DSBadge: View {

    // MARK: - Style

    public enum Style {
        case number
        case dot
    }

    // MARK: - Variant

    public enum Variant {
        case primary
        case secondary
        case error
        case success
        case warning
    }

    // MARK: - Properties

    let value: Int?
    let style: Style
    let variant: Variant
    let maxValue: Int

    // MARK: - Initialization

    public init(
        value: Int? = nil,
        style: Style = .number,
        variant: Variant = .error,
        maxValue: Int = 99
    ) {
        self.value = value
        self.style = style
        self.variant = variant
        self.maxValue = maxValue
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if style == .dot {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 8, height: 8)
            } else if let value = value, value > 0 {
                DSText(displayValue, style: .label, color: .Text.inverse)
                    .padding(.horizontal, value > 9 ? 4 : 0)
                    .frame(minWidth: 16, minHeight: 16)
                    .background(badgeColor)
                    .cornerRadius(8)
            }
        }
    }

    // MARK: - Helpers

    private var displayValue: String {
        guard let value = value else { return "" }
        return value > maxValue ? "\(maxValue)+" : "\(value)"
    }

    private var badgeColor: Color {
        switch variant {
        case .primary:
            return Color.Background.brand
        case .secondary:
            return Color.Background.brandInverse
        case .error:
            return Color.Semantic.error
        case .success:
            return Color.Semantic.success
        case .warning:
            return Color.Semantic.warning
        }
    }
}

// MARK: - Badge Modifier

public extension View {
    func badge(_ value: Int?, variant: DSBadge.Variant = .error) -> some View {
        self.overlay(
            DSBadge(value: value, variant: variant)
                .offset(x: 10, y: -10),
            alignment: .topTrailing
        )
    }

    func badgeDot(variant: DSBadge.Variant = .error) -> some View {
        self.overlay(
            DSBadge(style: .dot, variant: variant)
                .offset(x: 8, y: -8),
            alignment: .topTrailing
        )
    }
}

// MARK: - Recommended Badge
/// Figma "Badge – Recommended (sheen)": rests 0.6s, a white highlight sweeps left to right
/// over 1.5s (ease-in-out), then snaps back and repeats.
public struct DSRecommendedBadge: View {
    let title: String
    let isAnimated: Bool

    private static let rest: Double = 0.6
    private static let sweep: Double = 1.5

    public init(_ title: String = "Recommended", isAnimated: Bool = true) {
        self.title = title
        self.isAnimated = isAnimated
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: .radiusSM, topTrailingRadius: .radiusSM)
    }

    public var body: some View {
        Text(title)
            .fontStyle(.label)
            .fontWeight(.semibold)
            .foregroundColor(.Badge.highlightText)
            .lineLimit(1)
            .padding(.horizontal, .xs)
            .padding(.vertical, 2)
            .background(shape.fill(Color.Badge.highlightFill))
            .overlay {
                if isAnimated {
                    TimelineView(.animation) { context in
                        sheen(progress: Self.progress(at: context.date.timeIntervalSinceReferenceDate))
                    }
                }
            }
            .clipShape(shape)
    }

    private func sheen(progress: Double) -> some View {
        GeometryReader { geometry in
            let bandWidth: CGFloat = 16
            let travel = geometry.size.width + bandWidth * 3
            LinearGradient(
                colors: [.white.opacity(0), .white.opacity(0.7), .white.opacity(0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: bandWidth, height: geometry.size.height * 2)
            .rotationEffect(.degrees(20))
            .offset(x: -bandWidth * 2 + travel * progress, y: -geometry.size.height / 2)
        }
        .allowsHitTesting(false)
    }

    /// 0 while resting, then eases to 1 across the sweep.
    static func progress(at time: TimeInterval) -> Double {
        let t = time.truncatingRemainder(dividingBy: rest + sweep)
        guard t > rest else { return 0 }
        return UnitCurve.easeInOut.value(at: (t - rest) / sweep)
    }
}

// MARK: - Label Badge
/// Figma verification badges: 16pt icon and 14px text in a pill.
public struct DSLabelBadge: View {
    public enum Tone: Sendable {
        /// Light brand fill (ID verified)
        case brand
        /// Light gray fill (Photo verified)
        case neutral
    }

    let title: String
    let icon: Image?
    let tone: Tone

    public init(_ title: String, icon: Image? = nil, tone: Tone = .neutral) {
        self.title = title
        self.icon = icon
        self.tone = tone
    }

    public static var idVerified: DSLabelBadge {
        DSLabelBadge("ID verified", icon: Image(systemName: "checkmark.shield.fill"), tone: .brand)
    }

    public static var photoVerified: DSLabelBadge {
        DSLabelBadge("Photo verified", icon: Image(systemName: "camera.fill"), tone: .neutral)
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(tone == .brand ? .Badge.brandIcon : .Badge.neutralText)
            }
            Text(title)
                .fontStyle(.bodySmall)
                .foregroundColor(tone == .brand ? .Badge.brandText : .Badge.neutralText)
                .lineLimit(1)
        }
        .padding(.leading, .xs)
        .padding(.trailing, 10)
        .padding(.vertical, .xxs)
        .background(Capsule().fill(tone == .brand ? Color.Badge.brandFill : Color.Badge.neutralFill))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview
/// Mirrors the Figma Badges sheet, then the count and dot badges.
private struct DSBadgeGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .lg) {
            HStack(spacing: .md) {
                DSRecommendedBadge()
                DSRecommendedBadge(isAnimated: false)
            }
            HStack(spacing: .sm) {
                DSLabelBadge.idVerified
                DSLabelBadge.photoVerified
            }
            DSLabelBadge("Custom", icon: Image(systemName: "star.fill"), tone: .brand)

            HStack(spacing: .xl) {
                Image(systemName: "bell.fill").fontStyle(.heading2).badge(5)
                Image(systemName: "envelope.fill").fontStyle(.heading2).badge(120)
                Image(systemName: "person.fill").fontStyle(.heading2).badgeDot()
            }
            .foregroundColor(.Text.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSBadgeGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSBadgeGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSBadgeGallery().designSystem()
}
