//
//  DSChatView.swift
//  RWLabsDesignSystem
//
//  Private chat matching the Figma "Private chat container" (Online / Offline):
//  header (back, avatar, name, presence, call buttons), date pills and messages, typing field.
//
//  DSChatView(name: "Ana", presence: .lastSeen("Last seen at 2:45 PM"), messages: messages,
//             onBack: dismiss, onSend: send) {
//      DSChatAvatar(imageName: "ana", size: 36)
//  } actions: {
//      Button { call() } label: { Image(systemName: "phone") }
//  }
//

import SwiftUI

// MARK: - Presence
public enum DSChatPresence: Equatable, Sendable {
    /// Green "online"
    case online
    /// Gray text, e.g. "Last seen at 2:45 PM"
    case lastSeen(String)
    /// Gray text, e.g. "12 members, 3 online"
    case text(String)
    case hidden
}

// MARK: - Header
public struct DSChatHeader<Avatar: View, Actions: View>: View {
    let name: String
    let presence: DSChatPresence
    let onBack: (() -> Void)?
    let avatar: Avatar
    let actions: Actions

    /// - Parameters:
    ///   - onBack: Shows the round back button when set.
    ///   - actions: Trailing 24pt icons (Figma: video, call), spaced 16pt.
    public init(
        name: String,
        presence: DSChatPresence = .hidden,
        onBack: (() -> Void)? = nil,
        @ViewBuilder avatar: () -> Avatar,
        @ViewBuilder actions: () -> Actions
    ) {
        self.name = name
        self.presence = presence
        self.onBack = onBack
        self.avatar = avatar()
        self.actions = actions()
    }

    public var body: some View {
        HStack(spacing: .sm) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.Chat.icon)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.Chat.surface))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }

            avatar
                .frame(width: 36, height: 36)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .fontStyle(.bodyMedium)
                    .foregroundColor(.Chat.title)
                    .lineLimit(1)
                presenceText
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: .xs)

            HStack(spacing: .md) { actions }
                .font(.system(size: 20))
                .foregroundColor(.Chat.icon)
                .buttonStyle(.plain)
        }
        .padding(.horizontal, .md)
        .padding(.top, .sm)
        .padding(.bottom, 13)
        .background(Color.Chat.bar)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.Chat.barBorder).frame(height: .thin)
        }
    }

    @ViewBuilder
    private var presenceText: some View {
        switch presence {
        case .online:
            Text("online").fontStyle(.label).foregroundColor(.Chat.online)
        case .lastSeen(let text), .text(let text):
            Text(text).fontStyle(.label).foregroundColor(.Chat.lastSeen).lineLimit(1)
        case .hidden:
            EmptyView()
        }
    }
}

public extension DSChatHeader where Actions == EmptyView {
    init(
        name: String,
        presence: DSChatPresence = .hidden,
        onBack: (() -> Void)? = nil,
        @ViewBuilder avatar: () -> Avatar
    ) {
        self.init(name: name, presence: presence, onBack: onBack, avatar: avatar) { EmptyView() }
    }
}

// MARK: - Date Pill
/// "Today", "Yesterday", "12th June 2020" between messages.
public struct DSChatDatePill: View {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .fontStyle(.label)
            .foregroundColor(.Chat.title)
            .padding(.horizontal, .xs)
            .padding(.vertical, .xxs)
            .background(RoundedRectangle(cornerRadius: .radiusSM).fill(Color.Chat.surface))
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Message List
/// Messages grouped by date with pills, scrolled to the newest. Shared by the private and group chats.
struct DSChatMessageList: View {
    let messages: [DSChatMessage]
    let typingUsers: [String]
    let showsSenderNames: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: .md) {
                    ForEach(groupedMessages, id: \.date) { group in
                        DSChatDatePill(group.date)
                        ForEach(Array(group.messages.enumerated()), id: \.element.id) { index, message in
                            let previous = index > 0 ? group.messages[index - 1] : nil
                            let isFollowUp = previous?.senderName == message.senderName
                                && previous?.isSentByCurrentUser == message.isSentByCurrentUser
                            messageView(for: message, isFollowUp: isFollowUp)
                                .id(message.id)
                        }
                    }
                    if !typingUsers.isEmpty {
                        DSTypingIndicator(userNames: typingUsers)
                            .id(Self.typingID)
                    }
                }
                .padding(.horizontal, .md)
                .padding(.vertical, .sm)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: messages.count) { _, _ in
                withAnimation { proxy.scrollTo(lastID, anchor: .bottom) }
            }
        }
    }

    private static let typingID = "typing-indicator"

    private var lastID: String? {
        typingUsers.isEmpty ? messages.last?.id : Self.typingID
    }

    @ViewBuilder
    private func messageView(for message: DSChatMessage, isFollowUp: Bool) -> some View {
        let variant: DSChatBubbleVariant = message.isSentByCurrentUser ? .sender : .receiver
        switch message.messageType {
        case .text:
            DSChatBubble(
                message: message.message,
                variant: variant,
                timestamp: message.timestamp,
                status: message.isSentByCurrentUser ? message.status : nil,
                senderName: showsSenderNames && !isFollowUp ? message.senderName : nil,
                reactions: message.reactions,
                showAvatar: !isFollowUp,
                avatarImage: message.senderAvatar,
                avatarInitials: message.senderInitials
            )
        case .image(let url, let caption):
            DSChatMediaBubble(
                imageURL: url,
                caption: caption,
                variant: variant,
                timestamp: message.timestamp,
                status: message.isSentByCurrentUser ? message.status : nil,
                showAvatar: !isFollowUp,
                avatarImage: message.senderAvatar,
                avatarInitials: message.senderInitials
            )
        }
    }

    /// Dates in order of first appearance, so the caller's message order is kept.
    private var groupedMessages: [(date: String, messages: [DSChatMessage])] {
        var groups: [(date: String, messages: [DSChatMessage])] = []
        for message in messages {
            if let index = groups.firstIndex(where: { $0.date == message.date }) {
                groups[index].messages.append(message)
            } else {
                groups.append((message.date, [message]))
            }
        }
        return groups
    }
}

// MARK: - Private Chat View
public struct DSChatView<Avatar: View, Actions: View>: View {
    let name: String
    let presence: DSChatPresence
    let messages: [DSChatMessage]
    let typingUsers: [String]
    let voiceState: DSChatVoiceState
    let inputActions: DSChatInputActions
    let onBack: (() -> Void)?
    let onSend: (String) -> Void
    let avatar: Avatar
    let actions: Actions

    @State private var draft = ""

    /// - Parameters:
    ///   - onSend: Receives the typed text; empty when sending a finished voice recording.
    public init(
        name: String,
        presence: DSChatPresence,
        messages: [DSChatMessage],
        typingUsers: [String] = [],
        voiceState: DSChatVoiceState = .idle,
        inputActions: DSChatInputActions = .init(),
        onBack: (() -> Void)? = nil,
        onSend: @escaping (String) -> Void,
        @ViewBuilder avatar: () -> Avatar,
        @ViewBuilder actions: () -> Actions
    ) {
        self.name = name
        self.presence = presence
        self.messages = messages
        self.typingUsers = typingUsers
        self.voiceState = voiceState
        self.inputActions = inputActions
        self.onBack = onBack
        self.onSend = onSend
        self.avatar = avatar()
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSChatHeader(name: name, presence: presence, onBack: onBack) { avatar } actions: { actions }
            DSChatMessageList(messages: messages, typingUsers: typingUsers, showsSenderNames: false)
            DSChatInput(text: $draft, voiceState: voiceState, actions: inputActions) {
                onSend(draft)
                draft = ""
            }
        }
        .background(Color.Chat.bar)
    }
}

// MARK: - Preview
/// Mirrors the Figma Private chat container (Online, Offline) with a few messages.
private struct DSChatViewGallery: View {
    let presence: DSChatPresence

    var body: some View {
        DSChatView(
            name: "Name",
            presence: presence,
            messages: [
                DSChatMessage(message: "Hey! Are you coming to the hike?", senderName: "Ana", senderInitials: "AS",
                              timestamp: "9:00 AM", date: "Yesterday", isSentByCurrentUser: false),
                DSChatMessage(message: "Yes, see you at 7!", senderName: "Me", senderInitials: "ME",
                              timestamp: "9:02 AM", date: "Yesterday", isSentByCurrentUser: true, status: .read,
                              reactions: [.init("🔥", count: 1)]),
                DSChatMessage(message: "Bring water", senderName: "Ana", senderInitials: "AS",
                              timestamp: "8:10 AM", date: "Today", isSentByCurrentUser: false),
            ],
            onBack: {},
            onSend: { _ in }
        ) {
            DSChatAvatar(initials: "AS", size: 36)
        } actions: {
            Button {} label: { Image(systemName: "video") }.accessibilityLabel("Video call")
            Button {} label: { Image(systemName: "phone") }.accessibilityLabel("Call")
        }
    }
}

#Preview("RWLabs Online") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatViewGallery(presence: .online).designSystem()
}

#Preview("RWLabs Dark Offline") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSChatViewGallery(presence: .lastSeen("Last seen at 2:45 PM")).designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSChatViewGallery(presence: .online).designSystem()
}
