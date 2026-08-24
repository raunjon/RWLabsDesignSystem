//
//  DSText.swift
//  RWLDesignSystem
//
//  Design system text component
//

import SwiftUI

public struct DSText: View {
    public let text: String
    public var style: DSTypography.Style = .body
    public var color: Color = .Text.primary

    public init(_ text: String, style: DSTypography.Style = .body, color: Color = .Text.primary) {
        self.text = text
        self.style = style
        self.color = color
    }

    public var body: some View {
        Text(text)
            .typography(style, color: color)
    }
}
