//
//  DSChatBubble.swift
//  RWLabsDesignSystem
//
//  Chat messages matching the Figma "Chat messages":
//    Receiver  28pt avatar, sender name, light gray bubble (small bottom-left corner), time inside
//    Sender    dark navy bubble on the right (small bottom-right corner), time inside
//  Both can carry a row of emoji reactions under the bubble.
//
//  DSChatBubble(message: "Hi!", variant: .receiver, timestamp: "9:00 AM", senderName: "Ana",
//               reactions: [.init("🔥", count: 12)], avatarInitials: "AS")
//

import SwiftUI

// MARK: - Chat Bubble Variant
public enum DSChatBubbleVariant {
    case sender
    case receiver

    @MainActor
    var backgroundColor: Color {
        self == .sender ? .Chat.senderBubble : .Chat.surface
    }

    @MainActor
    var textColor: Color {
        self == .sender ? .Chat.senderText : .Chat.receiverText
    }

    @MainActor
    var timestampColor: Color {
        self == .sender ? .Chat.senderTime : .Chat.receiverTime
    }

    var alignment: HorizontalAlignment {
        self == .sender ? .trailing : .leading
    }

    var bubbleAlignment: Alignment {
        self == .sender ? .topTrailing : .topLeading
    }

    /// 16pt corners with a 4pt corner pointing at the speaker.
    var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: .radiusLG,
            bottomLeadingRadius: self == .receiver ? .radiusXS : .radiusLG,
            bottomTrailingRadius: self == .sender ? .radiusXS : .radiusLG,
            topTrailingRadius: .radiusLG
        )
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
        case .sending:   "clock"
        case .sent:      "checkmark"
        case .delivered: "checkmark.circle"
        case .read:      "checkmark.circle.fill"
        case .failed:    "exclamationmark.circle"
        }
    }

    @MainActor
    var iconColor: Color {
        switch self {
        case .sending, .sent, .delivered: .Chat.senderTime
        case .read:                       .Semantic.success
        case .failed:                     .Semantic.error
        }
    }
}

// MARK: - Reactions
public struct DSChatReaction: Hashable, Sendable {
    public let emoji: String
    public let count: Int

    public init(_ emoji: String, count: Int) {
        self.emoji = emoji
        self.count = count
    }
}

/// The chip of emoji counts under a message.
public struct DSChatReactions: View {
    let reactions: [DSChatReaction]

    public init(_ reactions: [DSChatReaction]) {
        self.reactions = reactions
    }

    public var body: some View {
        HStack(spacing: .xxs) {
            ForEach(reactions, id: \.self) { reaction in
                HStack(spacing: 2) {
                    Text(reaction.emoji)
                        .font(.system(size: 11))
                    Text("\(reaction.count)")
                        .fontStyle(.caption)
                        .foregroundColor(.Chat.reactionCount)
                }
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .frame(height: 22)
        .background(RoundedRectangle(cornerRadius: .radiusMD).fill(Color.Chat.surface))
        .overlay(RoundedRectangle(cornerRadius: .radiusMD).strokeBorder(Color.Chat.reactionBorder, lineWidth: .thin))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Avatar
/// Round avatar used across chat: an asset, a remote image, or initials.
public struct DSChatAvatar: View {
    let imageName: String?
    let imageURL: URL?
    let initials: String?
    let size: CGFloat

    public init(imageName: String? = nil, imageURL: URL? = nil, initials: String? = nil, size: CGFloat = 28) {
        self.imageName = imageName
        self.imageURL = imageURL
        self.initials = initials
        self.size = size
    }

    public var body: some View {
        Group {
            if let imageURL {
                CachedAsyncImage(url: imageURL, aspectRatio: .fill) { initialsView }
            } else if let imageName {
                Image(imageName).resizable().scaledToFill()
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle().fill(Color.Chat.surface)
            if let initials, !initials.isEmpty {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .medium))
                    .foregroundColor(.Text.brand)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.45))
                    .foregroundColor(.Chat.receiverTime)
            }
        }
    }
}

// MARK: - Chat Bubble
public struct DSChatBubble: View {
    let message: String
    let variant: DSChatBubbleVariant
    let timestamp: String?
    let status: DSChatMessageStatus?
    let senderName: String?
    let reactions: [DSChatReaction]
    let showAvatar: Bool
    let avatarImage: String?
    let avatarInitials: String?
    let avatarURL: URL?
    let maxWidth: CGFloat

    /// - Parameters:
    ///   - senderName: Shown above received messages (Figma "Name").
    ///   - showAvatar: Received messages only. `false` keeps the indent, for follow-up messages.
    ///   - maxWidth: Bubble width limit; Figma uses 257.
    public init(
        message: String,
        variant: DSChatBubbleVariant,
        timestamp: String? = nil,
        status: DSChatMessageStatus? = nil,
        senderName: String? = nil,
        reactions: [DSChatReaction] = [],
        showAvatar: Bool = true,
        avatarImage: String? = nil,
        avatarURL: URL? = nil,
        avatarInitials: String? = nil,
        maxWidth: CGFloat = 257
    ) {
        self.message = message
        self.variant = variant
        self.timestamp = timestamp
        self.status = status
        self.senderName = senderName
        self.reactions = reactions
        self.showAvatar = showAvatar
        self.avatarImage = avatarImage
        self.avatarURL = avatarURL
        self.avatarInitials = avatarInitials
        self.maxWidth = maxWidth
    }

    public var body: some View {
        HStack(alignment: .top, spacing: .xs) {
            if variant == .receiver {
                DSChatAvatar(imageName: avatarImage, imageURL: avatarURL, initials: avatarInitials)
                    .opacity(showAvatar ? 1 : 0)
            }

            VStack(alignment: variant.alignment, spacing: .xxs) {
                if variant == .receiver, let senderName {
                    Text(senderName)
                        .fontStyle(.bodySmallMedium)
                        .foregroundColor(.Chat.title)
                        .padding(.leading, .xxs)
                }

                bubble

                if !reactions.isEmpty {
                    DSChatReactions(reactions)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: variant.bubbleAlignment)
    }

    private var bubble: some View {
        VStack(alignment: variant.alignment, spacing: .xxs) {
            Text(message)
                .fontStyle(.bodySmall)
                .foregroundColor(variant.textColor)
                .fixedSize(horizontal: false, vertical: true)

            if timestamp != nil || status != nil {
                HStack(spacing: .xxs) {
                    if let timestamp {
                        Text(timestamp)
                            .fontStyle(.caption)
                            .foregroundColor(variant.timestampColor)
                    }
                    if let status, variant == .sender {
                        Image(systemName: status.icon)
                            .font(.system(size: 10))
                            .foregroundColor(status.iconColor)
                    }
                }
            }
        }
        .padding(.horizontal, .sm)
        .padding(.vertical, .xs)
        .background(variant.shape.fill(variant.backgroundColor))
        .frame(maxWidth: maxWidth, alignment: variant.bubbleAlignment)
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
                    showAvatar: index == 0 ? showAvatar : false,
                    avatarImage: avatarImage,
                    avatarInitials: avatarInitials
                )
            }
        }
    }
}

// MARK: - Media Bubble
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
        HStack(alignment: .top, spacing: .xs) {
            if variant == .receiver {
                DSChatAvatar(imageName: avatarImage, initials: avatarInitials)
                    .opacity(showAvatar ? 1 : 0)
            }

            VStack(alignment: .leading, spacing: .xxs) {
                image

                if let caption {
                    Text(caption)
                        .fontStyle(.bodySmall)
                        .foregroundColor(variant.textColor)
                        .padding(.horizontal, .xs)
                }

                if timestamp != nil || status != nil {
                    HStack(spacing: .xxs) {
                        if let timestamp {
                            Text(timestamp)
                                .fontStyle(.caption)
                                .foregroundColor(variant.timestampColor)
                        }
                        if let status, variant == .sender {
                            Image(systemName: status.icon)
                                .font(.system(size: 10))
                                .foregroundColor(status.iconColor)
                        }
                    }
                    .padding(.horizontal, .xs)
                }
            }
            .padding(.xxs)
            .background(variant.shape.fill(variant.backgroundColor))
        }
        .frame(maxWidth: .infinity, alignment: variant.bubbleAlignment)
    }

    @ViewBuilder
    private var image: some View {
        let placeholder = Rectangle().fill(Color.Chat.surface)
        Group {
            if let imageURL, let url = URL(string: imageURL) {
                CachedAsyncImage(url: url, aspectRatio: .fill) { placeholder.overlay(ProgressView()) }
            } else {
                placeholder.overlay(
                    Image(systemName: "photo").foregroundColor(.Chat.receiverTime)
                )
            }
        }
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: .radiusMD))
    }
}

// MARK: - Preview
/// Mirrors the Figma Chat messages sheet, then a follow-up message and a long one.
private struct DSChatBubbleGallery: View {
    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                DSChatBubble(message: "This is a test message", variant: .receiver, timestamp: "9:00 AM",
                             senderName: "Name", reactions: [.init("🔥", count: 12), .init("👍", count: 7)],
                             avatarInitials: "AS")
                DSChatBubble(message: "This is a test message", variant: .sender, timestamp: "9:00 AM",
                             reactions: [.init("🔥", count: 12), .init("👍", count: 7)])
                DSChatBubble(message: "Follow-up without the avatar", variant: .receiver, timestamp: "9:01 AM",
                             showAvatar: false)
                DSChatBubble(message: "A longer message wraps inside the bubble and keeps its corners, so long replies stay readable.",
                             variant: .sender, timestamp: "9:02 AM", status: .read)
                DSChatMediaBubble(imageURL: nil, caption: "Photo caption", variant: .receiver, timestamp: "9:03 AM",
                                  avatarInitials: "AS")
            }
            .padding()
        }
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatBubbleGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatBubbleGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSChatBubbleGallery().designSystem()
}
