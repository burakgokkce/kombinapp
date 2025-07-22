//
//  SettingsView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    private var isEnglish: Bool {
        appSettings.language == .english
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(hex: "ffb6c1").opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "d291bc"))
                            
                            Text(isEnglish ? "Settings" : "Ayarlar")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "d291bc"))
                        }
                        .padding(.top, 20)
                        
                        // Settings sections
                        VStack(spacing: 25) {
                            // Theme Settings
                            SettingsSection(title: isEnglish ? "Appearance" : "Görünüm", icon: "paintbrush.fill") {
                                VStack(spacing: 15) {
                                    HStack {
                                        Text(isEnglish ? "Theme Mode" : "Tema Modu")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 10) {
                                        ForEach(ThemeMode.allCases, id: \.self) { theme in
                                            ThemeOptionView(
                                                theme: theme,
                                                isSelected: appSettings.themeMode == theme
                                            ) {
                                                appSettings.themeMode = theme
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Language Settings
                            SettingsSection(title: isEnglish ? "Language" : "Dil", icon: "globe") {
                                VStack(spacing: 15) {
                                    HStack {
                                        Text(isEnglish ? "App Language" : "Uygulama Dili")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 10) {
                                        ForEach(AppLanguage.allCases, id: \.self) { language in
                                            LanguageOptionView(
                                                language: language,
                                                isSelected: appSettings.language == language
                                            ) {
                                                appSettings.language = language
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // App Info
                            SettingsSection(title: isEnglish ? "About" : "Hakkında", icon: "info.circle.fill") {
                                VStack(spacing: 15) {
                                    // App Version
                                    HStack {
                                        Text(isEnglish ? "App Version" : "Uygulama Sürümü")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(appSettings.appVersion)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Divider()
                                    
                                    // Developer Contact
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(isEnglish ? "Developer Contact" : "Geliştirici İletişim")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Button(action: {
                                                if let url = URL(string: "mailto:\(appSettings.developerEmail)") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }) {
                                                Text(appSettings.developerEmail)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(hex: "d291bc"))
                                                    .underline()
                                            }
                                        }
                                        Spacer()
                                        
                                        Image(systemName: "envelope.fill")
                                            .font(.title2)
                                            .foregroundColor(Color(hex: "d291bc"))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: "d291bc"))
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "d291bc"))
                
                Spacer()
            }
            
            // Section content
            VStack(spacing: 15) {
                content
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

struct ThemeOptionView: View {
    let theme: ThemeMode
    let isSelected: Bool
    let action: () -> Void
    
    var themeColors: [Color] {
        switch theme {
        case .light:
            return [.white, .gray.opacity(0.1)]
        case .dark:
            return [.black, .gray]
        case .auto:
            return [Color(hex: "ffb6c1"), Color(hex: "d291bc")]
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Theme preview
                HStack(spacing: 5) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(themeColors[index])
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Text(theme.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: "d291bc"))
                }
            }
            .padding()
            .background(isSelected ? Color(hex: "ffb6c1").opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "d291bc") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct LanguageOptionView: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    
    var flagEmoji: String {
        switch language {
        case .english:
            return "🇺🇸"
        case .turkish:
            return "🇹🇷"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(flagEmoji)
                    .font(.title2)
                
                Text(language.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: "d291bc"))
                }
            }
            .padding()
            .background(isSelected ? Color(hex: "ffb6c1").opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "d291bc") : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}