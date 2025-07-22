//
//  ClothingStore.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

class ClothingStore: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var favoriteOutfits: [Outfit] = []
    
    private let aiService = AIOutfitService()
    
    init() {
        loadDummyData()
    }
    
    func addClothingItem(_ item: ClothingItem) {
        var processedItem = item
        
        // If image data is available, use AI to detect color and style
        if let imageData = item.imageData {
            let detectedColor = aiService.detectColorFromImage(imageData)
            let detectedStyle = aiService.detectStyleFromImage(imageData)
            
            processedItem = ClothingItem(
                type: item.type,
                name: item.name,
                imageData: item.imageData,
                aiDetectedColor: detectedColor,
                aiDetectedStyle: detectedStyle
            )
        }
        
        clothingItems.append(processedItem)
    }
    
    func getItems(of type: ClothingType) -> [ClothingItem] {
        return clothingItems.filter { $0.type == type }
    }
    
    func getAllItems() -> [ClothingItem] {
        return clothingItems
    }
    
    func generateAIOutfitSuggestion(preferredStyle: OutfitStyle? = nil, customDescription: String? = nil) -> OutfitSuggestion? {
        return aiService.generateOutfitSuggestion(
            from: clothingItems,
            preferredStyle: preferredStyle,
            customDescription: customDescription
        )
    }
    
    func addToFavorites(_ outfit: Outfit) {
        var favoriteOutfit = outfit
        favoriteOutfit.isFavorite = true
        favoriteOutfits.append(favoriteOutfit)
    }
    
    func removeItem(_ item: ClothingItem) {
        clothingItems.removeAll { $0.id == item.id }
    }
    
    private func loadDummyData() {
        // Add diverse dummy items with new categories
        let dummyItems = [
            // Üst giyim
            ClothingItem(type: .top, name: "Beyaz Bluz", selectedColor: .white, aiDetectedStyle: .formal),
            ClothingItem(type: .tshirt, name: "Pembe Tişört", selectedColor: .lightPink, aiDetectedStyle: .casual),
            ClothingItem(type: .shirt, name: "Mavi Gömlek", selectedColor: .lightBlue, aiDetectedStyle: .casual),
            ClothingItem(type: .jacket, name: "Siyah Ceket", selectedColor: .black, aiDetectedStyle: .formal),
            ClothingItem(type: .coat, name: "Bej Kaban", selectedColor: .beige, aiDetectedStyle: .formal),
            
            // Alt giyim
            ClothingItem(type: .jeans, name: "Mavi Jean", selectedColor: .darkBlue, aiDetectedStyle: .casual),
            ClothingItem(type: .skirt, name: "Fuşya Etek", selectedColor: .hotPink, aiDetectedStyle: .formal),
            
            // Elbiseler
            ClothingItem(type: .dress, name: "Yaz Elbisesi", selectedColor: .lightYellow, aiDetectedStyle: .casual),
            ClothingItem(type: .dress, name: "Gece Elbisesi", selectedColor: .black, aiDetectedStyle: .formal),
            
            // Ayakkabılar
            ClothingItem(type: .shoes, name: "Siyah Topuklu", selectedColor: .black, aiDetectedStyle: .formal),
            ClothingItem(type: .sneakers, name: "Beyaz Spor Ayakkabı", selectedColor: .white, aiDetectedStyle: .sporty),
            ClothingItem(type: .shoes, name: "Kahverengi Bot", selectedColor: .darkBrown, aiDetectedStyle: .casual),
            
            // Çanta ve aksesuarlar
            ClothingItem(type: .bag, name: "Siyah Çanta", selectedColor: .black, aiDetectedStyle: .formal),
            ClothingItem(type: .accessory, name: "Altın Saat", selectedColor: .gold, aiDetectedStyle: .formal),
            ClothingItem(type: .hat, name: "Bej Şapka", selectedColor: .beige, aiDetectedStyle: .casual),
            
            // Plaj/yazlık
            ClothingItem(type: .swimwear, name: "Mavi Bikini", selectedColor: .lightBlue, aiDetectedStyle: .casual)
        ]
        
        clothingItems.append(contentsOf: dummyItems)
    }
}