//
//  DSChatBubble.swift
//  RWLDesignSystem
//
//  Created on 2025-12-15.
//

import SwiftUI

// MARK: - Chat Bubble Variant

public enum DSChatBubbleVariant {
    case sender
    case receiver

    @MainActor
    var backgroundColor: Color {
        switch self {
        case .sender:
            return Color.Background.brand
        case .receiver:
            return Color.Background.secondary
        }
    }

    @MainActor
    var textColor: Color {
        switch self {
        case .sender:
            return Color.Text.white
        case .receiver:
            return Color.Text.primary
        }
    }

    @MainActor
    var timestampColor: Color {
        switch self {
        case .sender:
            return Color.Text.white.opacity(0.7)
        case .receiver:
            return Color.Text.secondary
        }
    }

    var alignment: HorizontalAlignment {
        switch self {
        case .sender:
            return .trailing
        case .receiver:
            return .leading
        }
    }

    var bubbleAlignment: Alignment {
        switch self {
        case .sender:
            return .topTrailing
        case .receiver:
            return .topLeading
        }
    }
}

// MARK: - Message Status

public enum DSChatMessageStatus {
    case sending
    case sent
    case delivered
    case read
    case failed

    var icon: String {
        switch self {
        case .sending:
            return "clock"
        case .sent:
            return "checkmark"
        case .delivered:
            return "checkmark.circle"
        case .read:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.circle"
        }
    }

    @MainActor
    var iconColor: Color {
        switch self {
        case .sending:
            return Color.Icon.white.opacity(0.6)
        case .sent:
            return Color.Icon.white.opacity(0.6)
        case .delivered:
            return Color.Icon.primary.opacity(0.8)
        case .read:
            return Color.Semantic.success
        case .failed:
            return Color.Semantic.error
        }
    }
}

// MARK: - Chat Bubble Component

public struct DSChatBubble: View {
    let message: String
    let variant: DSChatBubbleVariant
    let timestamp: String?
    let status: DSChatMessageStatus?
    let showAvatar: Bool
    let avatarImage: String?
    let avatarInitials: String?
    let avatarURL: URL?
    let maxWidth: CGFloat
    private var size: DSAvatar.AvatarSize {
        .medium
    }

    public init(
        message: String,
        variant: DSChatBubbleVariant,
        timestamp: String? = nil,
        status: DSChatMessageStatus? = nil,
        showAvatar: Bool = true,
        avatarImage: String? = nil,
        avatarURL: URL? = nil,
        avatarInitials: String? = nil,
        maxWidth: CGFloat = 280
    ) {
        self.message = message
        self.variant = variant
        self.timestamp = timestamp
        self.status = status
        self.showAvatar = showAvatar
        self.avatarImage = avatarImage
        self.avatarURL = avatarURL
        self.avatarInitials = avatarInitials
        self.maxWidth = maxWidth
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: .xs) {
            if variant == .receiver && showAvatar {
                avatarView
            } else if variant == .sender && showAvatar {
                Spacer(minLength: 40)
            }

            VStack(alignment: variant.alignment, spacing: .xxs) {
                // Message bubble
                VStack(alignment: .leading, spacing: .xxs) {
                    DSText(message, style: .body, color: variant.textColor)
                        .fixedSize(horizontal: false, vertical: true)

                    // Timestamp and status
                    if timestamp != nil || status != nil {
                        HStack(spacing: .xxs) {
                            if let timestamp = timestamp {
                                DSText(timestamp, style: .caption2, color: variant.timestampColor)
                            }

                            if let status = status, variant == .sender {
                                Image(systemName: status.icon)
                                    .foregroundColor(status.iconColor)
                            }
                        }
                    }
                }
                .padding(.horizontal, .sm)
                .padding(.vertical, .xs)
                .background(variant.backgroundColor)
                .cornerRadius(.lg)
                .shadow(.sm)
            }
            .frame(maxWidth: maxWidth, alignment: variant.bubbleAlignment)

            if variant == .sender && showAvatar {
                avatarView
            } else if variant == .receiver && showAvatar {
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: variant.bubbleAlignment)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let avatarURL = avatarURL {
            DSAvatar(
                imageURL: avatarURL,
                imageName: nil,
                initials: "",
                size: .medium,
                status: .none,
                aspectRatio: .fit
            )
        }
        else if let avatarImage = avatarImage {
            Image(avatarImage)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        } else if let avatarInitials = avatarInitials {
            initialsView
        } else {
            placeholderView
        }
    }
    
    var initialsView: some View {
        if let avatarInitials = avatarInitials, !avatarInitials.isEmpty {
            AnyView(Circle()
                .fill(Color.Icon.brand)
                .frame(width: 32, height: 32)
                .overlay(
                    DSText(avatarInitials ?? "", style: .bodyMedium, color: Color.Icon.brandAccent)
                ))
        } else {
            AnyView(placeholderView)
        }
    }
    
    var placeholderView: some View {
        Circle()
            .fill(Color.Background.secondary)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "person.fill")
                    .fontStyle(.bodyMedium)
                    .foregroundColor(Color.Icon.placeholder)
            )
    }
}

// MARK: - Chat Message Group

public struct DSChatMessageGroup: View {
    let messages: [(String, String?, DSChatMessageStatus?)]
    let variant: DSChatBubbleVariant
    let showAvatar: Bool
    let avatarImage: String?
    let avatarInitials: String?
    let spacing: CGFloat

    public init(
        messages: [(message: String, timestamp: String?, status: DSChatMessageStatus?)],
        variant: DSChatBubbleVariant,
        showAvatar: Bool = true,
        avatarImage: String? = nil,
        avatarInitials: String? = nil,
        spacing: CGFloat = 2
    ) {
        self.messages = messages
        self.variant = variant
        self.showAvatar = showAvatar
        self.avatarImage = avatarImage
        self.avatarInitials = avatarInitials
        self.spacing = spacing
    }

    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                DSChatBubble(
                    message: message.0,
                    variant: variant,
                    timestamp: index == messages.count - 1 ? message.1 : nil,
                    status: index == messages.count - 1 ? message.2 : nil,
                    showAvatar: index == messages.count - 1 ? showAvatar : false,
                    avatarImage: avatarImage,
                    avatarInitials: avatarInitials
                )
            }
        }
    }
}

// MARK: - Typed Chat Bubble (Image Support)

public struct DSChatMediaBubble: View {
    let imageURL: String?
    let caption: String?
    let variant: DSChatBubbleVariant
    let timestamp: String?
    let status: DSChatMessageStatus?
    let showAvatar: Bool
    let avatarImage: String?
    let avatarInitials: String?

    public init(
        imageURL: String?,
        caption: String? = nil,
        variant: DSChatBubbleVariant,
        timestamp: String? = nil,
        status: DSChatMessageStatus? = nil,
        showAvatar: Bool = true,
        avatarImage: String? = nil,
        avatarInitials: String? = nil
    ) {
        self.imageURL = imageURL
        self.caption = caption
        self.variant = variant
        self.timestamp = timestamp
        self.status = status
        self.showAvatar = showAvatar
        self.avatarImage = avatarImage
        self.avatarInitials = avatarInitials
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: .xs) {
            if variant == .receiver && showAvatar {
                avatarView
            } else if variant == .sender && showAvatar {
                Spacer(minLength: 40)
            }

            VStack(alignment: variant.alignment, spacing: .xxs) {
                VStack(alignment: .leading, spacing: .xxs) {
                    // Image placeholder
                    if let imageURL = imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.Background.secondary)
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .frame(width: 200, height: 150)
                        .cornerRadius(.md)
                    } else {
                        Rectangle()
                            .fill(Color.Background.secondary)
                            .frame(width: 200, height: 150)
                            .cornerRadius(.md)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(Color.Icon.placeholder)
                            )
                    }

                    // Caption
                    if let caption = caption {
                        DSText(caption, style: .bodySmall, color: variant.textColor)
                            .padding(.horizontal, .xs)
                    }

                    // Timestamp and status
                    if timestamp != nil || status != nil {
                        HStack(spacing: .xxs) {
                            if let timestamp = timestamp {
                                DSText(timestamp, style: .caption2, color: variant.timestampColor)
                            }

                            if let status = status, variant == .sender {
                                Image(systemName: status.icon)
                                    .foregroundColor(status.iconColor)
                            }
                        }
                        .padding(.horizontal, .xs)
                    }
                }
                .padding(.xxs)
                .background(variant.backgroundColor)
                .cornerRadius(.lg)
                .shadow(.sm)
            }

            if variant == .sender && showAvatar {
                avatarView
            } else if variant == .receiver && showAvatar {
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: variant.bubbleAlignment)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let avatarImage = avatarImage {
            Image(avatarImage)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        } else if let avatarInitials = avatarInitials {
            Circle()
                .fill(Color.Background.brandInverse)
                .frame(width: 32, height: 32)
                .overlay(
                    DSText(avatarInitials, style: .caption, color: Color.Text.brand)
                )
        } else {
            Circle()
                .fill(Color.Background.secondary)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(Color.Icon.placeholder)
                )
        }
    }
}

// MARK: - Previews

#Preview("Chat Bubbles - Basic") {
    VStack(spacing: .md) {
        DSChatBubble(
            message: "Hey! How are you doing?",
            variant: .receiver,
            timestamp: "10:30 AM",
            avatarInitials: "JD"
        )

        DSChatBubble(
            message: "I'm doing great, thanks for asking!",
            variant: .sender,
            timestamp: "10:31 AM",
            status: .read
        )

        DSChatBubble(
            message: "Want to grab lunch later?",
            variant: .receiver,
            timestamp: "10:32 AM",
            avatarInitials: "JD"
        )

        DSChatBubble(
            message: "Sounds good! Let's meet at 12:30",
            variant: .sender,
            timestamp: "10:33 AM",
            status: .delivered
        )
    }
    .padding()
    .background(Color.Background.primary)
}

#Preview("Chat Bubbles - Message Status") {
    VStack(spacing: .md) {
        DSChatBubble(
            message: "Sending...",
            variant: .sender,
            timestamp: "10:30 AM",
            status: .sending
        )

        DSChatBubble(
            message: "Sent message",
            variant: .sender,
            timestamp: "10:31 AM",
            status: .sent
        )

        DSChatBubble(
            message: "Delivered message",
            variant: .sender,
            timestamp: "10:32 AM",
            status: .delivered
        )

        DSChatBubble(
            message: "Read message",
            variant: .sender,
            timestamp: "10:33 AM",
            status: .read
        )

        DSChatBubble(
            message: "Failed to send",
            variant: .sender,
            timestamp: "10:34 AM",
            status: .failed
        )
    }
    .padding()
    .background(Color.Background.primary)
}

#Preview("Chat Bubbles - Message Group") {
    VStack(spacing: .md) {
        DSChatMessageGroup(
            messages: [
                ("Hey!", nil, nil),
                ("How are you?", nil, nil),
                ("Long time no see!", "10:30 AM", .read)
            ],
            variant: .receiver,
            avatarInitials: "AS"
        )

        DSChatMessageGroup(
            messages: [
                ("Hi!", nil, nil),
                ("I'm good!", nil, nil),
                ("Yeah, it's been a while", "10:32 AM", .delivered)
            ],
            variant: .sender
        )
    }
    .padding()
    .background(Color.Background.primary)
}

#Preview("Chat Bubbles - With Media") {
    VStack(spacing: .md) {
        DSChatMediaBubble(
            imageURL: nil,
            caption: "Check out this photo!",
            variant: .receiver,
            timestamp: "10:30 AM",
            avatarInitials: "MK"
        )

        DSChatMediaBubble(
            imageURL: nil,
            caption: "Wow, that looks amazing!",
            variant: .sender,
            timestamp: "10:31 AM",
            status: .read
        )
    }
    .padding()
    .background(Color.Background.primary)
}

#Preview("Chat Bubbles - Long Messages") {
    VStack(spacing: .md) {
        DSChatBubble(
            message: "This is a much longer message to demonstrate how the chat bubble handles text wrapping. It should expand vertically to accommodate multiple lines of text while maintaining the maximum width constraint.",
            variant: .receiver,
            timestamp: "10:30 AM",
            avatarInitials: "AB"
        )

        DSChatBubble(
            message: "Indeed! The design system handles long messages gracefully by wrapping the text and maintaining proper spacing. This ensures readability even with lengthy content.",
            variant: .sender,
            timestamp: "10:31 AM",
            status: .read
        )
    }
    .padding()
    .background(Color.Background.primary)
}
