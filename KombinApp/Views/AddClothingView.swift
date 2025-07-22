//
//  AddClothingView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI
import PhotosUI

struct AddClothingView: View {
    @EnvironmentObject var clothingStore: ClothingStore
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: ClothingType = .top
    @State private var itemName = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var selectedColor: ClothingColor = .black


    
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
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "d291bc"))
                            
                            Text(isEnglish ? "Add New Item" : "Yeni Parça Ekle")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "d291bc"))
                        }
                        .padding(.top, 20)
                        
                        // Image selection
                        VStack(spacing: 15) {
                            Text(isEnglish ? "Add Photo" : "Fotoğraf Ekle")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 40))
                                                .foregroundColor(.gray)
                                            Text(isEnglish ? "No image selected" : "Fotoğraf seçilmedi")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Galeri butonu
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text(isEnglish ? "Select Photo" : "Fotoğraf Seç")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
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
                                .shadow(color: Color(hex: "d291bc").opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        
                        // Item name
                        VStack(alignment: .leading, spacing: 10) {
                            Text(isEnglish ? "Item Name (Optional)" : "Parça Adı (İsteğe Bağlı)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField(isEnglish ? "Enter item name" : "Parça adını girin", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 5)
                        }
                        
                        // Clothing type selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text(isEnglish ? "Category" : "Kategori")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(ClothingType.allCases, id: \.self) { type in
                                    ClothingTypeCard(
                                        type: type,
                                        isSelected: selectedType == type,
                                        isEnglish: isEnglish
                                    ) {
                                        selectedType = type
                                    }
                                }
                            }
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text(isEnglish ? "Color" : "Renk")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(ClothingColor.allCases, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedColor == color ? Color(hex: "d291bc") : Color.clear, lineWidth: 3)
                                                )
                                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                                            
                                            Text(isEnglish ? color.rawValue : color.localizedName)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // AI Detection Info
                        if imageData != nil {
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(Color(hex: "d291bc"))
                                    Text(isEnglish ? "AI will automatically detect color and style" : "AI renk ve stili otomatik olarak algılayacak")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(hex: "ffb6c1").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationTitle(isEnglish ? "Add Clothing" : "Kıyafet Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEnglish ? "Cancel" : "İptal") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "d291bc"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEnglish ? "Save" : "Kaydet") {
                        saveItem()
                    }
                    .foregroundColor(Color(hex: "d291bc"))
                    .fontWeight(.semibold)
                }
            }
        }
        .onChange(of: selectedImage) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }



    }
    

    

    

    
    // MARK: - Save Item
    private func saveItem() {
        let newItem = ClothingItem(
            type: selectedType,
            name: itemName.isEmpty ? selectedType.rawValue : itemName,
            imageData: imageData,
            selectedColor: selectedColor
        )
        
        clothingStore.addClothingItem(newItem)
        dismiss()
    }
}



struct ClothingTypeCard: View {
    let type: ClothingType
    let isSelected: Bool
    let isEnglish: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? 
                            LinearGradient(
                                colors: [Color(hex: "ffb6c1"), Color(hex: "d291bc")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : Color(hex: "d291bc"))
                }
                
                // Title
                Text(isEnglish ? type.englishName : type.localizedName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color(hex: "d291bc") : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? Color(hex: "d291bc").opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(hex: "d291bc") : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddClothingView()
        .environmentObject(ClothingStore())
        .environmentObject(AppSettings())
}
