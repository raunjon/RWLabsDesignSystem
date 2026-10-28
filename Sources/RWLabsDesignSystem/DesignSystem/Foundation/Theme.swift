//
//  Theme.swift
//  RWLDesignSystem
//
//  Theming system for customizable colors and typography.
//  Colors live in Foundation/Colors; a theme pairs a DSColorPalette with a typography scale.
//
//  Setup in the app:
//
//  @main
//  struct MyApp: App {
//      init() { DesignSystem.configure(theme: RWLabsTheme()) }
//
//      var body: some Scene {
//          WindowGroup {
//              ContentView()
//                  .designSystem()
//          }
//      }
//  }
//

import SwiftUI

// MARK: - Theme Protocol
@MainActor
public protocol DSTheme {
    var colors: any DSColorPalette { get set }
    var typography: any DSTypographyScale { get set }
    var name: String { get }
}

// MARK: - Design System Manager
@MainActor
public class DesignSystem: ObservableObject {
    @MainActor
    public static let shared = DesignSystem()

    @Published public var currentTheme: any DSTheme {
        didSet { revision += 1 }
    }

    /// Bumped on every theme change; `.designSystem()` uses it to rebuild the view tree.
    @Published private(set) var revision = 0

    private init() {
        self.currentTheme = DefaultTheme()
    }

    /// Configure the design system with a custom theme
    @MainActor
    public static func configure(theme: any DSTheme) {
        shared.currentTheme = theme
    }

    /// Replace the current theme's typography, keeping its colors
    @MainActor
    public static func configure(typography: any DSTypographyScale) {
        shared.currentTheme.typography = typography
    }

    /// Replace the current theme's colors, keeping its typography
    @MainActor
    public static func configure(colors: any DSColorPalette) {
        shared.currentTheme.colors = colors
    }

    /// Get the current theme
    @MainActor
    public static var theme: any DSTheme {
        shared.currentTheme
    }
}

// MARK: - Root Modifier
/// Applies theme changes and the saved color scheme preference to the whole app.
private struct DesignSystemRootModifier: ViewModifier {
    @ObservedObject private var designSystem = DesignSystem.shared
    @ObservedObject private var schemeManager = DSColorSchemeManager.shared

    func body(content: Content) -> some View {
        content
            // Components read colors and fonts statically, so a theme change rebuilds the tree.
            .id(designSystem.revision)
            .preferredColorScheme(schemeManager.selectedScheme.colorScheme)
    }
}

public extension View {
    /// Attach once at the app's root. Re-renders the app when the theme changes and applies
    /// the light/dark preference from `DSColorSchemeManager`.
    ///
    /// Changing the theme rebuilds the view tree, so `@State` below this modifier resets.
    @MainActor
    func designSystem() -> some View {
        modifier(DesignSystemRootModifier())
    }
}
