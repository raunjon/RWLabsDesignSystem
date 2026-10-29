//
//  DSPopupCard.swift
//  RWLabsDesignSystem
//
//  Popup card matching the Figma "Popup cards" (camera access, oops, upload failed, ID expired,
//  sure to exit…): illustration, centered title and message, one or two buttons, optional ✕.
//  Each Figma card is this component with its own illustration and copy, so the app supplies both.
//
//  content.dsPopup(isPresented: $showExit) {
//      DSPopupCard(
//          title: "Sure to exit?",
//          message: "Your progress will remain unsaved",
//          primaryAction: .init("Cancel") { showExit = false },
//          secondaryAction: .init("Exit", variant: .secondary) { exit() }
//      ) {
//          Image("exit-illustration")
//      }
//  }
//

import SwiftUI

// MARK: - Popup Action
public struct DSPopupAction {
    public let title: String
    public let variant: DSButtonVariant
    public let action: () -> Void

    /// Figma popups use the dark `.inverse` button; pair it with `.secondary` for the gray one.
    public init(_ title: String, variant: DSButtonVariant = .inverse, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.action = action
    }
}

// MARK: - Popup Card
public struct DSPopupCard<Illustration: View>: View {
    public enum TextSize: Sendable {
        /// 24px title, 16px message (newer Figma cards)
        case regular
        /// 20px title, 14px message (camera access, upload failed, ID expired…)
        case compact
    }

    let title: String
    let message: String?
    let primaryAction: DSPopupAction
    let secondaryAction: DSPopupAction?
    let textSize: TextSize
    let onClose: (() -> Void)?
    let illustration: Illustration

    /// - Parameters:
    ///   - secondaryAction: Shown to the left of the primary button.
    ///   - onClose: Shows the ✕ in the top-right corner when set.
    public init(
        title: String,
        message: String? = nil,
        primaryAction: DSPopupAction,
        secondaryAction: DSPopupAction? = nil,
        textSize: TextSize = .regular,
        onClose: (() -> Void)? = nil,
        @ViewBuilder illustration: () -> Illustration
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.textSize = textSize
        self.onClose = onClose
        self.illustration = illustration()
    }

    private static var cornerRadius: CGFloat { 28 } // Figma "Corner/Extra-large"

    public var body: some View {
        VStack(spacing: .s20) {
            illustration
                .frame(maxHeight: 100)

            VStack(spacing: .sm) {
                Text(title)
                    .fontStyle(textSize == .regular ? .heading2 : .heading3)
                    .foregroundColor(.Popup.title)
                if let message {
                    Text(message)
                        .fontStyle(textSize == .regular ? .body : .bodySmall)
                        .foregroundColor(.Popup.message)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .multilineTextAlignment(.center)

            HStack(spacing: .md) {
                if let secondaryAction {
                    button(secondaryAction)
                }
                button(primaryAction)
            }
            .padding(.top, .xxs)
        }
        .padding(.horizontal, .lg)
        .padding(.vertical, .s40)
        .frame(maxWidth: 340)
        .background(
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(Color.Popup.card)
                .shadow(color: .black.opacity(0.25), radius: 1.5, y: 1)
        )
        .overlay(alignment: .topTrailing) {
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.Popup.closeIcon)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.Popup.closeFill))
                        .contentShape(Circle().inset(by: -10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
                .padding(.s20)
            }
        }
    }

    private func button(_ action: DSPopupAction) -> some View {
        Button(action.title, action: action.action)
            .dsButtonStyle(action.variant, size: .large)
    }
}

public extension DSPopupCard where Illustration == EmptyView {
    /// A card without an illustration.
    init(
        title: String,
        message: String? = nil,
        primaryAction: DSPopupAction,
        secondaryAction: DSPopupAction? = nil,
        textSize: TextSize = .regular,
        onClose: (() -> Void)? = nil
    ) {
        self.init(title: title, message: message, primaryAction: primaryAction, secondaryAction: secondaryAction,
                  textSize: textSize, onClose: onClose) { EmptyView() }
    }
}

// MARK: - Presentation
private struct DSPopupModifier<Card: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dismissesOnBackgroundTap: Bool
    let card: Card

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.Popup.scrim
                            .ignoresSafeArea()
                            .onTapGesture { if dismissesOnBackgroundTap { isPresented = false } }
                            .transition(.opacity)
                        card
                            .padding(.horizontal, .md)
                            .transition(.scale(scale: 0.92).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(duration: 0.3), value: isPresented)
    }
}

public extension View {
    /// Shows a popup card centered over a dimmed page.
    func dsPopup<Card: View>(
        isPresented: Binding<Bool>,
        dismissesOnBackgroundTap: Bool = false,
        @ViewBuilder card: () -> Card
    ) -> some View {
        modifier(DSPopupModifier(isPresented: isPresented, dismissesOnBackgroundTap: dismissesOnBackgroundTap, card: card()))
    }
}

// MARK: - Preview
/// Three Figma cards with SF Symbol stand-ins for the illustrations, then a live popup.
private struct DSPopupCardGallery: View {
    @State private var showsPopup = false

    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                DSPopupCard(
                    title: "Camera access needed",
                    message: "We need access to your camera to take verification photos.",
                    primaryAction: .init("Allow camera access") {},
                    textSize: .compact,
                    onClose: {}
                ) {
                    Image(systemName: "camera.fill").resizable().scaledToFit().frame(width: 80)
                        .foregroundColor(.Semantic.error)
                }

                DSPopupCard(
                    title: "Sure to exit?",
                    message: "Your progress will remain unsaved",
                    primaryAction: .init("Cancel") {},
                    secondaryAction: .init("Exit", variant: .secondary) {}
                ) {
                    Image(systemName: "door.left.hand.open").resizable().scaledToFit().frame(width: 64)
                        .foregroundColor(.Semantic.error)
                }

                DSPopupCard(title: "Oops", message: "Add at least 2 photos to continue", primaryAction: .init("Okay") {})

                Button("Show popup") { showsPopup = true }.primaryButtonStyle(size: .medium)
            }
            .padding()
        }
        .background(Color.Background.primary)
        .dsPopup(isPresented: $showsPopup, dismissesOnBackgroundTap: true) {
            DSPopupCard(title: "Connection lost",
                        message: "Your network is unavailable. Check your data or Wi-Fi connection",
                        primaryAction: .init("Retry") { showsPopup = false })
        }
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSPopupCardGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSPopupCardGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSPopupCardGallery().designSystem()
}
