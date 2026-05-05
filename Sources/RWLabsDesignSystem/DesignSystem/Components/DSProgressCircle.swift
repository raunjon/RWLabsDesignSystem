//
//  DSProgressCircle.swift
//  RWLDesignSystem
//
//  Circular progress indicator
//

import SwiftUI

// MARK: - DSProgressCircle

public struct DSProgressCircle: View {

    // MARK: - Style

    public enum Style {
        case determinate
        case indeterminate
    }

    // MARK: - Properties

    let value: Double // 0.0 to 1.0
    let style: Style
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool

    @State private var isAnimating = false

    // MARK: - Initialization

    public init(
        value: Double,
        style: Style = .determinate,
        size: CGFloat = 60,
        lineWidth: CGFloat = 6,
        showPercentage: Bool = true
    ) {
        self.value = min(max(value, 0.0), 1.0)
        self.style = style
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.Background.secondary, lineWidth: lineWidth)
                .frame(width: size, height: size)

            if style == .determinate {
                // Progress arc
                Circle()
                    .trim(from: 0.0, to: value)
                    .stroke(Color.Background.brand, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: value)

                // Percentage text
                if showPercentage {
                    DSText("\(Int(value * 100))%", style: .bodyMedium, color: .Text.primary)
                }
            } else {
                // Indeterminate spinner
                Circle()
                    .trim(from: 0.0, to: 0.25)
                    .stroke(Color.Background.brand, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
        }
        .onAppear {
            if style == .indeterminate {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Progress Circle") {
    VStack(spacing: .xl) {
        DSProgressCircle(value: 0.35)

        DSProgressCircle(value: 0.75, size: 80, lineWidth: 8)

        DSProgressCircle(value: 0.0, style: .indeterminate, showPercentage: false)

        DSProgressCircle(value: 1.0)
    }
    .padding()
}
