//
//  DSTooltip.swift
//  RWLDesignSystem
//
//  Tooltip component with customizable positioning
//

import SwiftUI

// MARK: - DSTooltip

public struct DSTooltip: View {
    
    public enum Style {
        case brand
        case plain
        
        @MainActor
        var backgroundColor: Color {
            switch self {
            case .brand:
                .Background.brand
            case .plain:
                .Background.inverse
            }
        }
        
        @MainActor
        var textColor: Color {
            switch self {
            case .brand:
                .Text.white
            case .plain:
                .Background.inverse
            }
        }
    }
    
    @State var text: String
    let position: TooltipPosition
    let style: Style

    public init(
        text: String,
        position: TooltipPosition = .top,
        style: Style = .brand
    ) {
        self.text = text
        self.position = position
        self.style = style
    }

    public var body: some View {
        content
    }

    private var content: some View {
        VStack(spacing: .s0) {
            if position == .bottom {
                arrow
            }

            Text(text)
                .fontStyle(.bodySmall)
                .foregroundStyle(style.textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .sm)
                .padding(.vertical, .xs)
                .background(style.backgroundColor.opacity(0.9))
                .cornerRadius(.radiusLG)

            if position == .top {
                arrow
            }
        }
    }

    private var arrow: some View {
        Triangle()
            .fill(Color.Text.primary.opacity(0.9))
            .frame(width: 12, height: 6)
            .rotationEffect(.degrees(position == .top ? 180 : 0))
    }

    public enum TooltipPosition {
        case top
        case bottom
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - View Modifier

public extension View {
    func tooltip(
        _ text: String,
        isPresented: Binding<Bool>,
        position: DSTooltip.TooltipPosition = .top,
        style: DSTooltip.Style = .brand
    ) -> some View {
        ZStack {
            VStack {
                if position == .bottom {
                    self
                }
                if isPresented.wrappedValue {
                    DSTooltip(text: text, position: position, style: style)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(1000)
                }
                if position == .top {
                    self
                }
            }
          
        }
    }
}

// MARK: - Preview

#Preview("Basic Tooltip") {
    struct PreviewWrapper: View {
        @State private var showTooltip = false

        var body: some View {
            VStack(spacing: .xl) {
                DSButton(
                    title: showTooltip ? "Hide Tooltip" : "Show Tooltip",
                    variant: .primary
                ) {
                    withAnimation {
                        showTooltip.toggle()
                    }
                }
                .tooltip(
                    "This is a helpful tooltip message",
                    isPresented: $showTooltip,
                    position: .top
                )

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Tooltip Positions") {
    struct PreviewWrapper: View {
        @State private var showTop = true
        @State private var showBottom = true

        var body: some View {
            VStack(spacing: .xxl) {
                Spacer()

                DSButton(
                    title: showTop ? "Hide Top" : "Show Top",
                    variant: .outline
                ) {
                    withAnimation {
                        showTop.toggle()
                    }
                }
                .tooltip(
                    "Tooltip positioned at top",
                    isPresented: $showTop,
                    position: .top
                )

                DSButton(
                    title: showBottom ? "Hide Bottom" : "Show Bottom",
                    variant: .secondary
                ) {
                    withAnimation {
                        showBottom.toggle()
                    }
                }
                .tooltip(
                    "Tooltip positioned at bottom",
                    isPresented: $showBottom,
                    position: .bottom
                )

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Long Text Tooltip") {
    struct PreviewWrapper: View {
        @State private var showTooltip = true

        var body: some View {
            VStack(spacing: .xl) {
                Spacer()

                Image(systemName: "info.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.Icon.brand)
                    .tooltip(
                        "This is a longer tooltip message that demonstrates how the component handles multiline text content",
                        isPresented: $showTooltip,
                        position: .bottom
                    )
                    .onTapGesture {
                        withAnimation {
                            showTooltip.toggle()
                        }
                    }

                Text("Tap icon to toggle")
                    .fontStyle(.caption)
                    .foregroundStyle(Color.Text.secondary)

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
