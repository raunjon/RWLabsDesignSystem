//
//  DSAlert.swift
//  RWLDesignSystem
//
//  Design system alert and toast components
//

import SwiftUI

// MARK: - Alert Type
public enum DSToastType {
    case success
    case error
    case warning
    case info

    @MainActor
    var color: Color {
        switch self {
        case .success:
            return Color.Semantic.success
        case .error:
            return Color.Semantic.error
        case .warning:
            return Color.Semantic.warning
        case .info:
            return Color.Semantic.info
        }
    }

    @MainActor
    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.Semantic.success.opacity(0.1)
        case .error:
            return Color.Semantic.error.opacity(0.1)
        case .warning:
            return Color.Semantic.warning.opacity(0.1)
        case .info:
            return Color.Semantic.info.opacity(0.1)
        }
    }

    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
}

// MARK: - DSAlert Component
public struct DSAlert: View {
    let type: DSToastType
    let title: String
    let message: String?
    let showCloseButton: Bool
    let onClose: (() -> Void)?

    public init(
        type: DSToastType,
        title: String,
        message: String? = nil,
        showCloseButton: Bool = false,
        onClose: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.showCloseButton = showCloseButton
        self.onClose = onClose
    }

    public var body: some View {
        HStack(alignment: .top, spacing: .md) {
            // Icon
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.system(size: 20))

            // Content
            VStack(alignment: .leading, spacing: .xxs) {
                DSText(title, style: .bodyMedium, color: .Text.primary)
                    .fontWeight(.semibold)

                if let message = message {
                    DSText(message, style: .bodySmall, color: .Text.secondary)
                }
            }

            Spacer()

            // Close Button
            if showCloseButton {
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.Text.tertiary)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(DSSpacing.Component.alertPadding)
        .background(type.backgroundColor)
        .cornerRadius(.radiusMD)
        .border(type.color.opacity(0.3), lineWidth: .thin, cornerRadius: .radiusMD)
    }
}

// MARK: - Preview
struct DSAlert_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .lg) {
            DSAlert(
                type: .success,
                title: "Success!",
                message: "Your changes have been saved successfully."
            )

            DSAlert(
                type: .error,
                title: "Error",
                message: "Something went wrong. Please try again.",
                showCloseButton: true,
                onClose: {}
            )

            DSAlert(
                type: .warning,
                title: "Warning",
                message: "This action cannot be undone."
            )

            DSAlert(
                type: .info,
                title: "Information",
                message: "New features are available in this version."
            )
        }
        .padding()
    }
}
