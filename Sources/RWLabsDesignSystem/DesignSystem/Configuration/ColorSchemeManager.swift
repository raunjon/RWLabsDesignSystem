//
//  ColorSchemeManager.swift
//  RWLabsDesignSystem
//
//  Manages the application's color scheme preference (light, dark, or system)
//

import SwiftUI

// MARK: - Color Scheme Options
public enum DSColorSchemePreference: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    public var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Color Scheme Manager
@MainActor
public class DSColorSchemeManager: ObservableObject {
    @Published public var selectedScheme: DSColorSchemePreference {
        didSet {
            UserDefaults.standard.set(selectedScheme.rawValue, forKey: userDefaultsKey)
        }
    }

    private let userDefaultsKey = "DSColorSchemePreference"

    public static let shared = DSColorSchemeManager()

    private init() {
        if let savedScheme = UserDefaults.standard.string(forKey: userDefaultsKey),
           let scheme = DSColorSchemePreference(rawValue: savedScheme) {
            self.selectedScheme = scheme
        } else {
            self.selectedScheme = .system
        }
    }

    /// Set the color scheme preference
    public func setScheme(_ scheme: DSColorSchemePreference) {
        selectedScheme = scheme
    }
}
