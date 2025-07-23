//
//  GenerateOutfitView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

struct GenerateOutfitView: View {
    @EnvironmentObject var clothingStore: ClothingStore
    @EnvironmentObject var appSettings: AppSettings
    
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageTracker: UsageTracker
    @State private var showPaywall = false
    @State private var showUsageLimitAlert = false
    
    @State private var currentSuggestion: OutfitSuggestion?
    @State private var isGenerating = false
    @State private var styleInput = ""
    @State private var showFavoriteAlert = false
    
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
                        VStack(spacing: 15) {
                            HStack {
                                Spacer()
                                if subscriptionManager.subscriptionStatus.isPremium {
                                    PremiumStatusBadge()
                                } else {
                                    UsageCounterView(type: .outfitGeneration)
                                }
                            }
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "d291bc"))
                                .scaleEffect(isGenerating ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatCount(isGenerating ? 3 : 0), value: isGenerating)
                            
                            Text(isEnglish ? "What should I wear today?" : "Bugün ne giysem?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "d291bc"))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Tarz yazma alanı
                        VStack(spacing: 15) {
                            Text(isEnglish ? "What style do you want today?" : "Bugün ne tarz bir kombin istiyorsun?")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            TextField(
                                isEnglish ? "e.g., sporty, elegant, casual, office..." : "örn: spor, şık, günlük, ofis...",
                                text: $styleInput
                            )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(hex: "d291bc").opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // Kombin öner butonu
                        Button(action: generateOutfitWithStyle) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                        .font(.title2)
                                }
                                
                                Text(isGenerating ? (isEnglish ? "Generating..." : "Oluşturuluyor...") : (isEnglish ? "Suggest Outfit" : "Kombin Öner"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "ffb6c1"), Color(hex: "d291bc")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "d291bc").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isGenerating)
                        .padding(.horizontal, 30)
                        
                        // Outfit display
                        if let suggestion = currentSuggestion {
                            VStack(spacing: 25) {
                                // Style description
                                Text(suggestion.styleDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                
                                // Outfit items
                                ForEach(suggestion.items, id: \.id) { item in
                                    AIOutfitItemCard(item: item, isEnglish: isEnglish)
                                }
                                
                                // Action buttons
                                HStack(spacing: 15) {
                                    // I like it button
                                    Button(action: {
                                        likeOutfit()
                                    }) {
                                        HStack {
                                            Text("💖")
                                            Text(isEnglish ? "I like it" : "Beğendim")
                                        }
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color(hex: "d291bc"))
                                        .clipShape(Capsule())
                                        .shadow(color: Color(hex: "d291bc").opacity(0.3), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    // Try again button
                                    Button(action: {
                                        tryAgain()
                                    }) {
                                        HStack {
                                            Text("🔄")
                                            Text(isEnglish ? "Try again" : "Tekrar dene")
                                        }
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "d291bc"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color(.systemBackground))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(hex: "d291bc"), lineWidth: 2)
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
                                }
                                .padding(.horizontal, 30)
                            }
                        }
                        
                        // Empty closet message
                        if clothingStore.getAllItems().isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "tshirt")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text(isEnglish ? "Your closet is empty" : "Dolabınız boş")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(isEnglish ? "Add some clothes to get AI-powered outfit suggestions!" : "AI destekli kombin önerileri almak için kıyafet ekleyin!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                            .padding(.horizontal, 30)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isEnglish ? "Added to Favorites!" : "Favorilere Eklendi!", isPresented: $showFavoriteAlert) {
            Button(isEnglish ? "OK" : "Tamam") { }
        } message: {
            Text(isEnglish ? "This outfit has been saved to your favorites." : "Bu kombin favorilerinize kaydedildi.")
        }
        .alert("Günlük Limit Doldu", isPresented: $showUsageLimitAlert) {
            Button("Premium'a Geç") {
                showPaywall = true
            }
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Günlük kombin oluşturma limitiniz doldu. Premium'a geçerek sınırsız kombin oluşturun!")
        }
        .sheet(isPresented: $showPaywall) {
            ClosAIPremiumView()
        }
    }
    
    // MARK: - Functions
    private func generateOutfitWithStyle() {
        // Check usage limits before generating
        if !usageTracker.trackOutfitGeneration() {
            showUsageLimitAlert = true
            return
        }
        
        isGenerating = true
        
        print("👗 Kombin üretiliyor...")
        print("📝 Kullanıcı tarzı: '\(styleInput)'")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.styleInput.isEmpty {
                print("🎲 Tarz belirtilmedi - rastgele kombin üretiliyor")
                self.currentSuggestion = self.clothingStore.generateAIOutfitSuggestion()
            } else {
                print("🎯 Belirtilen tarza göre kombin üretiliyor: \(self.styleInput)")
                self.currentSuggestion = self.clothingStore.generateAIOutfitSuggestion(customDescription: self.styleInput)
            }
            self.isGenerating = false
        }
    }
    
    private func likeOutfit() {
        guard let suggestion = currentSuggestion else { return }
        
        // Create outfit from suggestion and add to favorites
        let topItem = suggestion.items.first { $0.type == .top || $0.type == .dress }
        let bottomItem = suggestion.items.first { $0.type == .jeans || $0.type == .skirt }
        let shoesItem = suggestion.items.first { $0.type == .shoes }
        let accessoryItem = suggestion.items.first { $0.type == .accessory }
        
        let outfit = Outfit(
            top: topItem,
            bottom: bottomItem,
            shoes: shoesItem,
            accessory: accessoryItem
        )
        
        clothingStore.addToFavorites(outfit)
        showFavoriteAlert = true
    }
    
    private func tryAgain() {
        currentSuggestion = nil
        styleInput = ""
    }
}

struct AIOutfitItemCard: View {
    let item: ClothingItem
    let isEnglish: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Image
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
            } else {
                // Placeholder with selected color
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [
                                (item.selectedColor?.color ?? Color.gray).opacity(0.8),
                                item.selectedColor?.color ?? Color.gray
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: item.type.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .shadow(color: (item.selectedColor?.color ?? Color.gray).opacity(0.3), radius: 5, x: 0, y: 3)
            }
            
            // Item info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    if let color = item.selectedColor {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(color.color)
                                .frame(width: 12, height: 12)
                            Text(isEnglish ? color.rawValue : color.localizedName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let style = item.aiDetectedStyle {
                        Text("• \(isEnglish ? style.rawValue : style.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(isEnglish ? item.type.englishName : item.type.localizedName)
                    .font(.caption)
                    .foregroundColor(Color(hex: "d291bc"))
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 30)
    }
}

#Preview {
    GenerateOutfitView()
        .environmentObject(ClothingStore())
        .environmentObject(AppSettings())
}