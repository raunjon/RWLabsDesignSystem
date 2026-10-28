//
//  DSToast.swift
//  RWLabsDesignSystem
//
//  Top toast with an icon, title, message and close button. There is no Figma design; it uses
//  the option dropdown's raised card (surface, 16pt corners, soft shadow) and the Figma type scale.
//
//  content.toast(isShowing: $saved, type: .success, title: "Saved", message: "Your profile is updated")
//

import SwiftUI

// MARK: - DSToast
public struct DSToast: View {
    let type: DSToastType
    let title: String?
    let message: String?
    @Binding var isShowing: Bool
    let onClose: () -> Void

    public init(
        type: DSToastType,
        title: String?,
        message: String?,
        isShowing: Binding<Bool>,
        onClose: @escaping () -> Void = {}
    ) {
        self.type = type
        self.title = title
        self.message = message
        self._isShowing = isShowing
        self.onClose = onClose
    }

    public var body: some View {
        if isShowing {
            HStack(spacing: .sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(type.color)

                VStack(alignment: .leading, spacing: .xxs) {
                    if let title {
                        Text(title)
                            .fontStyle(.bodyMedium)
                            .foregroundColor(.Text.primary)
                    }
                    if let message {
                        Text(message)
                            .fontStyle(.bodySmall)
                            .foregroundColor(.Text.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    withAnimation { isShowing = false }
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.Input.icon)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle().inset(by: -10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, .md)
            .padding(.vertical, .sm)
            .background(
                RoundedRectangle(cornerRadius: .radiusLG)
                    .fill(DSOptionDropdown.surface)
                    .shadow(color: .black.opacity(0.25), radius: 9)
            )
            .accessibilityElement(children: .combine)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Toast Modifier
public struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let type: DSToastType
    let title: String?
    let message: String?
    let duration: TimeInterval
    let onClose: () -> Void

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                DSToast(type: type, title: title, message: message, isShowing: $isShowing, onClose: onClose)
                    .padding(.horizontal, .md)
                    .padding(.top, .md)
            }
            .animation(.spring(duration: 0.35), value: isShowing)
            .task(id: isShowing) {
                // Restarts whenever the toast reappears; cancelled if it is closed early
                guard isShowing else { return }
                try? await Task.sleep(for: .seconds(duration))
                guard !Task.isCancelled else { return }
                isShowing = false
                onClose()
            }
    }
}

// MARK: - View Extension
public extension View {
    func toast(
        isShowing: Binding<Bool>,
        type: DSToastType,
        title: String? = nil,
        message: String? = nil,
        duration: TimeInterval = 3.0,
        onClose: @escaping () -> Void = {}
    ) -> some View {
        modifier(ToastModifier(
            isShowing: isShowing,
            type: type,
            title: title,
            message: message,
            duration: duration,
            onClose: onClose
        ))
    }
}

// MARK: - Preview
private struct DSToastGallery: View {
    @State private var isShowing = false

    var body: some View {
        VStack(spacing: .sm) {
            DSToast(type: .success, title: "Saved", message: "Your profile is updated", isShowing: .constant(true))
            DSToast(type: .error, title: nil, message: "Something went wrong. Try again.", isShowing: .constant(true))
            DSToast(type: .warning, title: "Heads up", message: nil, isShowing: .constant(true))
            DSToast(type: .info, title: "New feature", message: "You can now add up to 6 photos", isShowing: .constant(true))

            Button("Show toast") { isShowing = true }
                .primaryButtonStyle(size: .medium)
                .padding(.top, .lg)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.Background.primary)
        .toast(isShowing: $isShowing, type: .success, title: "Saved", message: "Auto-dismisses after 3 seconds")
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSToastGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSToastGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSToastGallery().designSystem()
}
