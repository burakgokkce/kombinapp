//
//  Outfit.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import Foundation

struct Outfit: Identifiable, Codable {
    let id = UUID()
    let top: ClothingItem?
    let bottom: ClothingItem?
    let shoes: ClothingItem?
    let accessory: ClothingItem?
    let dateCreated: Date
    var isFavorite: Bool = false
    
    init(top: ClothingItem?, bottom: ClothingItem?, shoes: ClothingItem?, accessory: ClothingItem? = nil) {
        self.top = top
        self.bottom = bottom
        self.shoes = shoes
        self.accessory = accessory
        self.dateCreated = Date()
    }
}