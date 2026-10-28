//
//  DSDotsLoader.swift
//  RWLabsDesignSystem
//
//  Two-dot loader matching the Figma "Loader" (Loader UI): two light brand dots on a 75pt track.
//  The right dot runs to the left one and back, then the left dot runs to the right one and back
//  (Figma frames Default → Variant6 → Variant12 → Variant4).
//
//  ProgressView()
//      .dsDotsLoaderStyle()
//
//  DSDotsLoader()                            // same thing
//

import SwiftUI

// MARK: - Dots Loader Style
/// Always animates; a determinate ProgressView's value is ignored.
public struct DSDotsLoaderStyle: ProgressViewStyle {
    let dotSize: CGFloat

    /// - Parameter dotSize: Dot diameter. Figma uses 6.8pt on a track 11 dots wide.
    public init(dotSize: CGFloat = 6.8) {
        self.dotSize = dotSize
    }

    public func makeBody(configuration: Configuration) -> some View {
        DSDotsLoaderAnimation(dotSize: dotSize)
            .accessibilityElement()
            .accessibilityLabel("Loading")
    }
}

struct DSDotsLoaderAnimation: View {
    let dotSize: CGFloat

    /// Seconds per move (four moves per loop).
    private static let step: Double = 0.35
    /// Dot positions per keyframe, as a fraction of the travel: (left dot, right dot).
    private static func keyframes(adjacent: Double) -> [(Double, Double)] {
        [(0, 1), (0, adjacent), (0, 1), (1 - adjacent, 1), (0, 1)]
    }

    private var travel: CGFloat { dotSize * 10 }

    var body: some View {
        TimelineView(.animation) { context in
            let (left, right) = positions(at: context.date.timeIntervalSinceReferenceDate)
            ZStack(alignment: .leading) {
                dot.offset(x: left * travel)
                dot.offset(x: right * travel)
            }
            .frame(width: travel + dotSize, height: dotSize, alignment: .leading)
        }
    }

    var dot: some View {
        Circle()
            .fill(Color.Progress.dots)
            .frame(width: dotSize, height: dotSize)
    }

    func positions(at time: TimeInterval) -> (CGFloat, CGFloat) {
        // Adjacent dots sit a hair apart, as in Figma (7pt apart for 6.8pt dots)
        let frames = Self.keyframes(adjacent: Double((dotSize + 0.2) / travel))
        let loop = Self.step * Double(frames.count - 1)
        let t = time.truncatingRemainder(dividingBy: loop) / Self.step
        let index = min(Int(t), frames.count - 2)
        let e = UnitCurve.easeInOut.value(at: t - Double(index))
        let (a, b) = (frames[index], frames[index + 1])
        return (a.0 + (b.0 - a.0) * e, a.1 + (b.1 - a.1) * e)
    }
}

public extension View {
    /// Figma two-dot loader.
    func dsDotsLoaderStyle(dotSize: CGFloat = 6.8) -> some View {
        progressViewStyle(DSDotsLoaderStyle(dotSize: dotSize))
    }
}

// MARK: - DSDotsLoader
public struct DSDotsLoader: View {
    let dotSize: CGFloat

    public init(dotSize: CGFloat = 6.8) {
        self.dotSize = dotSize
    }

    public var body: some View {
        ProgressView().dsDotsLoaderStyle(dotSize: dotSize)
    }
}

// MARK: - Preview
private struct DSDotsLoaderGallery: View {
    var body: some View {
        VStack(spacing: .xl) {
            DSDotsLoader()
            DSDotsLoader(dotSize: 10)
            ProgressView().dsDotsLoaderStyle()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSDotsLoaderGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSDotsLoaderGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSDotsLoaderGallery().designSystem()
}
