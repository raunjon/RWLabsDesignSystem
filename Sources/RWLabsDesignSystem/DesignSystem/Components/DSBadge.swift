//
//  DSBadge.swift
//  RWLDesignSystem
//
//  Badge component for notifications and counts
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
                DSText(displayValue, style: .caption2, color: .Text.inverse)
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

// MARK: - Preview

#Preview("Badge") {
    VStack(spacing: .xl) {
        HStack(spacing: .xl) {
            Image(systemName: "bell.fill")
                .fontStyle(.title)
                .badge(5)

            Image(systemName: "envelope.fill")
                .fontStyle(.title)
                .badge(120)

            Image(systemName: "person.fill")
                .fontStyle(.title)
                .badgeDot()
        }

        HStack(spacing: .md) {
            DSBadge(value: 1, variant: .error)
            DSBadge(value: 42, variant: .primary)
            DSBadge(value: 999, variant: .success)
            DSBadge(style: .dot, variant: .warning)
        }

        DSButton(title: "Notifications", variant: .primary) {
            
        }
        .badge(12)
    }
    .padding()
}
