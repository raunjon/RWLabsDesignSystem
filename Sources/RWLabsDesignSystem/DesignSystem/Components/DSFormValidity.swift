//
//  DSFormValidity.swift
//  RWLabsDesignSystem
//
//  Collects whether every validated field in a form passes, e.g. to disable a submit button.
//

import SwiftUI

/// `true` only while every `DSTextField` with a `validate` closure below it is valid
public struct DSFormValidityKey: PreferenceKey {
    public static let defaultValue = true

    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value && nextValue()
    }
}

public extension View {
    /// Writes whether every validated `DSTextField` inside this view passes into `isValid`
    ///
    /// ```swift
    /// VStack {
    ///     DSTextField(text: $email, label: "Email", validate: { $0.contains("@") ? nil : "Invalid email" })
    ///     Button("Continue") { ... }.disabled(!isValid)
    /// }
    /// .formValidity($isValid)
    /// ```
    func formValidity(_ isValid: Binding<Bool>) -> some View {
        onPreferenceChange(DSFormValidityKey.self) { [isValid] in isValid.wrappedValue = $0 }
    }
}
