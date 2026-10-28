//
//  DSGroupChatView.swift
//  RWLDesignSystem
//
//  Created on 2025-12-15.
//

import SwiftUI

// MARK: - Message Model

public struct DSChatMessage: Identifiable {
    public let id: String
    public let message: String
    public let senderName: String
    public let senderInitials: String
    public let senderAvatar: String?
    public let timestamp: String
    public let date: String
    public let isSentByCurrentUser: Bool
    public let status: DSChatMessageStatus?
    public let messageType: MessageType

    public enum MessageType {
        case text
        case image(url: String?, caption: String?)
    }

    public init(
        id: String = UUID().uuidString,
        message: String,
        senderName: String,
        senderInitials: String,
        senderAvatar: String? = nil,
        timestamp: String,
        date: String,
        isSentByCurrentUser: Bool,
        status: DSChatMessageStatus? = nil,
        messageType: MessageType = .text
    ) {
        self.id = id
        self.message = message
        self.senderName = senderName
        self.senderInitials = senderInitials
        self.senderAvatar = senderAvatar
        self.timestamp = timestamp
        self.date = date
        self.isSentByCurrentUser = isSentByCurrentUser
        self.status = status
        self.messageType = messageType
    }
}

// MARK: - Group Chat Member

public struct DSGroupChatMember: Identifiable {
    public let id: String
    public let name: String
    public let initials: String
    public let avatar: String?
    public let isOnline: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        initials: String,
        avatar: String? = nil,
        isOnline: Bool = false
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.avatar = avatar
        self.isOnline = isOnline
    }
}

// MARK: - Date Separator

public struct DSChatDateSeparator: View {
    let date: String

    public init(date: String) {
        self.date = date
    }

    public var body: some View {
        HStack {
            Rectangle()
                .fill(Color.Border.subtle)
                .frame(height: 1)

            DSText(date, style: .label, color: .Text.secondary)
                .padding(.horizontal, .sm)

            Rectangle()
                .fill(Color.Border.subtle)
                .frame(height: 1)
        }
        .padding(.vertical, .md)
    }
}

// MARK: - Typing Indicator

public struct DSTypingIndicator: View {
    let userNames: [String]
    @State private var animationPhase = 0

    public init(userNames: [String]) {
        self.userNames = userNames
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: .xs) {
            // Avatar placeholder
            Circle()
                .fill(Color.Background.secondary)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "ellipsis")
                        .fontStyle(.label)
                        .foregroundColor(Color.Icon.placeholder)
                )

            VStack(alignment: .leading, spacing: .xxs) {
                DSText(typingText, style: .label, color: .Text.secondary)

                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.Icon.secondary)
                            .frame(width: 6, height: 6)
                            .opacity(animationPhase == index ? 1.0 : 0.3)
                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: animationPhase)
                    }
                }
                .padding(.horizontal, .sm)
                .padding(.vertical, .xs)
                .background(Color.Background.tertiary)
                .cornerRadius(.radiusMD)
            }

            Spacer(minLength: 40)
        }
        .onAppear {
            startAnimation()
        }
    }

    private var typingText: String {
        switch userNames.count {
        case 1:
            return "\(userNames[0]) is typing..."
        case 2:
            return "\(userNames[0]) and \(userNames[1]) are typing..."
        case 3...:
            return "\(userNames[0]), \(userNames[1]) and \(userNames.count - 2) others are typing..."
        default:
            return "Someone is typing..."
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            Task { @MainActor in
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

// MARK: - Group Chat Header

public struct DSGroupChatHeader: View {
    let groupName: String
    let groupAvatar: String?
    let memberCount: Int
    let onlineCount: Int
    let onBackTapped: () -> Void
    let onInfoTapped: () -> Void

    public init(
        groupName: String,
        groupAvatar: String? = nil,
        memberCount: Int,
        onlineCount: Int,
        onBackTapped: @escaping () -> Void,
        onInfoTapped: @escaping () -> Void
    ) {
        self.groupName = groupName
        self.groupAvatar = groupAvatar
        self.memberCount = memberCount
        self.onlineCount = onlineCount
        self.onBackTapped = onBackTapped
        self.onInfoTapped = onInfoTapped
    }

    public var body: some View {
        HStack(spacing: .sm) {
            // Back button
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .fontStyle(.heading3)
                    .foregroundColor(Color.Icon.brand)
            }

            // Group avatar
            if let groupAvatar = groupAvatar {
                Image(groupAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.Icon.brandAccent)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .fontStyle(.body)
                            .foregroundColor(Color.Icon.brand)
                    )
            }

            // Group info
            VStack(alignment: .leading, spacing: 2) {
                DSText(groupName, style: .heading3, color: .Text.primary)
                    .fontWeight(.semibold)

                DSText("\(memberCount) members, \(onlineCount) online", style: .label, color: .Text.secondary)
            }

            Spacer()

            // Info button
            Button(action: onInfoTapped) {
                Image(systemName: "info.circle")
                    .font(.system(size: 28))
                    .foregroundColor(Color.Icon.brand)
            }
        }
        .padding(.horizontal, .md)
        .padding(.vertical, .sm)
        .background(Color.Background.primary)
        .overlay(
            Rectangle()
                .fill(Color.Border.subtle)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Group Chat Input

public struct DSGroupChatInput: View {
    @Binding var text: String
    let onSendTapped: () -> Void
    let onAttachTapped: () -> Void

    public init(
        text: Binding<String>,
        onSendTapped: @escaping () -> Void,
        onAttachTapped: @escaping () -> Void
    ) {
        self._text = text
        self.onSendTapped = onSendTapped
        self.onAttachTapped = onAttachTapped
    }

    public var body: some View {
        HStack(spacing: .sm) {
            // Attach button
            Button(action: onAttachTapped) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.Icon.brand)
                    .background(Color.Background.primary)
            }

            // Text input
            HStack(spacing: .xs) {
                TextField("Type a message...", text: $text)
                    .fontStyle(.body)
                    .foregroundColor(Color.Text.primary)

                // Emoji button
                Button(action: {}) {
                    Image(systemName: "face.smiling")
                        .fontStyle(.heading3)
                        .foregroundColor(Color.Background.secondaryInverse)
                }
            }
            .padding(.horizontal, .sm)
            .padding(.vertical, .xs)
            .background(Color.Background.secondary)
            .cornerRadius(.radiusFull)

            // Send button
            Button(action: onSendTapped) {
                Image(systemName: text.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty ? Color.Button.disabled: Color.Button.primary)
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, .md)
        .padding(.vertical, .sm)
        .background(Color.Background.primary)
        .overlay(
            Rectangle()
                .fill(Color.Border.subtle)
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Group Member Avatars Row

public struct DSGroupMemberAvatars: View {
    let members: [DSGroupChatMember]
    let maxVisible: Int
    let onMemberTapped: (DSGroupChatMember) -> Void

    public init(
        members: [DSGroupChatMember],
        maxVisible: Int = 5,
        onMemberTapped: @escaping (DSGroupChatMember) -> Void = { _ in }
    ) {
        self.members = members
        self.maxVisible = maxVisible
        self.onMemberTapped = onMemberTapped
    }

    public var body: some View {
        HStack(spacing: -8) {
            ForEach(Array(members.prefix(maxVisible))) { member in
                Button(action: { onMemberTapped(member) }) {
                    ZStack(alignment: .bottomTrailing) {
                        if let avatar = member.avatar {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.Background.primary, lineWidth: 2)
                                )
                        } else {
                            Circle()
                                .fill(Color.Icon.brand)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.Background.primary, lineWidth: 2)
                                )
                                .overlay(
                                    DSText(member.initials, style: .label, color: .Text.primary)
                                )
                        }

                        if member.isOnline {
                            Circle()
                                .fill(Color.Semantic.success)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.Background.primary, lineWidth: 2)
                                )
                        }
                    }
                }
            }

            if members.count > maxVisible {
                Circle()
                    .fill(Color.Background.secondary)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.Background.primary, lineWidth: 2)
                    )
                    .overlay(
                        DSText("+\(members.count - maxVisible)", style: .label, color: .Text.secondary)
                    )
            }
        }
    }
}

// MARK: - Group Chat View

public struct DSGroupChatView: View {
    let groupName: String
    let groupAvatar: String?
    let members: [DSGroupChatMember]
    let messages: [DSChatMessage]
    let typingUsers: [String]

    @State private var messageText: String = ""
    @State private var scrollProxy: ScrollViewProxy?

    let onBackTapped: () -> Void
    let onInfoTapped: () -> Void
    let onSendMessage: (String) -> Void
    let onAttachTapped: () -> Void

    public init(
        groupName: String,
        groupAvatar: String? = nil,
        members: [DSGroupChatMember],
        messages: [DSChatMessage],
        typingUsers: [String] = [],
        onBackTapped: @escaping () -> Void = {},
        onInfoTapped: @escaping () -> Void = {},
        onSendMessage: @escaping (String) -> Void = { _ in },
        onAttachTapped: @escaping () -> Void = {}
    ) {
        self.groupName = groupName
        self.groupAvatar = groupAvatar
        self.members = members
        self.messages = messages
        self.typingUsers = typingUsers
        self.onBackTapped = onBackTapped
        self.onInfoTapped = onInfoTapped
        self.onSendMessage = onSendMessage
        self.onAttachTapped = onAttachTapped
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            DSGroupChatHeader(
                groupName: groupName,
                groupAvatar: groupAvatar,
                memberCount: members.count,
                onlineCount: members.filter { $0.isOnline }.count,
                onBackTapped: onBackTapped,
                onInfoTapped: onInfoTapped
            )

            // Messages
            ScrollViewReader { proxy in
                if #available(iOS 17.0, *) {
                    ScrollView {
                        LazyVStack(spacing: .sm) {
                            ForEach(groupedMessages, id: \.date) { group in
                                DSChatDateSeparator(date: group.date)
                                
                                ForEach(group.messages) { message in
                                    messageView(for: message)
                                        .id(message.id)
                                }
                            }
                            
                            // Typing indicator
                            if !typingUsers.isEmpty {
                                DSTypingIndicator(userNames: typingUsers)
                                    .id("typing-indicator")
                            }
                        }
                        .padding(.horizontal, .md)
                        .padding(.vertical, .sm)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .onChange(of: messages.count) { _, _ in
                        scrollToBottom()
                    }
                } else {
                    // Fallback on earlier versions
                }
            }

            // Input
            DSGroupChatInput(
                text: $messageText,
                onSendTapped: {
                    guard !messageText.isEmpty else { return }
                    onSendMessage(messageText)
                    messageText = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom()
                    }
                },
                onAttachTapped: onAttachTapped
            )
        }
        .background(Color.Background.primary)
    }

    @ViewBuilder
    private func messageView(for message: DSChatMessage) -> some View {
        VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading, spacing: .xxs) {
            // Show sender name for group chat (only for received messages)
            if !message.isSentByCurrentUser {
                DSText(message.senderName, style: .label, color: .Text.secondary)
                    .padding(.leading, 40)
            }

            switch message.messageType {
            case .text:
                DSChatBubble(
                    message: message.message,
                    variant: message.isSentByCurrentUser ? .sender : .receiver,
                    timestamp: message.timestamp,
                    status: message.isSentByCurrentUser ? message.status : nil,
                    showAvatar: true,
                    avatarImage: message.senderAvatar,
                    avatarInitials: message.senderInitials
                )

            case .image(let url, let caption):
                DSChatMediaBubble(
                    imageURL: url,
                    caption: caption,
                    variant: message.isSentByCurrentUser ? .sender : .receiver,
                    timestamp: message.timestamp,
                    status: message.isSentByCurrentUser ? message.status : nil,
                    showAvatar: true,
                    avatarImage: message.senderAvatar,
                    avatarInitials: message.senderInitials
                )
            }
        }
    }

    private var groupedMessages: [(date: String, messages: [DSChatMessage])] {
        let grouped = Dictionary(grouping: messages) { $0.date }
        return grouped.map { (date: $0.key, messages: $0.value) }
            .sorted { $0.date < $1.date }
    }

    private func scrollToBottom() {
        guard let proxy = scrollProxy else { return }

        if !typingUsers.isEmpty {
            withAnimation {
                proxy.scrollTo("typing-indicator", anchor: .bottom)
            }
        } else if let lastMessage = messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Previews

#Preview("Group Chat View") {
    DSGroupChatView(
        groupName: "Design Team",
        members: [
            DSGroupChatMember(name: "Alice", initials: "AB", isOnline: true),
            DSGroupChatMember(name: "Bob", initials: "BC", isOnline: true),
            DSGroupChatMember(name: "Charlie", initials: "CD", isOnline: false),
            DSGroupChatMember(name: "Diana", initials: "DE", isOnline: true),
        ],
        messages: [
            DSChatMessage(
                message: "Hey everyone! How's the project going?",
                senderName: "Alice",
                senderInitials: "AB",
                timestamp: "9:00 AM",
                date: "Today",
                isSentByCurrentUser: false
            ),
            DSChatMessage(
                message: "Going great! Just finished the mockups",
                senderName: "Bob",
                senderInitials: "BC",
                timestamp: "9:02 AM",
                date: "Today",
                isSentByCurrentUser: false
            ),
            DSChatMessage(
                message: "Awesome! Can't wait to see them",
                senderName: "You",
                senderInitials: "ME",
                timestamp: "9:03 AM",
                date: "Today",
                isSentByCurrentUser: true,
                status: .read
            ),
            DSChatMessage(
                message: "I'll share the designs in a bit",
                senderName: "Bob",
                senderInitials: "BC",
                timestamp: "9:05 AM",
                date: "Today",
                isSentByCurrentUser: false
            ),
        ],
        typingUsers: ["Diana"]
    )
}

#Preview("Date Separator") {
    VStack {
        DSChatDateSeparator(date: "Today")
        DSChatDateSeparator(date: "Yesterday")
        DSChatDateSeparator(date: "Dec 10, 2025")
    }
    .padding()
}

#Preview("Typing Indicator") {
    VStack(spacing: .lg) {
        DSTypingIndicator(userNames: ["Alice"])
        DSTypingIndicator(userNames: ["Alice", "Bob"])
        DSTypingIndicator(userNames: ["Alice", "Bob", "Charlie"])
    }
    .padding()
}

#Preview("Group Member Avatars") {
    VStack(spacing: .lg) {
        DSGroupMemberAvatars(
            members: [
                DSGroupChatMember(name: "Alice", initials: "AB", isOnline: true),
                DSGroupChatMember(name: "Bob", initials: "BC", isOnline: true),
                DSGroupChatMember(name: "Charlie", initials: "CD", isOnline: false),
            ]
        )

        DSGroupMemberAvatars(
            members: [
                DSGroupChatMember(name: "Alice", initials: "AB", isOnline: true),
                DSGroupChatMember(name: "Bob", initials: "BC", isOnline: true),
                DSGroupChatMember(name: "Charlie", initials: "CD", isOnline: false),
                DSGroupChatMember(name: "Diana", initials: "DE", isOnline: true),
                DSGroupChatMember(name: "Eve", initials: "EF", isOnline: false),
                DSGroupChatMember(name: "Frank", initials: "FG", isOnline: true),
            ],
            maxVisible: 4
        )
    }
    .padding()
}
