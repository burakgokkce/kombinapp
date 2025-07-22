//
//  ClothingItem.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

enum ClothingType: String, CaseIterable, Codable {
    case top = "Üst"
    case jeans = "Jean"
    case dress = "Elbise"
    case tshirt = "Tişört"
    case shirt = "Gömlek"
    case jacket = "Ceket / Mont"
    case skirt = "Etek"
    case shoes = "Ayakkabı"
    case bag = "Çanta"
    case accessory = "Aksesuar"
    case sneakers = "Spor Ayakkabı"
    case coat = "Kaban / Dış Giyim"
    case swimwear = "Plaj / Yazlık"
    case hat = "Şapka"
    
    var icon: String {
        switch self {
        case .top: return "tshirt"
        case .jeans: return "pants.fill"
        case .dress: return "dress"
        case .tshirt: return "tshirt.fill"
        case .shirt: return "shirt"
        case .jacket: return "jacket"
        case .skirt: return "skirt"
        case .shoes: return "shoe.2"
        case .bag: return "bag.fill"
        case .accessory: return "watch"
        case .sneakers: return "shoe.2.fill"
        case .coat: return "coat"
        case .swimwear: return "sun.max.fill"
        case .hat: return "hat"
        }
    }
    
    var localizedName: String {
        return self.rawValue
    }
    
    var englishName: String {
        switch self {
        case .top: return "Top"
        case .jeans: return "Jeans"
        case .dress: return "Dress"
        case .tshirt: return "T-shirt"
        case .shirt: return "Shirt"
        case .jacket: return "Jacket"
        case .skirt: return "Skirt"
        case .shoes: return "Shoes"
        case .bag: return "Bag"
        case .accessory: return "Accessory"
        case .sneakers: return "Sneakers"
        case .coat: return "Coat"
        case .swimwear: return "Swimwear"
        case .hat: return "Hat"
        }
    }
}

enum ClothingStyle: String, CaseIterable, Codable {
    case casual = "Casual"
    case formal = "Formal"
    case sporty = "Sporty"
}

enum ClothingColor: String, CaseIterable, Codable {
    case black = "Black"
    case white = "White"
    case gray = "Gray"
    case lightGray = "Light Gray"
    case darkGray = "Dark Gray"
    case red = "Red"
    case darkRed = "Dark Red"
    case pink = "Pink"
    case lightPink = "Light Pink"
    case hotPink = "Hot Pink"
    case blue = "Blue"
    case lightBlue = "Light Blue"
    case darkBlue = "Dark Blue"
    case navy = "Navy"
    case green = "Green"
    case lightGreen = "Light Green"
    case darkGreen = "Dark Green"
    case yellow = "Yellow"
    case lightYellow = "Light Yellow"
    case orange = "Orange"
    case purple = "Purple"
    case lightPurple = "Light Purple"
    case brown = "Brown"
    case lightBrown = "Light Brown"
    case darkBrown = "Dark Brown"
    case beige = "Beige"
    case cream = "Cream"
    case gold = "Gold"
    case silver = "Silver"
    case maroon = "Maroon"
    
    var color: Color {
        switch self {
        case .black: return .black
        case .white: return .white
        case .gray: return .gray
        case .lightGray: return Color(.systemGray4)
        case .darkGray: return Color(.systemGray)
        case .red: return .red
        case .darkRed: return Color(red: 0.5, green: 0, blue: 0)
        case .pink: return .pink
        case .lightPink: return Color(red: 1, green: 0.7, blue: 0.8)
        case .hotPink: return Color(red: 1, green: 0.1, blue: 0.6)
        case .blue: return .blue
        case .lightBlue: return Color(red: 0.7, green: 0.8, blue: 1)
        case .darkBlue: return Color(red: 0, green: 0, blue: 0.5)
        case .navy: return Color(red: 0, green: 0, blue: 0.3)
        case .green: return .green
        case .lightGreen: return Color(red: 0.7, green: 1, blue: 0.7)
        case .darkGreen: return Color(red: 0, green: 0.5, blue: 0)
        case .yellow: return .yellow
        case .lightYellow: return Color(red: 1, green: 1, blue: 0.7)
        case .orange: return .orange
        case .purple: return .purple
        case .lightPurple: return Color(red: 0.8, green: 0.7, blue: 1)
        case .brown: return .brown
        case .lightBrown: return Color(red: 0.8, green: 0.6, blue: 0.4)
        case .darkBrown: return Color(red: 0.4, green: 0.2, blue: 0.1)
        case .beige: return Color(red: 0.96, green: 0.96, blue: 0.86)
        case .cream: return Color(red: 1, green: 0.99, blue: 0.82)
        case .gold: return Color(red: 1, green: 0.84, blue: 0)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .maroon: return Color(red: 0.5, green: 0, blue: 0)
        }
    }
    
    var localizedName: String {
        // Turkish translations
        switch self {
        case .black: return "Siyah"
        case .white: return "Beyaz"
        case .gray: return "Gri"
        case .lightGray: return "Açık Gri"
        case .darkGray: return "Koyu Gri"
        case .red: return "Kırmızı"
        case .darkRed: return "Koyu Kırmızı"
        case .pink: return "Pembe"
        case .lightPink: return "Açık Pembe"
        case .hotPink: return "Fuşya"
        case .blue: return "Mavi"
        case .lightBlue: return "Açık Mavi"
        case .darkBlue: return "Koyu Mavi"
        case .navy: return "Lacivert"
        case .green: return "Yeşil"
        case .lightGreen: return "Açık Yeşil"
        case .darkGreen: return "Koyu Yeşil"
        case .yellow: return "Sarı"
        case .lightYellow: return "Açık Sarı"
        case .orange: return "Turuncu"
        case .purple: return "Mor"
        case .lightPurple: return "Açık Mor"
        case .brown: return "Kahverengi"
        case .lightBrown: return "Açık Kahve"
        case .darkBrown: return "Koyu Kahve"
        case .beige: return "Bej"
        case .cream: return "Krem"
        case .gold: return "Altın"
        case .silver: return "Gümüş"
        case .maroon: return "Bordo"
        }
    }
}

struct ClothingItem: Identifiable, Codable {
    let id = UUID()
    let type: ClothingType
    let name: String
    let imageData: Data?
    let selectedColor: ClothingColor?
    let aiDetectedColor: ClothingColor?
    let aiDetectedStyle: ClothingStyle?
    let dateAdded: Date
    
    init(type: ClothingType, name: String = "", imageData: Data? = nil, selectedColor: ClothingColor? = nil, aiDetectedColor: ClothingColor? = nil, aiDetectedStyle: ClothingStyle? = nil) {
        self.type = type
        self.name = name.isEmpty ? type.rawValue : name
        self.imageData = imageData
        self.selectedColor = selectedColor
        self.aiDetectedColor = aiDetectedColor
        self.aiDetectedStyle = aiDetectedStyle
        self.dateAdded = Date()
    }
}