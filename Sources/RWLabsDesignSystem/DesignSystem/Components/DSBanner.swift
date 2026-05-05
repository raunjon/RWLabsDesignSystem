//
//  DSBanner.swift
//  RWLabsDesignSystem
//
//  Created by Raunak Joneja on 29/03/26.
//

import SwiftUI

// MARK: - Banner Alert
public struct DSBanner: View {
    let type: DSToastType
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    public init(
        type: DSToastType,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(spacing: .md) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .fontStyle(.title3)

            DSText(message, style: .bodyMedium, color: .Text.primary)
                .lineLimit(2)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    DSText(actionTitle, style: .bodySmall, color: type.color)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.md)
        .background(type.backgroundColor)
    }
}

// MARK: - Preview
struct DSBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .lg) {
            DSBanner(
                type: .info,
                message: "Enable notifications to stay up to date",
                actionTitle: "Enable",
                action: {}
            )
        }
        .padding()
    }
}
