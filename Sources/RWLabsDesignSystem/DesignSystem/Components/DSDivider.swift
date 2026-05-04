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
        self.color = color ?? Color.Border.default
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

                Text(label!)
                    .fontStyle(.caption)
                    .foregroundColor(Color.Text.tertiary)

                Rectangle()
                    .fill(color)
                    .frame(height: thickness)
            }
        } else {
            VStack(spacing: .sm) {
                Rectangle()
                    .fill(color)
                    .frame(width: thickness)

                Text(label!)
                    .fontStyle(.caption)
                    .foregroundColor(Color.Text.tertiary)
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
            Text("Section 1")
            Text("Content here")

            DSDivider()

            Text("Section 2")
            Text("More content")
        }

        HStack {
            Text("Left")
            DSDivider(axis: .vertical)
            Text("Right")
        }
        .frame(height: 50)
    }
    .padding()
}
