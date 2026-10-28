//
//  DSCard.swift
//  RWLDesignSystem
//
//  Design system card component
//

import SwiftUI

// MARK: - Card Elevation
public enum DSCardElevation {
    case flat
    case low
    case medium
    case high

    @MainActor
    var shadow: DSShadow.ShadowStyle? {
        switch self {
        case .flat:
            return nil
        case .low:
            return .sm
        case .medium:
            return .md
        case .high:
            return .lg
        }
    }

    @MainActor
    var borderColor: Color? {
        switch self {
        case .flat:
            return Color.Border.subtle
        default:
            return nil
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
        elevation: DSCardElevation = .medium,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = .lg,
        padding: EdgeInsets = .card,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.backgroundColor = backgroundColor ?? Color.Background.primary
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }


    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .border(elevation.borderColor ?? .clear, lineWidth: .thin, cornerRadius: cornerRadius)
            .modifier(ShadowModifier(shadow: elevation.shadow))
    }
}

// MARK: - Shadow Modifier
private struct ShadowModifier: ViewModifier {
    let shadow: DSShadow.ShadowStyle?

    func body(content: Content) -> some View {
        if let shadow = shadow {
            content.shadow(shadow)
        } else {
            content
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
struct DSCard_Previews: PreviewProvider {
    static var previews: some View {
           Group {
               content
                   .preferredColorScheme(.light)

               content
                   .preferredColorScheme(.dark)
           }
       }
    
    static var content: some View {
        ScrollView {
            VStack(spacing: .lg) {
                // Basic Cards
                DSCard(elevation: .flat) {
                    DSText("Flat Card", style: .body, color: .Text.primary)
                }

                DSCard(elevation: .low) {
                    VStack(alignment: .leading) {
                        DSText("Low Elevation", style: .heading3, color: .Text.primary)
                        DSText("This is a card with low elevation", style: .body, color: .Text.primary)
                    }
                }

                DSCard(elevation: .high) {
                    DSText("High Elevation Card", style: .body, color: .Text.primary)
                }

                // Content Card
                DSContentCard(
                    image: Image(systemName: "photo"),
                    title: "Card Title",
                    subtitle: "Category",
                    description: "This is a content card with image, title, subtitle, and description. It can also have an action button.",
                    action: {}
                )

                // Info Cards
                DSInfoCard(
                    icon: Image(systemName: "chart.line.uptrend.xyaxis"),
                    iconColor: Color.Icon.brand,
                    title: "Total Sales",
                    value: "$24,500",
                    trend: "+12.5%",
                    trendIsPositive: true
                )

                DSInfoCard(
                    icon: Image(systemName: "person.3.fill"),
                    iconColor: Color.Semantic.info,
                    title: "Active Users",
                    value: "1,234",
                    trend: "-2.3%",
                    trendIsPositive: false
                )
            }
            .padding()
        }
    }
}
