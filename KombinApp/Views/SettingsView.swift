//
//  SettingsView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageTracker: UsageTracker
    @State private var showPaywall = false
    @State private var showSubscriptionManagement = false
    
    init() {
        let subscriptionManager = SubscriptionManager()
        self._usageTracker = StateObject(wrappedValue: UsageTracker(subscriptionManager: subscriptionManager))
    }
    
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
                            // Premium Subscription Section
                            SettingsSection(
                                title: isEnglish ? "Premium Subscription" : "Premium Abonelik",
                                icon: "crown.fill"
                            ) {
                                SubscriptionStatusView(
                                    subscriptionManager: subscriptionManager,
                                    usageTracker: usageTracker,
                                    isEnglish: isEnglish,
                                    showPaywall: $showPaywall,
                                    showSubscriptionManagement: $showSubscriptionManagement
                                )
                            }
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
        .sheet(isPresented: $showPaywall) {
            ClosAIPremiumView()
        }
        .sheet(isPresented: $showSubscriptionManagement) {
            SubscriptionManagementView()
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
// MARK: - Subscription Status View
struct SubscriptionStatusView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @ObservedObject var usageTracker: UsageTracker
    let isEnglish: Bool
    @Binding var showPaywall: Bool
    @Binding var showSubscriptionManagement: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            if subscriptionManager.subscriptionStatus.isPremium {
                // Premium Status
                premiumStatusView
            } else {
                // Free Status
                freeStatusView
            }
        }
    }
    
    private var premiumStatusView: some View {
        VStack(spacing: 15) {
            // Premium Badge
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("PREMIUM ACTIVE")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            
            // Subscription Details
            if case .premium(let expiryDate, let type) = subscriptionManager.subscriptionStatus {
                VStack(spacing: 10) {
                    HStack {
                        Text(isEnglish ? "Plan" : "Plan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(type.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text(isEnglish ? "Renewal Date" : "Yenileme Tarihi")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(DateFormatter.shortDate.string(from: expiryDate))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // Manage Subscription Button
            Button(isEnglish ? "Manage Subscription" : "Aboneliği Yönet") {
                showSubscriptionManagement = true
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color(hex: "d291bc"))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(hex: "d291bc").opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var freeStatusView: some View {
        VStack(spacing: 15) {
            // Usage Statistics
            VStack(spacing: 12) {
                HStack {
                    Text(isEnglish ? "Current Usage" : "Mevcut Kullanım")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                let stats = usageTracker.getUsageStatistics()
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "tshirt.fill")
                            .foregroundColor(.blue)
                        Text(isEnglish ? "Clothing Items" : "Kıyafet Parçası")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(stats.clothingUsageText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text(isEnglish ? "Daily Outfits" : "Günlük Kombin")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(stats.outfitUsageText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Premium Features List
            VStack(spacing: 8) {
                HStack {
                    Text(isEnglish ? "Premium Features" : "Premium Özellikler")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                ForEach(Array(PremiumFeature.allCases.prefix(3)), id: \.self) { feature in
                    HStack {
                        Image(systemName: feature.iconName)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(feature.displayName)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Upgrade Button
            Button(isEnglish ? "Upgrade to Premium" : "Premium'a Geç") {
                showPaywall = true
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color.pink, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Subscription Management View
struct SubscriptionManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Abonelik Yönetimi")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 30)
                
                // Current Subscription Info
                if case .premium(let expiryDate, let type) = subscriptionManager.subscriptionStatus {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Text("Aktif Plan: \(type.displayName)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Yenileme Tarihi: \(DateFormatter.longDate.string(from: expiryDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        
                        // Management Options
                        VStack(spacing: 15) {
                            Button("App Store'da Aboneliği Yönet") {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                            
                            Button("Satın Alımları Geri Yükle") {
                                Task {
                                    await subscriptionManager.restorePurchases()
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .disabled(subscriptionManager.isLoading)
                        }
                    }
                }
                
                Spacer()
                
                // Info Text
                Text("Aboneliğinizi iptal etmek veya değiştirmek için App Store ayarlarını kullanın. Abonelik mevcut dönem sonuna kadar aktif kalacaktır.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}