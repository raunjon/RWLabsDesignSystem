//
//  DSActionSheet.swift
//  RWLDesignSystem
//
//  Bottom sheet with action buttons
//

import SwiftUI

// MARK: - DSActionSheet

public struct DSActionSheet: View {
    @Binding var isPresented: Bool

    let title: String?
    let message: String?
    let actions: [ActionItem]

    public init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        actions: [ActionItem]
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.actions = actions
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            if title != nil || message != nil {
                VStack(spacing: .xs) {
                    if let title = title {
                        DSText(title, style: .heading3, color: .Text.primary)
                    }

                    if let message = message {
                        DSText(message, style: .bodySmallMedium, color: .Text.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.lg)

                Divider()
            }

            // Actions
            ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                if action.role != .cancel {
                    Button(action: {
                        action.action()
                        if !action.keepSheetOpen {
                            isPresented = false
                        }
                    }) {
                        HStack(spacing: .sm) {
                            if let icon = action.icon {
                                icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(action.role == .destructive ? Color.Semantic.error : Color.Text.primary)
                            }

                            DSText(action.title, style: .body, color: action.role == .destructive ? .Semantic.error : .Text.primary)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.md)
                        .background(Color.Background.primary)
                    }
                    .disabled(action.isDisabled)
                    .opacity(action.isDisabled ? 0.5 : 1.0)
                    
                    if index < actions.count - 1 {
                        Divider()
                    }
                }
            }

            // Cancel button
            if let cancelAction = actions.first(where: { $0.role == .cancel }) {
                Divider()
                    .padding(.vertical, .xs)

                Button(action: {
                    cancelAction.action()
                    if !cancelAction.keepSheetOpen {
                        isPresented = false
                    }
                }) {
                    DSText(cancelAction.title, style: .body, color: .Semantic.error)
                        .frame(maxWidth: .infinity)
                        .padding(.md)
                        .background(Color.Background.primary)
                }
            }
        }
        .cornerRadius(.radiusMD)
        .shadow(.sm)
    }

    public struct ActionItem {
        public let title: String
        public let icon: Image?
        public let role: ActionRole
        public let isDisabled: Bool
        public let keepSheetOpen: Bool
        public let action: () -> Void

        public init(
            title: String,
            icon: Image? = nil,
            role: ActionRole = .default,
            isDisabled: Bool = false,
            keepSheetOpen: Bool = false,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.role = role
            self.isDisabled = isDisabled
            self.keepSheetOpen = keepSheetOpen
            self.action = action
        }
    }

    public enum ActionRole {
        case `default`
        case destructive
        case cancel
    }
}

// MARK: - View Modifier

public extension View {
    func actionSheet(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        actions: [DSActionSheet.ActionItem]
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            DSActionSheet(
                isPresented: isPresented,
                title: title,
                message: message,
                actions: actions
            )
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var showSheet = true

        var body: some View {
            VStack(spacing: .lg) {
                DSButton(title: "Show Action Sheet", variant: .primary) {
                    showSheet = true
                }

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showSheet) {
                DSActionSheet(
                    isPresented: $showSheet,
                    title: "Delete Item",
                    message: "This action cannot be undone",
                    actions: [
                        .init(
                            title: "Delete",
                            icon: Image(systemName: "trash"),
                            role: .destructive,
                            action: { print("Deleted") }
                        ),
                        .init(
                            title: "Archive",
                            icon: Image(systemName: "archivebox"),
                            action: { print("Archived") }
                        ),
                        .init(
                            title: "Cancel",
                            role: .cancel,
                            action: { print("Cancelled") }
                        )
                    ]
                )
                .presentationDetents([.medium])
            }
        }
    }

    return PreviewWrapper()
}
