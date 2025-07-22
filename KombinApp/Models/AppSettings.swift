//
//  AppSettings.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case auto = "Auto"
}

enum AppLanguage: String, CaseIterable {
    case english = "English"
    case turkish = "Türkçe"
    
    var code: String {
        switch self {
        case .english: return "en"
        case .turkish: return "tr"
        }
    }
}

class AppSettings: ObservableObject {
    @Published var themeMode: ThemeMode = .auto
    @Published var language: AppLanguage = .english
    
    let appVersion = "1.0.0"
    let developerEmail = "contact@ybdigitall.com"
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}