//
//  DSChatListRow.swift
//  RWLabsDesignSystem
//
//  Chat list row matching the Figma "Chat fields":
//    Direct     44pt avatar, name, last message, optional source line ("From Hiking club")
//    Community  same row; the last message is prefixed with its sender ("Ana: …")
//    Unread     coral time, semibold message, red count badge. Read: gray time and message.
//
//  DSChatListRow(name: "Ana", message: "See you there!", time: "2m", unreadCount: 2) {
//      DSChatAvatar(imageName: "ana", size: 44)
//  } action: { open(chat) }
//

import SwiftUI

// MARK: - Chat List Row
public struct DSChatListRow<Avatar: View>: View {
    let name: String
    let message: String
    let time: String?
    let unreadCount: Int
    let messageSender: String?
    let source: String?
    let showsDivider: Bool
    let avatar: Avatar
    let action: (() -> Void)?

    /// - Parameters:
    ///   - unreadCount: Above 0 shows the unread look and badge.
    ///   - messageSender: Community chats: prefixes the message with "Name: ".
    ///   - source: Direct chats: a small gray line under the message.
    public init(
        name: String,
        message: String,
        time: String? = nil,
        unreadCount: Int = 0,
        messageSender: String? = nil,
        source: String? = nil,
        showsDivider: Bool = true,
        @ViewBuilder avatar: () -> Avatar,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.message = message
        self.time = time
        self.unreadCount = unreadCount
        self.messageSender = messageSender
        self.source = source
        self.showsDivider = showsDivider
        self.avatar = avatar()
        self.action = action
    }

    private var isUnread: Bool { unreadCount > 0 }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) { content }
                    .buttonStyle(.plain)
            } else {
                content
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var content: some View {
        VStack(spacing: 0) {
            HStack(spacing: .sm) {
                avatar
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(name)
                            .fontStyle(.bodyMedium)
                            .foregroundColor(.Chat.title)
                            .lineLimit(1)
                        Spacer(minLength: .xs)
                        if let time {
                            Text(time)
                                .fontStyle(.caption)
                                .foregroundColor(isUnread ? .Chat.timeUnread : .Chat.timeRead)
                        }
                    }

                    HStack(spacing: .xs) {
                        Text(messageSender.map { "\($0): \(message)" } ?? message)
                            .fontStyle(isUnread ? .labelMedium : .label)
                            .foregroundColor(isUnread ? .Chat.previewUnread : .Chat.previewRead)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if isUnread {
                            DSUnreadBadge(count: unreadCount)
                        }
                    }

                    if let source {
                        Text(source)
                            .fontStyle(.caption)
                            .foregroundColor(.Chat.source)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, .md)
            .padding(.vertical, .xs)
            .frame(minHeight: 83)
            .contentShape(Rectangle())

            if showsDivider {
                Rectangle()
                    .fill(Color.Chat.divider)
                    .frame(height: .thin)
                    .padding(.horizontal, .md)
            }
        }
        .background(Color.Chat.bar)
    }
}

// MARK: - Unread Badge
/// 20pt red count used on chat rows and the nav bar.
public struct DSUnreadBadge: View {
    let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .fontStyle(.caption)
            .foregroundColor(.Chat.unreadBadgeText)
            .lineLimit(1)
            .padding(.horizontal, count > 9 ? .xxs : 0)
            .frame(minWidth: 20, minHeight: 20, maxHeight: 20)
            .background(Capsule().fill(Color.Chat.unreadBadge))
            .accessibilityLabel("\(count) unread")
    }
}

// MARK: - Preview
/// Mirrors the Figma Chat fields sheet: Direct and Community, each Unread then Read.
private struct DSChatListRowGallery: View {
    var body: some View {
        VStack(spacing: 0) {
            DSChatListRow(name: "Label", message: "This is a test message", time: "2m", unreadCount: 2, source: "Label") {
                DSChatAvatar(initials: "AS", size: 44)
            }
            DSChatListRow(name: "Label", message: "This is a test message", time: "2m", source: "Label") {
                DSChatAvatar(initials: "AS", size: 44)
            }
            DSChatListRow(name: "Label", message: "This is a test message", time: "2m", unreadCount: 2,
                          messageSender: "Test Name") {
                DSChatAvatar(initials: "HC", size: 44)
            }
            DSChatListRow(name: "Label", message: "This is a test message", time: "2m", messageSender: "Test Name") {
                DSChatAvatar(initials: "HC", size: 44)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatListRowGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatListRowGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSChatListRowGallery().designSystem()
}
