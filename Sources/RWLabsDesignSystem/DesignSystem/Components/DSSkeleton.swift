//
//  DSSkeleton.swift
//  RWLDesignSystem
//
//  Skeleton loading placeholder
//

import SwiftUI

// MARK: - DSSkeleton

public struct DSSkeleton: View {

    // MARK: - Style

    public enum Style {
        case text
        case circle
        case rectangle
        case card
    }

    // MARK: - Properties

    let style: Style
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var isAnimating = false

    // MARK: - Initialization

    public init(
        style: Style = .text,
        width: CGFloat? = nil,
        height: CGFloat = 16,
        cornerRadius: CGFloat? = nil
    ) {
        self.style = style
        self.width = width
        self.height = height

        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        } else {
            switch style {
            case .text:
                self.cornerRadius = 4
            case .circle:
                self.cornerRadius = height / 2
            case .rectangle:
                self.cornerRadius = .radiusXS
            case .card:
                self.cornerRadius = .radiusXS
            }
        }
    }

    // MARK: - Body

    public var body: some View {
        let baseColor = Color.Background.secondaryInverse
        let highlightColor = Color.Text.placeholder

        Group {
            if let width = width {
                skeletonShape
                    .frame(width: width, height: height)
            } else {
                skeletonShape
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
            }
        }
        .overlay(
            LinearGradient(
                colors: [baseColor, highlightColor, baseColor],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? 500 : -500)
            .mask(skeletonShape)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Skeleton Shape

    @ViewBuilder
    private var skeletonShape: some View {
        switch style {
        case .text, .rectangle, .card:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.Background.tertiary)
        case .circle:
            Circle()
                .fill(Color.Background.tertiary)
        }
    }
}

// MARK: - Preview

#Preview("Skeleton") {
    VStack(spacing: .lg) {
        // Text skeleton
        VStack(alignment: .leading, spacing: .xs) {
            DSSkeleton(style: .text, width: 200, height: 20)
            DSSkeleton(style: .text, width: 150, height: 16)
            DSSkeleton(style: .text, width: 180, height: 16)
        }

        Divider()

        // Card skeleton
        VStack(alignment: .leading, spacing: .sm) {
            HStack(spacing: .sm) {
                DSSkeleton(style: .circle, width: 50, height: 50)
                VStack(alignment: .leading, spacing: .xs) {
                    DSSkeleton(style: .text, width: 120, height: 16)
                    DSSkeleton(style: .text, width: 80, height: 14)
                }
            }

            DSSkeleton(style: .card, height: 120)

            DSSkeleton(style: .text, height: 14)
            DSSkeleton(style: .text, width: 100, height: 14)
        }
        .padding(.md)
        .background(Color.Background.secondary)
        .cornerRadius(.md)
    }
    .padding()
}
