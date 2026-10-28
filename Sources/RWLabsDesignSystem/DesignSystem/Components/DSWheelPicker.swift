//
//  DSWheelPicker.swift
//  RWLabsDesignSystem
//
//  Generic wheel matching the Figma "Height picker": 36pt rows that snap to a 32pt highlight band
//  in the middle, fading toward the edges. Scroll or tap a row to select it.
//
//  DSWheelPicker(selection: $age, options: Array(18...80)) { Text("\($0)") }
//

import SwiftUI

// MARK: - Wheel Picker
public struct DSWheelPicker<Value: Hashable, Label: View>: View {
    @Binding var selection: Value
    let options: [Value]
    let height: CGFloat
    let label: (Value) -> Label

    @State private var scrolledID: Value?

    private let rowHeight: CGFloat = 36
    private let highlightHeight: CGFloat = 32

    public init(
        selection: Binding<Value>,
        options: [Value],
        height: CGFloat = 172,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self._selection = selection
        self.options = options
        self.height = height
        self.label = label
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    label(option)
                        .fontStyle(.body)
                        .foregroundColor(option == (scrolledID ?? selection) ? .Input.text : .Input.placeholder)
                        .frame(maxWidth: .infinity)
                        .frame(height: rowHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) { scrolledID = option }
                        }
                        .id(option)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.vertical, (height - rowHeight) / 2, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledID, anchor: .center)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.3), location: 0),
                    .init(color: .black, location: 0.4),
                    .init(color: .black, location: 0.6),
                    .init(color: .black.opacity(0.3), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .background(
            Capsule()
                .fill(Color.Selection.wheelHighlight)
                .frame(height: highlightHeight)
        )
        .frame(height: height)
        .onAppear { scrolledID = selection }
        .onChange(of: scrolledID) { _, newValue in
            if let newValue, newValue != selection { selection = newValue }
        }
        .onChange(of: selection) { _, newValue in
            if scrolledID != newValue { scrolledID = newValue }
        }
        .sensoryFeedback(.selection, trigger: scrolledID)
        .accessibilityElement()
        .accessibilityAdjustableAction { direction in
            guard let index = options.firstIndex(of: selection) else { return }
            switch direction {
            case .increment where index + 1 < options.count: selection = options[index + 1]
            case .decrement where index > 0:                 selection = options[index - 1]
            default: break
            }
        }
    }
}

// MARK: - Wheel Card
public extension View {
    /// The Figma picker card: surface fill, 16pt corners, light drop shadow.
    func dsWheelCard() -> some View {
        padding(.vertical, .s20)
            .background(
                RoundedRectangle(cornerRadius: .radiusLG)
                    .fill(Color.Selection.surface)
                    .shadow(color: .black.opacity(0.25), radius: 1.5, y: 1)
            )
    }
}

// MARK: - Pill Toggle
/// Two-or-more option toggle with a sliding thumb, matching the Figma "height toggle".
public struct DSPillToggle<Value: Hashable, Label: View>: View {
    @Binding var selection: Value
    let options: [Value]
    let label: (Value) -> Label

    @Namespace private var namespace

    public init(selection: Binding<Value>, options: [Value], @ViewBuilder label: @escaping (Value) -> Label) {
        self._selection = selection
        self.options = options
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                label(option)
                    .fontStyle(.label)
                    .foregroundColor(.Text.primary)
                    .padding(.horizontal, .xs)
                    .frame(minWidth: 29, minHeight: 22)
                    .background {
                        if option == selection {
                            Capsule()
                                .fill(Color.Selection.toggleThumb)
                                .shadow(color: .black.opacity(0.25), radius: 0.75, y: 1)
                                .matchedGeometryEffect(id: "thumb", in: namespace)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { selection = option }
                    }
                    .accessibilityAddTraits(option == selection ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, 2) // Figma: thumb sits 2pt from the track edge
        .frame(height: 27)
        .background(
            Capsule()
                .fill(Color.Selection.toggleTrack)
                .shadow(color: Color.Selection.shadow, radius: 4)
        )
    }
}

// MARK: - Preview
private struct DSWheelPickerGallery: View {
    @State private var age = 28
    @State private var unit = "ft"

    var body: some View {
        VStack(spacing: .lg) {
            DSWheelPicker(selection: $age, options: Array(18...80)) { Text("\($0) years") }
                .dsWheelCard()
            DSPillToggle(selection: $unit, options: ["ft", "cm"]) { Text($0) }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSWheelPickerGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSWheelPickerGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSWheelPickerGallery().designSystem()
}
