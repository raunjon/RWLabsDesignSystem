//
//  DSSliderButton.swift
//  RWLabsDesignSystem
//
//  A draggable slider button component that requires users to drag to completion
//

import SwiftUI

/// A slider button component that requires dragging to trigger an action.
/// Users must drag the thumb across the track to a threshold to complete the action.
public struct DSSliderButton: View {
    /// The title text displayed on the slider
    var title: String

    /// The background color of the track
    var trackBackgroundColor: Color = Color.Background.primary

    /// The color of the draggable thumb
    var thumbColor: Color = Color.Icon.brand

    /// The color of the text
    var textColor: Color = Color.Text.primary

    /// The color of the icon inside the thumb
    var iconColor: Color = Color.Text.primary

    /// Callback triggered when the slider is successfully dragged to completion
    let onComplete: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    private let sliderHeight: CGFloat = 60
    private let thumbSize: CGFloat = 40
    private let minDragThreshold: CGFloat = 0.78 // 78% of available drag width

    public init(
        title: String,
        trackBackgroundColor: Color = Color.Background.primary,
        thumbColor: Color = Color.Icon.brand,
        textColor: Color = Color.Text.primary,
        iconColor: Color = Color.Text.primary,
        onComplete: @escaping () -> Void
    ) {
        self.title = title
        self.trackBackgroundColor = trackBackgroundColor
        self.thumbColor = thumbColor
        self.textColor = textColor
        self.iconColor = iconColor
        self.onComplete = onComplete
    }

    public var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width
            let maxDragDistance = sliderWidth - thumbSize - .sm * 2
            let dragThreshold = maxDragDistance * minDragThreshold

            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 30)
                    .fill(trackBackgroundColor)
                    .shadow(.lg)

                // Text (fades as user drags)
                HStack {
                    Spacer()

                    DSText(title, style: .bodyMedium, color: textColor)
                        .tracking(-0.15)

                    Spacer()
                }
                .opacity(max(0, 1 - Double(dragOffset / (maxDragDistance * 0.25))))
                .animation(.easeInOut(duration: 0.2), value: dragOffset)

                // Draggable thumb (chevron + circle)
                HStack(spacing: .sm) {
                    ZStack {
                        Circle()
                            .fill(thumbColor)
                            .shadow(.sm)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(iconColor)
                    }
                    .frame(width: thumbSize, height: thumbSize)

                    Spacer()
                }
                .frame(height: sliderHeight)
                .padding(.horizontal, .sm)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = value.translation.width
                            // Constrain drag to slider bounds
                            dragOffset = max(0, min(newOffset, maxDragDistance))
                            isDragging = true
                        }
                        .onEnded { value in
                            let finalOffset = dragOffset

                            // Check if dragged far enough to trigger
                            if finalOffset >= dragThreshold {
                                // Animate to complete state
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = maxDragDistance
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.resetSlider()
                                    }
                                }
                            } else {
                                self.resetSlider()
                            }
                            isDragging = false
                        }
                )
            }
        }
    }
    
    private func resetSlider() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
        }
    }
}

#Preview {
    DSSliderButton(title: "Let's get started") {
        print("Slider completed!")
    }
    .frame(height: 60)
    .padding()
}
