//
//  MainTabView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var clothingStore = ClothingStore()
    @StateObject private var appSettings = AppSettings()
    
    var body: some View {
        TabView {
            GenerateOutfitView()
                .environmentObject(clothingStore)
                .environmentObject(appSettings)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text(appSettings.language == .english ? "Generate Outfit" : "Kombin Oluştur")
                }
            
            MyClosetView()
                .environmentObject(clothingStore)
                .environmentObject(appSettings)
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text(appSettings.language == .english ? "My Closet" : "Dolabım")
                }
            
            SettingsView()
                .environmentObject(appSettings)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(appSettings.language == .english ? "Settings" : "Ayarlar")
                }
        }
        .accentColor(Color(hex: "d291bc"))
        .preferredColorScheme(appSettings.colorScheme)
    }
}

#Preview {
    MainTabView()
}