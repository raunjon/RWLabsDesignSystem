//
//  DSProgressBar.swift
//  RWLabsDesignSystem
//
//  Linear progress matching the Figma "Progress indicator": a brand fill for the completed part,
//  a 4pt gap, then a neutral track for the rest. Both ends are rounded.
//
//  Style any ProgressView:
//
//  ProgressView(value: 3, total: 10)
//      .dsProgressBarStyle()
//
//  Or use the onboarding stepper directly:
//
//  DSStepProgress(step: 3)                   // Figma Step=3 of 10
//

import SwiftUI

// MARK: - Progress Bar Style
/// Determinate progress draws Figma's split bar. Indeterminate progress slides a short fill along the track.
public struct DSProgressBarStyle: ProgressViewStyle {
    let height: CGFloat

    public init(height: CGFloat = 12) {
        self.height = height
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: .xs) {
            configuration.label
                .fontStyle(.bodySmallMedium)
                .foregroundColor(.Text.primary)

            Group {
                if let fraction = configuration.fractionCompleted {
                    DSProgressBarTrack(fraction: fraction, height: height)
                } else {
                    DSIndeterminateBarTrack(height: height)
                }
            }
            .frame(height: height)

            configuration.currentValueLabel
                .fontStyle(.label)
                .foregroundColor(.Text.secondary)
        }
    }
}

private struct DSProgressBarTrack: View {
    let fraction: Double
    let height: CGFloat

    private let gap: CGFloat = .xxs

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let clamped = min(max(fraction, 0), 1)
            let fillWidth = clamped >= 1 ? width : max(0, clamped * width - gap / 2)
            let trackWidth = clamped >= 1 ? 0 : width - fillWidth - (clamped > 0 ? gap : 0)

            HStack(spacing: clamped > 0 && clamped < 1 ? gap : 0) {
                if clamped > 0 {
                    Capsule().fill(Color.Progress.fill).frame(width: max(fillWidth, height))
                }
                if trackWidth > 0 {
                    Capsule().fill(Color.Progress.track)
                }
            }
            .animation(.easeInOut, value: clamped)
        }
    }
}

private struct DSIndeterminateBarTrack: View {
    let height: CGFloat
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.Progress.track)
                Capsule()
                    .fill(Color.Progress.fill)
                    .frame(width: width * 0.3)
                    .offset(x: isAnimating ? width * 0.7 : 0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear { isAnimating = true }
    }
}

public extension View {
    /// Figma progress bar: brand fill, 4pt gap, neutral track.
    func dsProgressBarStyle(height: CGFloat = 12) -> some View {
        progressViewStyle(DSProgressBarStyle(height: height))
    }
}

// MARK: - Step Progress
/// The onboarding progress bar from Figma: `step` of `totalSteps` segments filled.
public struct DSStepProgress: View {
    let step: Int
    let totalSteps: Int

    public init(step: Int, totalSteps: Int = 10) {
        self.step = step
        self.totalSteps = max(totalSteps, 1)
    }

    public var body: some View {
        ProgressView(value: Double(min(max(step, 0), totalSteps)), total: Double(totalSteps))
            .dsProgressBarStyle()
            .accessibilityLabel("Step \(step) of \(totalSteps)")
    }
}

// MARK: - DSProgressBar
/// Convenience bar with an optional label and percentage, built on `DSProgressBarStyle`.
public struct DSProgressBar: View {

    public enum Style {
        case determinate
        case indeterminate
    }

    let value: Double // 0.0 to 1.0
    let style: Style
    let label: String?
    let showPercentage: Bool
    let height: CGFloat

    public init(
        value: Double,
        style: Style = .determinate,
        label: String? = nil,
        showPercentage: Bool = true,
        height: CGFloat = 12
    ) {
        self.value = min(max(value, 0.0), 1.0)
        self.style = style
        self.label = label
        self.showPercentage = showPercentage
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            if label != nil || (showPercentage && style == .determinate) {
                HStack {
                    if let label {
                        DSText(label, style: .bodySmallMedium, color: .Text.primary)
                    }
                    Spacer()
                    if showPercentage && style == .determinate {
                        DSText("\(Int(value * 100))%", style: .bodySmallMedium, color: .Text.secondary)
                    }
                }
            }

            Group {
                if style == .determinate {
                    ProgressView(value: value)
                } else {
                    ProgressView()
                }
            }
            .dsProgressBarStyle(height: height)
        }
    }
}

// MARK: - Preview
/// Mirrors the Figma Progress indicator sheet (Step=1…10), then the convenience bar.
private struct DSProgressBarGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .lg) {
                ForEach(1...10, id: \.self) { step in
                    DSStepProgress(step: step)
                }

                ProgressView(value: 0.4) { Text("Custom label") }
                    .dsProgressBarStyle(height: 8)

                DSProgressBar(value: 0.35, label: "Uploading")
                DSProgressBar(value: 0, style: .indeterminate, label: "Loading", showPercentage: false)
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSProgressBarGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSProgressBarGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSProgressBarGallery().designSystem()
}
