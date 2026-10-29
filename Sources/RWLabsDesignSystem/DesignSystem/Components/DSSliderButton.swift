//
//  DSSliderButton.swift
//  RWLabsDesignSystem
//
//  Swipe-to-confirm button matching the Figma "Swipe button":
//    Inactive  knob on the left, label centered
//    Swipe     knob follows the finger, label fades
//    Confirm   past the threshold the track turns brand coral and the knob shows a check
//
//  DSSliderButton(title: "Let's get started") { start() }
//

import SwiftUI

public struct DSSliderButton: View {
    let title: String
    let resetsAfterCompletion: Bool
    let onComplete: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isConfirmed = false

    private let height: CGFloat = 60
    private let knobSize: CGFloat = 40
    private let inset: CGFloat = .sm
    /// Share of the travel the knob must pass to confirm.
    private let threshold: CGFloat = 0.78

    /// - Parameter resetsAfterCompletion: Slide the knob back a second after confirming.
    public init(
        title: String,
        resetsAfterCompletion: Bool = true,
        onComplete: @escaping () -> Void
    ) {
        self.title = title
        self.resetsAfterCompletion = resetsAfterCompletion
        self.onComplete = onComplete
    }

    @available(*, deprecated, message: "Colors come from the theme; use init(title:resetsAfterCompletion:onComplete:)")
    public init(
        title: String,
        trackBackgroundColor: Color,
        thumbColor: Color = Color.Icon.brand,
        textColor: Color = Color.Text.primary,
        iconColor: Color = Color.Text.primary,
        onComplete: @escaping () -> Void
    ) {
        self.init(title: title, onComplete: onComplete)
    }

    public var body: some View {
        GeometryReader { geometry in
            let travel = max(geometry.size.width - knobSize - inset * 2, 1)

            DSSwipeTrack(
                title: title,
                progress: dragOffset / travel,
                isConfirmed: isConfirmed,
                knobOffset: dragOffset,
                knobSize: knobSize,
                inset: inset
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isConfirmed else { return }
                        dragOffset = min(max(0, value.translation.width), travel)
                    }
                    .onEnded { _ in
                        guard !isConfirmed else { return }
                        if dragOffset >= travel * threshold {
                            complete(travel: travel)
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { dragOffset = 0 }
                        }
                    }
            )
            .accessibilityElement()
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { complete(travel: travel) }
        }
        .frame(height: height)
        .sensoryFeedback(.success, trigger: isConfirmed) { _, new in new }
    }

    private func complete(travel: CGFloat) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = travel
            isConfirmed = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            onComplete()
            guard resetsAfterCompletion else { return }
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = 0
                isConfirmed = false
            }
        }
    }
}

// MARK: - Track
/// The drawn button for a given drag position; the parent owns the gesture.
struct DSSwipeTrack: View {
    let title: String
    /// 0 at rest, 1 at the right end
    let progress: CGFloat
    let isConfirmed: Bool
    let knobOffset: CGFloat
    let knobSize: CGFloat
    let inset: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(isConfirmed ? Color.Swipe.confirmedTrack : Color.Swipe.track)
                .shadow(color: isConfirmed ? .black.opacity(0.25) : Color.Selection.shadow,
                        radius: isConfirmed ? 0.5 : 4, y: isConfirmed ? 1 : 0)

            Text(title)
                .fontStyle(.bodyMedium)
                .foregroundColor(.Swipe.label)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, knobSize + inset * 2)
                .opacity(isConfirmed ? 0 : max(0, 1 - Double(progress) * 2))

            ZStack {
                Circle()
                    .fill(isConfirmed ? Color.Swipe.confirmedKnob : Color.Swipe.knob)
                    .shadow(color: .black.opacity(0.25), radius: 0.5, y: 2)
                Image(systemName: isConfirmed ? "checkmark" : "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isConfirmed ? .Swipe.confirmedIcon : .Swipe.knobIcon)
            }
            .frame(width: knobSize, height: knobSize)
            .padding(.leading, inset)
            .offset(x: knobOffset)
        }
    }
}

// MARK: - Preview
/// Mirrors the Figma Swipe button sheet (Inactive, Swipe, Confirm), then a live button.
private struct DSSliderButtonGallery: View {
    var body: some View {
        VStack(spacing: .lg) {
            DSSwipeTrack(title: "Let’s get started", progress: 0, isConfirmed: false, knobOffset: 0, knobSize: 40, inset: .sm)
                .frame(height: 60)
            DSSwipeTrack(title: "Let’s get started", progress: 0.5, isConfirmed: false, knobOffset: 150, knobSize: 40, inset: .sm)
                .frame(height: 60)
            DSSwipeTrack(title: "Let’s get started", progress: 1, isConfirmed: true, knobOffset: 295, knobSize: 40, inset: .sm)
                .frame(width: 359, height: 60)
            DSSliderButton(title: "Swipe to confirm") {}
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSliderButtonGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSliderButtonGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSSliderButtonGallery().designSystem()
}
