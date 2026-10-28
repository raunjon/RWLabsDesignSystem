//
//  DSSelectionCard.swift
//  RWLabsDesignSystem
//
//  Selection card matching the Figma "Field selection": 84pt card with an optional 52pt icon
//  bubble, title and subtext, and the selection mark on the right. Selected cards take the
//  raised surface and a 1pt border.
//
//  Style any Toggle, so the content is yours:
//
//  Toggle(isOn: $likesHiking) {
//      DSSelectionCardLabel("Hiking", subtitle: "Weekend trails", icon: Image(systemName: "figure.hiking"))
//  }
//  .selectionCardStyle()
//
//  Or use the wrapper: DSSelectionCard(info: option, isSelected: $isSelected)
//

import SwiftUI

extension EnvironmentValues {
    /// Set by `DSSelectionCardStyle` so labels inside the card can react to selection.
    @Entry public var dsSelectionIsOn: Bool = false
}

// MARK: - Selection Card Style
public struct DSSelectionCardStyle: ToggleStyle {
    let minHeight: CGFloat
    let showsShadow: Bool

    public init(minHeight: CGFloat = 84, showsShadow: Bool = true) {
        self.minHeight = minHeight
        self.showsShadow = showsShadow
    }

    public func makeBody(configuration: Configuration) -> some View {
        DSSelectionCardBody(configuration: configuration, minHeight: minHeight, showsShadow: showsShadow)
    }
}

private struct DSSelectionCardBody: View {
    let configuration: ToggleStyleConfiguration
    let minHeight: CGFloat
    let showsShadow: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let isOn = configuration.isOn
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { configuration.isOn.toggle() }
        } label: {
            HStack(spacing: .xs) {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.dsSelectionIsOn, isOn)
                DSSelectionIndicator(isSelected: isOn)
            }
            .padding(.horizontal, .s20)
            .padding(.vertical, .md)
            .frame(minHeight: minHeight)
            .background(
                RoundedRectangle(cornerRadius: .radiusLG)
                    .fill(isOn ? Color.Selection.surfaceSelected : Color.Selection.surface)
                    .shadow(color: showsShadow ? Color.Selection.shadow : .clear, radius: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusLG)
                    .strokeBorder(isOn ? Color.Selection.borderSelected : .clear, lineWidth: .thin)
            )
            .contentShape(RoundedRectangle(cornerRadius: .radiusLG))
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

public extension View {
    /// Figma "Field selection" card for a Toggle.
    func selectionCardStyle(minHeight: CGFloat = 84, showsShadow: Bool = true) -> some View {
        toggleStyle(DSSelectionCardStyle(minHeight: minHeight, showsShadow: showsShadow))
    }
}

// MARK: - Card Label
/// Figma card content: icon bubble, title, optional subtext.
public struct DSSelectionCardLabel: View {
    let title: String
    let subtitle: String?
    let icon: Image?

    @Environment(\.dsSelectionIsOn) private var isOn

    public init(_ title: String, subtitle: String? = nil, icon: Image? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: .xs) {
            if let icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.Text.primary)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(isOn ? Color.Selection.surface : Color.Selection.iconBackground))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .fontStyle(.body)
                    .foregroundColor(.Text.primary)
                if let subtitle {
                    Text(subtitle)
                        .fontStyle(.label)
                        .foregroundColor(.Input.autofillText)
                }
            }
            .lineLimit(1)
        }
    }
}

// MARK: - Card Info
public enum DSSelectionMode {
    case singleSelect
    case multiSelect
}

public protocol DSSelectionCardInfo {
    var icon: Image? { get }
    var title: String { get }
    var subtitle: String? { get }
}

public extension DSSelectionCardInfo {
    var subtitle: String? { nil }
}

// MARK: - DSSelectionCard
/// Convenience card for a `DSSelectionCardInfo`, built on `DSSelectionCardStyle`.
public struct DSSelectionCard<T: DSSelectionCardInfo>: View {
    @Binding var isSelected: Bool
    let info: T
    let mode: DSSelectionMode
    let isEnabled: Bool
    let height: CGFloat
    let hideShadow: Bool
    let onTap: (Bool) -> Void

    /// - Parameter mode: Kept for callers; Figma uses the same mark for single and multi select.
    public init(
        info: T,
        isSelected: Binding<Bool>,
        mode: DSSelectionMode = .singleSelect,
        isEnabled: Bool = true,
        height: CGFloat = 84,
        hideShadow: Bool = false,
        onTap: @escaping (Bool) -> Void = { _ in }
    ) {
        self._isSelected = isSelected
        self.info = info
        self.mode = mode
        self.isEnabled = isEnabled
        self.height = height
        self.hideShadow = hideShadow
        self.onTap = onTap
    }

    public var body: some View {
        Toggle(isOn: Binding(
            get: { isSelected },
            set: { isSelected = $0; onTap($0) }
        )) {
            DSSelectionCardLabel(info.title, subtitle: info.subtitle, icon: info.icon)
        }
        .selectionCardStyle(minHeight: height, showsShadow: !hideShadow)
        .disabled(!isEnabled)
    }
}

// MARK: - Preview
private struct PreviewCardInfo: DSSelectionCardInfo {
    let icon: Image? = Image(systemName: "figure.stand.dress.line.vertical.figure")
    let title = "Main text"
    let subtitle: String? = "This is a description"
}

/// Mirrors the Figma Field selection sheet (Unselected, Selected), then custom content.
private struct DSSelectionCardGallery: View {
    @State private var first = false
    @State private var second = true
    @State private var custom = true

    var body: some View {
        VStack(spacing: .md) {
            DSSelectionCard(info: PreviewCardInfo(), isSelected: $first)
            DSSelectionCard(info: PreviewCardInfo(), isSelected: $second)

            Toggle(isOn: $custom) {
                DSSelectionCardLabel("Hiking", icon: Image(systemName: "figure.hiking"))
            }
            .selectionCardStyle()

            Toggle(isOn: $first) { Text("Text only").fontStyle(.body) }
                .selectionCardStyle(minHeight: 56)

            DSSelectionCard(info: PreviewCardInfo(), isSelected: $second, isEnabled: false)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSelectionCardGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSSelectionCardGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSSelectionCardGallery().designSystem()
}
