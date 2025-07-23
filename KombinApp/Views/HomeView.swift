//
//  HomeView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

// This view is no longer used in the main app flow
// The app now uses MainTabView with GenerateOutfitView, MyClosetView, and SettingsView
// Keeping this for reference or potential future use

struct HomeView: View {
    @EnvironmentObject var clothingStore: ClothingStore
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageTracker: UsageTracker
    @State private var showPaywall = false
    
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
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(hex: "ffb6c1").opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 15) {
                        HStack {
                            Spacer()
                            
                            if !subscriptionManager.isPremium {
                                Button(action: {
                                    showPaywall = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "crown.fill")
                                            .font(.caption)
                                        Text("Premium")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.pink, Color.purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                }
                            } else {
                                PremiumStatusBadge()
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "d291bc"))
                        
                        Text("KombinApp")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "d291bc"))
                        
                        Text(isEnglish ? "AI-Powered Outfit Suggestions" : "AI Destekli Kombin Önerileri")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Usage counters for free users
                        if !subscriptionManager.subscriptionStatus.isPremium {
                            HStack(spacing: 20) {
                                UsageCounterView(type: .clothing)
                                UsageCounterView(type: .outfitGeneration)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Welcome message
                    VStack(spacing: 20) {
                        Text(isEnglish ? "Welcome to KombinApp!" : "KombinApp'e Hoş Geldiniz!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(isEnglish ? "Use the tabs below to manage your closet and get AI-powered outfit suggestions." : "Dolabınızı yönetmek ve AI destekli kombin önerileri almak için aşağıdaki sekmeleri kullanın.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        // Premium upgrade prompt for free users
                        if !subscriptionManager.subscriptionStatus.isPremium && clothingStore.getAllItems().count >= 2 {
                            Button("Premium'a Geç ve Sınırsız Özellikler Kazan") {
                                showPaywall = true
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.pink, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Stats
                    if !clothingStore.getAllItems().isEmpty {
                        VStack(spacing: 15) {
                            Text(isEnglish ? "Your Wardrobe" : "Gardırobunuz")
                                .font(.headline)
                                .foregroundColor(Color(hex: "d291bc"))
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                                StatView(title: isEnglish ? "Tops" : "Üstler", count: clothingStore.getItems(of: .top).count)
                                StatView(title: isEnglish ? "Bottoms" : "Altlar", count: clothingStore.getItems(of: .jeans).count + clothingStore.getItems(of: .skirt).count)
                                StatView(title: isEnglish ? "Shoes" : "Ayakkabılar", count: clothingStore.getItems(of: .shoes).count)
                                StatView(title: isEnglish ? "Dresses" : "Elbiseler", count: clothingStore.getItems(of: .dress).count)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPaywall) {
            ClosAIPremiumView()
        }
    }
}

struct StatView: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "d291bc"))
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(ClothingStore())
        .environmentObject(AppSettings())
}