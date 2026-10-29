//
//  DSCard.swift
//  RWLabsDesignSystem
//
//  Cards matching the Figma "Cards Container":
//    .container  white card, 16pt corners, 1pt gray border, soft shadow (the default)
//    DSCardContainer  the fixed L (276×324) / S (257×290) card with the optional ＋ button
//  The older elevations (.flat, .low, .medium, .high) are kept for existing screens.
//
//  DSCardContainer(size: .large, onAdd: { addGoal() }) {
//      VStack { … }
//  }
//

import SwiftUI

// MARK: - Card Elevation
public enum DSCardElevation {
    /// Figma Cards Container: 1pt border and a tight shadow
    case container
    case flat
    case low
    case medium
    case high

    @MainActor
    var shadow: DSShadow.ShadowStyle? {
        switch self {
        case .container, .flat: nil
        case .low:              .sm
        case .medium:           .md
        case .high:             .lg
        }
    }

    @MainActor
    var borderColor: Color? {
        switch self {
        case .container: Color.Card.border
        case .flat:      Color.Border.subtle
        default:         nil
        }
    }
}

// MARK: - DSCard Component
public struct DSCard<Content: View>: View {
    let elevation: DSCardElevation
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let content: Content

    @MainActor
    public init(
        elevation: DSCardElevation = .container,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = .radiusLG,
        padding: EdgeInsets = .card,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.backgroundColor = backgroundColor ?? Color.Card.surface
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .background(
                // Shadow on the shape only, so it never lands on the content
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .modifier(ShadowModifier(elevation: elevation))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(elevation.borderColor ?? .clear, lineWidth: .thin)
            )
    }
}

// MARK: - Shadow Modifier
private struct ShadowModifier: ViewModifier {
    let elevation: DSCardElevation

    func body(content: Content) -> some View {
        if elevation == .container {
            content.shadow(color: .Card.shadow, radius: 1.5, y: 1)
        } else if let shadow = elevation.shadow {
            content.shadow(shadow)
        } else {
            content
        }
    }
}

// MARK: - Card Size
public enum DSCardSize: Sendable {
    /// Figma L: 276×324, 32pt ＋
    case large
    /// Figma S: 257×290, 24pt ＋
    case small

    var width: CGFloat { self == .large ? 276 : 257 }
    var minHeight: CGFloat { self == .large ? 324 : 290 }
    var addButtonSize: CGFloat { self == .large ? 32 : 24 }
}

// MARK: - Card Container
/// The Figma card shell: fixed width, minimum height, content centered, optional ＋ in the corner.
public struct DSCardContainer<Content: View>: View {
    let size: DSCardSize
    let isAdded: Bool
    let onAdd: (() -> Void)?
    let content: Content

    /// - Parameters:
    ///   - onAdd: Shows the ＋ button when set.
    ///   - isAdded: Swaps the ＋ for a filled brand check.
    public init(
        size: DSCardSize = .large,
        isAdded: Bool = false,
        onAdd: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.isAdded = isAdded
        self.onAdd = onAdd
        self.content = content()
    }

    public var body: some View {
        DSCard(padding: EdgeInsets(top: .s32, leading: .lg, bottom: .s32, trailing: .lg)) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: size.width)
        .frame(minHeight: size.minHeight)
        .fixedSize(horizontal: false, vertical: true)
        .overlay(alignment: .topTrailing) {
            if let onAdd {
                Button(action: onAdd) {
                    Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                        .resizable()
                        .fontWeight(.ultraLight)
                        .foregroundColor(isAdded ? .Icon.brand : .Card.accessory)
                        .frame(width: size.addButtonSize, height: size.addButtonSize)
                        .contentShape(Circle().inset(by: -8))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isAdded ? "Added" : "Add")
                .padding(.top, .md)
                .padding(.trailing, .sm)
            }
        }
    }
}

// MARK: - Content Card with Image
public struct DSContentCard: View {
    let image: Image?
    let title: String
    let subtitle: String?
    let description: String?
    let action: (() -> Void)?
    let elevation: DSCardElevation

    public init(
        image: Image? = nil,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        elevation: DSCardElevation = .medium,
        action: (() -> Void)? = nil
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.elevation = elevation
        self.action = action
    }

    public var body: some View {
        DSCard(elevation: elevation, padding: .zero) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                }

                // Content
                VStack(alignment: .leading, spacing: .xs) {
                    if let subtitle = subtitle {
                        DSText(subtitle, style: .label, color: .Text.secondary)
                            .textCase(.uppercase)
                    }

                    DSText(title, style: .heading3, color: .Text.primary)

                    if let description = description {
                        DSText(description, style: .bodySmallMedium, color: .Text.secondary)
                            .lineLimit(3)
                    }
                }
                .padding(.md)

                // Action Button
                if let action = action {
                    Divider()
                    Button(action: action) {
                        HStack {
                            DSText("Learn More", style: .bodySmallMedium, color: .Text.brand)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color.Icon.brand)
                        }
                        .padding(.md)
                    }
                }
            }
        }
    }
}

// MARK: - Info Card with Icon
public struct DSInfoCard: View {
    let icon: Image
    let iconColor: Color
    let title: String
    let value: String
    let trend: String?
    let trendIsPositive: Bool

    @MainActor
    public init(
        icon: Image,
        iconColor: Color? = nil,
        title: String,
        value: String,
        trend: String? = nil,
        trendIsPositive: Bool = true
    ) {
        self.icon = icon
        self.iconColor = iconColor ?? Color.Icon.brand
        self.title = title
        self.value = value
        self.trend = trend
        self.trendIsPositive = trendIsPositive
    }

    public var body: some View {
        DSCard(elevation: .low) {
            HStack(spacing: .md) {
                // Icon
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(iconColor)
                    .padding(.sm)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(.md)

                VStack(alignment: .leading, spacing: .xxs) {
                    DSText(title, style: .bodySmallMedium, color: .Text.secondary)

                    DSText(value, style: .heading3, color: .Text.primary)

                    if let trend = trend {
                        HStack(spacing: .xxs) {
                            Image(systemName: trendIsPositive ? "arrow.up" : "arrow.down")
                                .font(.system(size: 10))
                            DSText(trend, style: .label, color: trendIsPositive ? .Semantic.success : .Semantic.error)
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview
/// Mirrors the Figma Cards Container sheet (L, S) with goal-card content, then the older elevations.
private struct DSCardGallery: View {
    @State private var added = false

    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                DSCardContainer(size: .large, isAdded: added, onAdd: { added.toggle() }) { goal }
                DSCardContainer(size: .small, onAdd: {}) { goal }
                DSCard {
                    Text("Default card").fontStyle(.body).foregroundColor(.Card.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DSInfoCard(icon: Image(systemName: "person.3.fill"), title: "Active users", value: "1,234",
                           trend: "+2.3%")
            }
            .padding()
        }
        .background(Color.Background.primary)
    }

    private var goal: some View {
        VStack(spacing: 34) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundColor(.Button.primaryText)
                .frame(width: 106, height: 106)
                .background(Circle().fill(Color.Icon.brand).shadow(color: .Icon.brand.opacity(0.25), radius: 1, y: 3))
            VStack(spacing: .md) {
                Text("Long term relationship").fontStyle(.bodyMedium).foregroundColor(.Card.title)
                Text("Building a lasting connection with someone special")
                    .fontStyle(.bodySmall).foregroundColor(.Card.message).multilineTextAlignment(.center)
            }
        }
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSCardGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSCardGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSCardGallery().designSystem()
}
