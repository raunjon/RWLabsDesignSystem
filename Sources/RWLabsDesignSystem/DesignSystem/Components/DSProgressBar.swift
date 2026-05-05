//
//  DSProgressBar.swift
//  RWLDesignSystem
//
//  Linear progress bar component
//

import SwiftUI

// MARK: - DSProgressBar

public struct DSProgressBar: View {

    // MARK: - Style

    public enum Style {
        case determinate
        case indeterminate
    }

    // MARK: - Properties

    let value: Double // 0.0 to 1.0
    let style: Style
    let label: String?
    let showPercentage: Bool
    let height: CGFloat

    @State private var isAnimating = false

    // MARK: - Initialization

    public init(
        value: Double,
        style: Style = .determinate,
        label: String? = nil,
        showPercentage: Bool = true,
        height: CGFloat = 8
    ) {
        self.value = min(max(value, 0.0), 1.0)
        self.style = style
        self.label = label
        self.showPercentage = showPercentage
        self.height = height
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            if label != nil || showPercentage {
                HStack {
                    if let label = label {
                        DSText(label, style: .bodyMedium, color: .Text.primary)
                    }

                    Spacer()

                    if showPercentage && style == .determinate {
                        DSText("\(Int(value * 100))%", style: .bodyMedium, color: .Text.secondary)
                    }
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.Background.secondary)
                        .frame(height: height)
                        .cornerRadius(height / 2)

                    // Progress fill
                    if style == .determinate {
                        Rectangle()
                            .fill(Color.Background.brand)
                            .frame(width: geometry.size.width * value, height: height)
                            .cornerRadius(height / 2)
                            .animation(.easeInOut, value: value)
                    } else {
                        Rectangle()
                            .fill(Color.Background.brand)
                            .frame(width: geometry.size.width * 0.3, height: height)
                            .cornerRadius(height / 2)
                            .offset(x: isAnimating ? geometry.size.width * 0.7 : -geometry.size.width * 0.3)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                    }
                }
            }
            .frame(height: height)
            .onAppear {
                if style == .indeterminate {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Progress Bar") {
    VStack(spacing: .xl) {
        DSProgressBar(
            value: 0.35,
            label: "Uploading"
        )

        DSProgressBar(
            value: 0.75,
            label: "Progress"
        )

        DSProgressBar(
            value: 0.0,
            style: .indeterminate,
            label: "Loading",
            showPercentage: false
        )

        DSProgressBar(
            value: 1.0,
            label: "Complete"
        )
    }
    .padding()
}
