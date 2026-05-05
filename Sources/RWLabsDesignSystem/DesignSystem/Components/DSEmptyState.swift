//
//  DSEmptyState.swift
//  RWLDesignSystem
//
//  Empty state placeholder component
//

import SwiftUI

// MARK: - DSEmptyState

public struct DSEmptyState: View {

    // MARK: - Properties

    let icon: Image
    let title: String
    let description: String?
    let actionTitle: String?
    let action: (() -> Void)?

    // MARK: - Initialization

    public init(
        icon: Image,
        title: String,
        description: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: .lg) {
            // Icon
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.Text.tertiary)

            // Content
            VStack(spacing: .sm) {
                DSText(title, style: .title3, color: Color.Text.primary)
                    .multilineTextAlignment(.center)

                if let description = description {
                    DSText(description, style: .body, color: Color.Text.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Action button
            if let actionTitle = actionTitle, let action = action {
                DSButton(
                    title: actionTitle,
                    variant: .primary
                ) {
                    action()
                }
            }
        }
        .padding(.xxl)
        .frame(maxWidth: 400)
    }
}

// MARK: - Preview

#Preview("Empty State") {
    VStack(spacing: .xxl) {
        DSEmptyState(
            icon: Image(systemName: "tray.fill"),
            title: "No Items",
            description: "There are no items to display at the moment",
            actionTitle: "Add Item",
            action: { print("Add item tapped") }
        )

        Divider()

        DSEmptyState(
            icon: Image(systemName: "wifi.slash"),
            title: "No Connection",
            description: "Please check your internet connection and try again"
        )

        Divider()

        DSEmptyState(
            icon: Image(systemName: "magnifyingglass"),
            title: "No Results",
            description: "Try adjusting your search or filter criteria",
            actionTitle: "Clear Filters",
            action: { print("Clear filters") }
        )
    }
    .padding()
}
