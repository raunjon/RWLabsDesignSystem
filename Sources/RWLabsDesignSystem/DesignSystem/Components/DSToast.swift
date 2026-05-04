//
//  DSToast.swift
//  ThirtyPlusPanel
//
//  Created by Raunak Joneja on 29/03/26.
//

import SwiftUI

// MARK: - DSToast Component
public struct DSToast: View {
    let type: DSToastType
    var title: String?
    let message: String?
    @Binding var isShowing: Bool
    var onClose:() -> Void = { }

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
                    .foregroundColor(type.color)
                    .font(.system(size: 16))
                VStack(alignment: .leading, spacing: .s0) {
                    if let title {
                        Text(title)
                            .fontStyle(.subheadiline)
                            .foregroundColor(Color.Text.primary)
                            .padding(.bottom, .s2)
                    }
                    if let message {
                        Text(message)
                            .fontStyle(.bodySmall)
                            .foregroundColor(Color.Text.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()

                Button(action: { isShowing = false; onClose() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.Text.tertiary)
                        .font(.system(size: 12))
                }
            }
            .padding(.md)
            .background(Color.Background.primary)
            .cornerRadius(.md)
            .shadow(.md)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(), value: isShowing)
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
    let onClose:() -> Void

    public func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            ZStack {
                content
                
                VStack {
                    DSToast(type: type, title: title,  message: message, isShowing: $isShowing)
                        .padding(.horizontal, .md)
                        .padding(.top, .md)
                    Spacer()
                }
            }
            .onChange(of: isShowing) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isShowing = false
                            onClose()
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK: - View Extension for Toast
public extension View {
    func toast(
        isShowing: Binding<Bool>,
        type: DSToastType,
        title: String? = nil,
        message: String? = nil,
        duration: TimeInterval = 3.0,
        onClose: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(
            ToastModifier(
                isShowing: isShowing,
                type: type,
                title: title,
                message: message,
                duration: duration,
                onClose: onClose
            )
        )
    }
}

// MARK: - Preview
struct DSToast_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .sm) {
            // Toast example in a separate view would need state management
            Text("Toast appears at the top with auto-dismiss")
                .fontStyle(.caption)
                .foregroundColor(Color.Text.tertiary)
                .toast(isShowing: .constant(true), type: .success, title: "Test", message: "Toast appears at the top with auto-dismiss")
            Text("Toast appears at the top with auto-dismiss")
                .fontStyle(.caption)
                .foregroundColor(Color.Text.tertiary)
                .toast(isShowing: .constant(true), type: .error, message: "Test")
            Text("Toast appears at the top with auto-dismiss")
                .fontStyle(.caption)
                .foregroundColor(Color.Text.tertiary)
                .toast(isShowing: .constant(true), type: .warning, message: "Test")
            
            Text("Toast appears at the top with auto-dismiss")
                .fontStyle(.caption)
                .foregroundColor(Color.Text.tertiary)
                .toast(isShowing: .constant(true), type: .info, message: "Test")
        }
        .padding()
    }
}
