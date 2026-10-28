//
//  DSDivider.swift
//  RWLDesignSystem
//
//  Divider line with optional label
//

import SwiftUI

// MARK: - DSDivider

public struct DSDivider: View {

    // MARK: - Axis

    public enum Axis {
        case horizontal
        case vertical
    }

    // MARK: - Properties

    let axis: Axis
    let label: String?
    let thickness: CGFloat
    let color: Color

    // MARK: - Initialization

    public init(
        axis: Axis = .horizontal,
        label: String? = nil,
        thickness: CGFloat = 1,
        color: Color? = nil
    ) {
        self.axis = axis
        self.label = label
        self.thickness = thickness
        self.color = color ?? Color.Border.subtle
    }

    // MARK: - Body

    public var body: some View {
        if label != nil {
            dividerWithLabel
        } else {
            simpleDivider
        }
    }

    // MARK: - Simple Divider

    @ViewBuilder
    private var simpleDivider: some View {
        if axis == .horizontal {
            Rectangle()
                .fill(color)
                .frame(height: thickness)
        } else {
            Rectangle()
                .fill(color)
                .frame(width: thickness)
        }
    }

    // MARK: - Divider with Label

    @ViewBuilder
    private var dividerWithLabel: some View {
        if axis == .horizontal {
            HStack(spacing: .sm) {
                Rectangle()
                    .fill(color)
                    .frame(height: thickness)

                DSText(label!, style: .label, color: .Text.tertiary)

                Rectangle()
                    .fill(color)
                    .frame(height: thickness)
            }
        } else {
            VStack(spacing: .sm) {
                Rectangle()
                    .fill(color)
                    .frame(width: thickness)

                DSText(label!, style: .label, color: .Text.tertiary)
                    .rotationEffect(.degrees(-90))

                Rectangle()
                    .fill(color)
                    .frame(width: thickness)
            }
        }
    }
}

// MARK: - Preview

#Preview("Divider") {
    VStack(spacing: .xl) {
        DSDivider()

        DSDivider(label: "OR")

        VStack(spacing: .sm) {
            DSText("Section 1", style: .body, color: .Text.primary)
            DSText("Content here", style: .body, color: .Text.primary)

            DSDivider()

            DSText("Section 2", style: .body, color: .Text.primary)
            DSText("More content", style: .body, color: .Text.primary)
        }

        HStack {
            DSText("Left", style: .body, color: .Text.primary)
            DSDivider(axis: .vertical)
            DSText("Right", style: .body, color: .Text.primary)
        }
        .frame(height: 50)
    }
    .padding()
}
