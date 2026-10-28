//
//  DSProgressCircle.swift
//  RWLabsDesignSystem
//
//  Circular loader matching the Figma "Loader": a brand arc with round caps over a light brand ring.
//  Indeterminate: the arc grows to ~85% of the ring (0.65s), then its tail catches up one full
//  turn later (0.65s), both eased with cubic-bezier(0.4, 0, 0.2, 1), looping seamlessly.
//
//  Style any ProgressView:
//
//  ProgressView()
//      .dsSpinnerStyle()                     // 48pt, Figma default
//
//  ProgressView(value: 0.6)
//      .dsSpinnerStyle(size: 32)             // determinate arc
//

import SwiftUI

// MARK: - Spinner Style
public struct DSSpinnerStyle: ProgressViewStyle {
    let size: CGFloat
    let lineWidth: CGFloat

    /// - Parameters:
    ///   - size: Ring diameter. Figma uses 48pt.
    ///   - lineWidth: Ring thickness. Defaults to 8% of `size`, Figma's proportion.
    public init(size: CGFloat = 48, lineWidth: CGFloat? = nil) {
        self.size = size
        self.lineWidth = lineWidth ?? size * 0.08
    }

    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if let fraction = configuration.fractionCompleted {
                DSSpinnerRing(tail: 0, head: min(max(fraction, 0), 1), lineWidth: lineWidth)
                    .animation(.easeInOut, value: fraction)
            } else {
                DSIndeterminateSpinner(lineWidth: lineWidth)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel("Loading")
    }
}

/// Track plus an arc from `tail` to `head`, in turns measured clockwise from 12 o'clock.
struct DSSpinnerRing: View {
    let tail: Double
    let head: Double
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.Progress.spinnerTrack, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(head - tail, 0))
                .stroke(Color.Progress.fill, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(tail * 360 - 90))
        }
        .padding(lineWidth / 2)
    }
}

struct DSIndeterminateSpinner: View {
    let lineWidth: CGFloat

    private static let phase: Double = 0.65
    private static let maxSweep: Double = 0.85
    private static let minSweep: Double = 0.02
    private static let curve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.4, y: 0),
        endControlPoint: UnitPoint(x: 0.2, y: 1)
    )

    var body: some View {
        TimelineView(.animation) { context in
            let (tail, head) = Self.arc(at: context.date.timeIntervalSinceReferenceDate)
            DSSpinnerRing(tail: tail, head: head, lineWidth: lineWidth)
        }
    }

    /// Phase 1 grows the head to `maxSweep`; phase 2 moves the tail a full turn while the head
    /// closes in, so each loop ends where the next one starts.
    static func arc(at time: TimeInterval) -> (tail: Double, head: Double) {
        let t = time.truncatingRemainder(dividingBy: phase * 2)
        if t < phase {
            let e = curve.value(at: t / phase)
            return (0, minSweep + (maxSweep - minSweep) * e)
        }
        let e = curve.value(at: (t - phase) / phase)
        return (e, maxSweep + (1 + minSweep - maxSweep) * e)
    }
}

public extension View {
    /// Figma circular loader. Indeterminate ProgressViews spin; determinate ones show their fraction.
    func dsSpinnerStyle(size: CGFloat = 48, lineWidth: CGFloat? = nil) -> some View {
        progressViewStyle(DSSpinnerStyle(size: size, lineWidth: lineWidth))
    }
}

// MARK: - DSProgressCircle
/// Convenience circle with an optional percentage label, built on `DSSpinnerStyle`.
public struct DSProgressCircle: View {

    public enum Style {
        case determinate
        case indeterminate
    }

    let value: Double // 0.0 to 1.0
    let style: Style
    let size: CGFloat
    let lineWidth: CGFloat?
    let showPercentage: Bool

    public init(
        value: Double,
        style: Style = .determinate,
        size: CGFloat = 48,
        lineWidth: CGFloat? = nil,
        showPercentage: Bool = true
    ) {
        self.value = min(max(value, 0.0), 1.0)
        self.style = style
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }

    public var body: some View {
        ZStack {
            if style == .determinate {
                ProgressView(value: value)
                    .dsSpinnerStyle(size: size, lineWidth: lineWidth)

                if showPercentage {
                    DSText("\(Int(value * 100))%", style: .label, color: .Text.primary)
                }
            } else {
                ProgressView()
                    .dsSpinnerStyle(size: size, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Preview
private struct DSProgressCircleGallery: View {
    var body: some View {
        VStack(spacing: .xl) {
            ProgressView().dsSpinnerStyle()

            HStack(spacing: .lg) {
                ProgressView(value: 0.1).dsSpinnerStyle()
                ProgressView(value: 0.5).dsSpinnerStyle()
                ProgressView(value: 0.85).dsSpinnerStyle()
            }

            HStack(spacing: .lg) {
                ProgressView().dsSpinnerStyle(size: 24)
                DSProgressCircle(value: 0.35, size: 64)
                DSProgressCircle(value: 0, style: .indeterminate, size: 32)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSProgressCircleGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSProgressCircleGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSProgressCircleGallery().designSystem()
}
