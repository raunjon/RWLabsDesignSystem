//
//  DSActionSheet.swift
//  RWLabsDesignSystem
//
//  Bottom sheet. There is no Figma design; it borrows the popup cards' look: 28pt corners,
//  heading + message, round ✕, dark buttons. Built on the system sheet, so drag-to-dismiss,
//  detents and the keyboard work as usual.
//
//  Your own content:
//
//  .dsBottomSheet(isPresented: $showFilters, title: "Filters") {
//      Toggle("Verified only", isOn: $verified)
//      Button("Apply") { apply() }.primaryButtonStyle()
//  }
//
//  A list of actions:
//
//  .actionSheet(isPresented: $showMenu, title: "Photo", actions: [
//      .init(title: "Delete", icon: Image(systemName: "trash"), role: .destructive) { delete() },
//      .init(title: "Cancel", role: .cancel) {},
//  ])
//

import SwiftUI

// MARK: - Bottom Sheet
/// The sheet's layout: optional header, then your content. Present it with `.dsBottomSheet`.
public struct DSBottomSheet<Content: View>: View {
    let title: String?
    let message: String?
    let showsCloseButton: Bool
    let content: Content

    @Environment(\.dismiss) private var dismiss

    public init(
        title: String? = nil,
        message: String? = nil,
        showsCloseButton: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.message = message
        self.showsCloseButton = showsCloseButton
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .lg) {
            if title != nil || message != nil || showsCloseButton {
                header
            }
            content
        }
        .padding(.horizontal, .lg)
        .padding(.top, .lg)
        .padding(.bottom, .md)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: .md) {
            VStack(alignment: .leading, spacing: .xs) {
                if let title {
                    Text(title)
                        .fontStyle(.heading3)
                        .foregroundColor(.Popup.title)
                        .accessibilityAddTraits(.isHeader)
                }
                if let message {
                    Text(message)
                        .fontStyle(.bodySmall)
                        .foregroundColor(.Popup.message)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsCloseButton {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.Popup.closeIcon)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.Popup.closeFill))
                        .contentShape(Circle().inset(by: -10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
        }
    }
}

// MARK: - Presentation
private struct DSBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>?
    let onDismiss: (() -> Void)?
    let sheet: SheetContent

    /// Measured height for the fit-to-content detent
    @State private var fittedHeight: CGFloat = 300

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            sheet
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fittedHeight = $0 }
                .frame(maxHeight: .infinity, alignment: .top)
                .presentationDetents(detents ?? [.height(fittedHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Self.cornerRadius)
                .presentationBackground(Color.Popup.card)
        }
    }

    /// Figma "Corner/Extra-large", as on the popup cards
    static var cornerRadius: CGFloat { 28 }
}

public extension View {
    /// Presents a bottom sheet with your own content.
    /// - Parameter detents: Sheet heights; `nil` fits the sheet to its content.
    func dsBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        showsCloseButton: Bool = true,
        detents: Set<PresentationDetent>? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(DSBottomSheetModifier(
            isPresented: isPresented,
            detents: detents,
            onDismiss: onDismiss,
            sheet: DSBottomSheet(title: title, message: message, showsCloseButton: showsCloseButton, content: content)
        ))
    }
}

// MARK: - Action Sheet
/// A bottom sheet of action rows, with an optional cancel button underneath.
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

    private var rows: [ActionItem] { actions.filter { $0.role != .cancel } }
    private var cancel: ActionItem? { actions.first { $0.role == .cancel } }

    public var body: some View {
        DSBottomSheet(title: title, message: message, showsCloseButton: false) {
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Rectangle().fill(Color.Border.subtle).frame(height: .thin)
                    }
                    row(item)
                }
            }

            if let cancel {
                Button(cancel.title) { run(cancel) }
                    .secondaryButtonStyle()
            }
        }
    }

    private func row(_ item: ActionItem) -> some View {
        let tint: Color = item.role == .destructive ? .Semantic.error : .Popup.title
        return Button { run(item) } label: {
            HStack(spacing: .sm) {
                if let icon = item.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Text(item.title)
                    .fontStyle(.body)
                Spacer(minLength: 0)
            }
            .foregroundColor(tint)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        .opacity(item.isDisabled ? 0.5 : 1)
    }

    private func run(_ item: ActionItem) {
        item.action()
        if !item.keepSheetOpen { isPresented = false }
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

public extension View {
    /// Presents `DSActionSheet`, sized to its rows.
    func actionSheet(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        actions: [DSActionSheet.ActionItem]
    ) -> some View {
        modifier(DSBottomSheetModifier(
            isPresented: isPresented,
            detents: nil,
            onDismiss: nil,
            sheet: DSActionSheet(isPresented: isPresented, title: title, message: message, actions: actions)
        ))
    }
}

// MARK: - Preview
/// The sheet bodies inline (sheets don't show in a static canvas), then buttons that present them.
private struct DSActionSheetGallery: View {
    @State private var showsFilters = false
    @State private var showsActions = false
    @State private var verified = true
    @State private var distance = "Nearby"

    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                filters
                    .background(RoundedRectangle(cornerRadius: 28).fill(Color.Popup.card))
                actionSheet(isPresented: .constant(true))
                    .background(RoundedRectangle(cornerRadius: 28).fill(Color.Popup.card))

                Button("Show filters sheet") { showsFilters = true }.primaryButtonStyle(size: .medium)
                Button("Show action sheet") { showsActions = true }.secondaryButtonStyle(size: .medium)
            }
            .padding()
        }
        .background(Color.Background.secondary)
        .dsBottomSheet(isPresented: $showsFilters, title: "Filters", message: "Show people who match") {
            filterControls
        }
        .actionSheet(isPresented: $showsActions, title: "Photo", actions: actions)
    }

    private var filters: some View {
        DSBottomSheet(title: "Filters", message: "Show people who match") { filterControls }
    }

    @ViewBuilder
    private var filterControls: some View {
        HStack(spacing: .sm) {
            ForEach(["Nearby", "City", "Anywhere"], id: \.self) { option in
                Toggle(option, isOn: Binding(get: { distance == option }, set: { if $0 { distance = option } }))
                    .pillStyle()
            }
        }
        Toggle("Verified profiles only", isOn: $verified)
            .fontStyle(.body)
            .tint(.Icon.brand)
        Button("Apply") { showsFilters = false }.primaryButtonStyle()
    }

    private func actionSheet(isPresented: Binding<Bool>) -> some View {
        DSActionSheet(isPresented: isPresented, title: "Photo", actions: actions)
    }

    private var actions: [DSActionSheet.ActionItem] {
        [
            .init(title: "Set as main photo", icon: Image(systemName: "star")) {},
            .init(title: "Replace", icon: Image(systemName: "arrow.triangle.2.circlepath")) {},
            .init(title: "Delete", icon: Image(systemName: "trash"), role: .destructive) {},
            .init(title: "Cancel", role: .cancel) {},
        ]
    }
}

#Preview("RWLabs") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSActionSheetGallery().designSystem()
}

#Preview("RWLabs Dark") {
    DesignSystem.configure(theme: RWLabsTheme())
    return DSActionSheetGallery().designSystem().preferredColorScheme(.dark)
}

#Preview("BW") {
    DesignSystem.configure(theme: BWTheme())
    return DSActionSheetGallery().designSystem()
}
