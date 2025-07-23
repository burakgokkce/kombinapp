//
//  AIOutfitService.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

enum OutfitStyle: String, CaseIterable {
    case casual = "Casual"
    case formal = "Formal"
    case sporty = "Sporty"
    case elegant = "Elegant"
    case trendy = "Trendy"
    case comfortable = "Comfortable"
    
    var localizedName: String {
        // This will be expanded with proper localization
        return self.rawValue
    }
}

struct OutfitSuggestion {
    let items: [ClothingItem]
    let styleDescription: String
    let confidence: Double
}

class AIOutfitService: ObservableObject {
    
    // Simulate AI color detection from image
    func detectColorFromImage(_ imageData: Data) -> ClothingColor {
        // In a real app, this would use Core ML or Vision framework
        // For now, we'll simulate with random selection
        return ClothingColor.allCases.randomElement() ?? .black
    }
    
    // Simulate AI style detection from image
    func detectStyleFromImage(_ imageData: Data) -> ClothingStyle {
        // In a real app, this would analyze the image for style characteristics
        return ClothingStyle.allCases.randomElement() ?? .casual
    }
    
    // Generate outfit suggestion based on available items and desired style
    func generateOutfitSuggestion(from items: [ClothingItem], preferredStyle: OutfitStyle? = nil, customDescription: String? = nil, isPremium: Bool = false) -> OutfitSuggestion? {
        
        // Filter items by style preference if provided
        var filteredItems = items
        if let preferredStyle = preferredStyle {
            let targetStyle = mapOutfitStyleToClothingStyle(preferredStyle)
            filteredItems = items.filter { item in
                item.aiDetectedStyle == targetStyle || item.aiDetectedStyle == nil
            }
        }
        
        // If custom description is provided, simulate AI understanding
        if let customDescription = customDescription, !customDescription.isEmpty {
            filteredItems = filterItemsByDescription(items, description: customDescription, isPremium: isPremium)
        }
        
        // Try to create a complete outfit
        let tops = filteredItems.filter { $0.type == .top || $0.type == .dress }
        let bottoms = filteredItems.filter { $0.type == .jeans || $0.type == .skirt }
        let shoes = filteredItems.filter { $0.type == .shoes }
        let accessories = filteredItems.filter { $0.type == .accessory }
        
        var outfitItems: [ClothingItem] = []
        
        // Add top or dress
        if let selectedTop = tops.randomElement() {
            outfitItems.append(selectedTop)
            
            // If it's not a dress, add bottom
            if selectedTop.type != .dress {
                if let selectedBottom = bottoms.randomElement() {
                    outfitItems.append(selectedBottom)
                }
            }
        }
        
        // Add shoes
        if let selectedShoes = shoes.randomElement() {
            outfitItems.append(selectedShoes)
        }
        
        // Optionally add accessory
        if let selectedAccessory = accessories.randomElement(), Bool.random() {
            outfitItems.append(selectedAccessory)
        }
        
        guard !outfitItems.isEmpty else { return nil }
        
        let styleDescription = generateStyleDescription(for: outfitItems, preferredStyle: preferredStyle)
        let confidence = calculateConfidence(for: outfitItems)
        
        return OutfitSuggestion(
            items: outfitItems,
            styleDescription: styleDescription,
            confidence: confidence
        )
    }
    
    private func mapOutfitStyleToClothingStyle(_ outfitStyle: OutfitStyle) -> ClothingStyle {
        switch outfitStyle {
        case .casual, .comfortable: return .casual
        case .formal, .elegant: return .formal
        case .sporty, .trendy: return .sporty
        }
    }
    
    private func filterItemsByDescription(_ items: [ClothingItem], description: String, isPremium: Bool = false) -> [ClothingItem] {
        let lowercased = description.lowercased()
        
        // Enhanced AI understanding for premium users
        var filtered = items
        
        if isPremium {
            // Premium users get more sophisticated filtering
            filtered = performAdvancedFiltering(items: items, description: lowercased)
        } else {
            // Basic filtering for free users
            filtered = performBasicFiltering(items: items, description: lowercased)
        }
        
        return filtered.isEmpty ? items : filtered
    }
    
    private func performAdvancedFiltering(items: [ClothingItem], description: String) -> [ClothingItem] {
        var filtered = items
        
        // Advanced style detection
        if description.contains("formal") || description.contains("elegant") || description.contains("business") || 
           description.contains("ofis") || description.contains("iş") || description.contains("resmi") {
            filtered = items.filter { $0.aiDetectedStyle == .formal || $0.aiDetectedStyle == nil }
        } else if description.contains("casual") || description.contains("relaxed") || description.contains("comfortable") ||
                  description.contains("rahat") || description.contains("günlük") || description.contains("sade") {
            filtered = items.filter { $0.aiDetectedStyle == .casual || $0.aiDetectedStyle == nil }
        } else if description.contains("sport") || description.contains("gym") || description.contains("active") ||
                  description.contains("spor") || description.contains("aktif") || description.contains("koşu") {
            filtered = items.filter { $0.aiDetectedStyle == .sporty || $0.aiDetectedStyle == nil }
        } else if description.contains("party") || description.contains("night") || description.contains("club") ||
                  description.contains("parti") || description.contains("gece") || description.contains("eğlence") {
            filtered = items.filter { $0.aiDetectedStyle == .formal || $0.type == .dress }
        }
        
        // Advanced color filtering with Turkish support
        let colorKeywords: [String: ClothingColor] = [
            "black": .black, "siyah": .black,
            "white": .white, "beyaz": .white,
            "red": .red, "kırmızı": .red,
            "blue": .blue, "mavi": .blue,
            "green": .green, "yeşil": .green,
            "yellow": .yellow, "sarı": .yellow,
            "pink": .pink, "pembe": .pink,
            "purple": .purple, "mor": .purple,
            "brown": .brown, "kahverengi": .brown,
            "gray": .gray, "gri": .gray
        ]
        
        for (keyword, color) in colorKeywords {
            if description.contains(keyword) {
                filtered = filtered.filter { $0.aiDetectedColor == color || $0.selectedColor == color || $0.aiDetectedColor == nil }
                break
            }
        }
        
        // Weather-based filtering (premium feature)
        if description.contains("hot") || description.contains("summer") || description.contains("sıcak") || description.contains("yaz") {
            filtered = filtered.filter { $0.type != .jacket && $0.type != .coat }
        } else if description.contains("cold") || description.contains("winter") || description.contains("soğuk") || description.contains("kış") {
            // Prefer warmer items
            let warmItems = filtered.filter { $0.type == .jacket || $0.type == .coat }
            if !warmItems.isEmpty {
                filtered = warmItems + filtered.filter { $0.type != .jacket && $0.type != .coat }
            }
        }
        
        return filtered
    }
    
    private func performBasicFiltering(items: [ClothingItem], description: String) -> [ClothingItem] {
        var filtered = items
        
        // Basic style filtering
        if description.contains("formal") || description.contains("elegant") || description.contains("business") {
            filtered = items.filter { $0.aiDetectedStyle == .formal || $0.aiDetectedStyle == nil }
        } else if description.contains("casual") || description.contains("relaxed") || description.contains("comfortable") {
            filtered = items.filter { $0.aiDetectedStyle == .casual || $0.aiDetectedStyle == nil }
        } else if description.contains("sport") || description.contains("gym") || description.contains("active") {
            filtered = items.filter { $0.aiDetectedStyle == .sporty || $0.aiDetectedStyle == nil }
        }
        
        // Basic color filtering (English only for free users)
        for color in ClothingColor.allCases {
            if description.contains(color.rawValue.lowercased()) {
                filtered = filtered.filter { $0.aiDetectedColor == color || $0.aiDetectedColor == nil }
                break
            }
        }
        
        return filtered
    }
    
    private func generateStyleDescription(for items: [ClothingItem], preferredStyle: OutfitStyle?) -> String {
        let descriptions = [
            "Perfect for a day out with friends!",
            "Great choice for any occasion.",
            "This combination looks amazing together.",
            "A stylish and comfortable outfit.",
            "You'll look fantastic in this!",
            "This outfit perfectly matches your style.",
            "A great combination for today's weather.",
            "This look is both trendy and timeless."
        ]
        
        if let preferredStyle = preferredStyle {
            switch preferredStyle {
            case .casual:
                return "A relaxed and comfortable casual look."
            case .formal:
                return "An elegant and professional formal outfit."
            case .sporty:
                return "Perfect for an active and energetic day."
            case .elegant:
                return "A sophisticated and refined ensemble."
            case .trendy:
                return "A fashionable and contemporary style."
            case .comfortable:
                return "Comfortable yet stylish for all-day wear."
            }
        }
        
        return descriptions.randomElement() ?? "A great outfit choice!"
    }
    
    private func calculateConfidence(for items: [ClothingItem]) -> Double {
        // Simulate confidence based on outfit completeness and style matching
        var confidence = 0.5
        
        let hasTop = items.contains { $0.type == .top || $0.type == .dress }
        let hasBottom = items.contains { $0.type == .jeans || $0.type == .skirt || $0.type == .dress }
        let hasShoes = items.contains { $0.type == .shoes }
        
        if hasTop { confidence += 0.2 }
        if hasBottom { confidence += 0.2 }
        if hasShoes { confidence += 0.1 }
        
        return min(confidence, 1.0)
    }
}