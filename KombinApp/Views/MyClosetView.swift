//
//  MyClosetView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI
import PhotosUI

struct MyClosetView: View {
    @EnvironmentObject var clothingStore: ClothingStore
    @EnvironmentObject var appSettings: AppSettings
    @State private var showAddClothing = false
    @State private var selectedCategory: ClothingType? = nil
    
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
                
                VStack(spacing: 20) {
                    // Header with stats
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(isEnglish ? "My Closet" : "Dolabım")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "d291bc"))
                                
                                Text(isEnglish ? "\(clothingStore.getAllItems().count) items in your wardrobe" : "Gardırobunuzda \(clothingStore.getAllItems().count) parça")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showAddClothing = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Color(hex: "d291bc"))
                            }
                        }
                        
                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryFilterButton(
                                    title: isEnglish ? "All" : "Tümü",
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(ClothingType.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: isEnglish ? category.englishName : category.localizedName,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Items grid
                    if filteredItems.isEmpty {
                        EmptyClosetView(isEnglish: isEnglish) {
                            showAddClothing = true
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                ForEach(filteredItems) { item in
                                    ClothingItemCard(item: item, isEnglish: isEnglish) {
                                        clothingStore.removeItem(item)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddClothing) {
            AddClothingView()
                .environmentObject(clothingStore)
                .environmentObject(appSettings)
        }
    }
    
    private var filteredItems: [ClothingItem] {
        if let selectedCategory = selectedCategory {
            return clothingStore.getItems(of: selectedCategory)
        }
        return clothingStore.getAllItems()
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color(hex: "d291bc"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    Color(hex: "d291bc") : 
                    Color(.systemBackground)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "d291bc"), lineWidth: isSelected ? 0 : 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

struct ClothingItemCard: View {
    let item: ClothingItem
    let isEnglish: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Image
            ZStack {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Placeholder with selected color
                    RoundedRectangle(cornerRadius: 12)
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
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: item.type.icon)
                                .font(.title)
                                .foregroundColor(.white)
                        )
                }
                
                // Delete button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                                .background(Color.white, in: Circle())
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            // Item info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct EmptyClosetView: View {
    let isEnglish: Bool
    let onAddClothing: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tshirt")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(isEnglish ? "Your closet is empty" : "Dolabınız boş")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(isEnglish ? "Start adding your clothes to get AI-powered outfit suggestions!" : "AI destekli kombin önerileri almak için kıyafetlerinizi eklemeye başlayın!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onAddClothing) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(isEnglish ? "Add Your First Item" : "İlk Parçanızı Ekleyin")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "ffb6c1"), Color(hex: "d291bc")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "d291bc").opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.vertical, 50)
    }
}

#Preview {
    MyClosetView()
        .environmentObject(ClothingStore())
        .environmentObject(AppSettings())
}