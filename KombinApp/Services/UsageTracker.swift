import Foundation
import SwiftUI

@MainActor
class UsageTracker: ObservableObject {
    @AppStorage("clothingItemCount") private var clothingCount: Int = 0
    @AppStorage("dailyOutfitGenerations") private var dailyGenerations: Int = 0
    @AppStorage("lastResetDate") private var lastResetDateString: String = ""
    
    @Published var canAddClothing: Bool = true
    @Published var shouldShowPaywall: Bool = false
    @Published var usageLimitError: UsageLimitError?
    
    private let subscriptionManager: SubscriptionManager
    
    init(subscriptionManager: SubscriptionManager) {
        self.subscriptionManager = subscriptionManager
        updateUsageLimits()
        resetDailyCountersIfNeeded()
    }
    
    // MARK: - Clothing Tracking
    var currentClothingCount: Int {
        return clothingCount
    }
    
    var remainingClothingSlots: Int {
        if subscriptionManager.subscriptionStatus.isPremium {
            return -1 // Unlimited
        }
        return max(0, UsageLimits.freeClothingLimit - clothingCount)
    }
    
    func trackClothingAddition() -> Bool {
        if subscriptionManager.subscriptionStatus.isPremium {
            clothingCount += 1
            return true
        }
        
        if clothingCount >= UsageLimits.freeClothingLimit {
            usageLimitError = .clothingLimitReached
            shouldShowPaywall = true
            return false
        }
        
        clothingCount += 1
        updateUsageLimits()
        return true
    }
    
    func trackClothingRemoval() {
        if clothingCount > 0 {
            clothingCount -= 1
            updateUsageLimits()
        }
    }
    
    // MARK: - Outfit Generation Tracking
    var currentDailyGenerations: Int {
        return dailyGenerations
    }
    
    var remainingDailyGenerations: Int {
        if subscriptionManager.subscriptionStatus.isPremium {
            return -1 // Unlimited
        }
        return max(0, UsageLimits.freeOutfitGenerationLimit - dailyGenerations)
    }
    
    func trackOutfitGeneration() -> Bool {
        resetDailyCountersIfNeeded()
        
        if subscriptionManager.subscriptionStatus.isPremium {
            dailyGenerations += 1
            return true
        }
        
        if dailyGenerations >= UsageLimits.freeOutfitGenerationLimit {
            usageLimitError = .outfitGenerationLimitReached
            shouldShowPaywall = true
            return false
        }
        
        dailyGenerations += 1
        return true
    }
    
    // MARK: - Feature Access
    func canAccessFeature(_ feature: PremiumFeature) -> Bool {
        switch feature {
        case .unlimitedClothing:
            return subscriptionManager.subscriptionStatus.isPremium || clothingCount < UsageLimits.freeClothingLimit
        case .unlimitedOutfits:
            return subscriptionManager.subscriptionStatus.isPremium || dailyGenerations < UsageLimits.freeOutfitGenerationLimit
        case .themeCustomization, .unlimitedFavorites, .dailyStyleSuggestions:
            return subscriptionManager.subscriptionStatus.isPremium
        }
    }
    
    func requestFeatureAccess(_ feature: PremiumFeature) -> Bool {
        if canAccessFeature(feature) {
            return true
        }
        
        usageLimitError = .featureRequiresPremium(feature)
        shouldShowPaywall = true
        return false
    }
    
    // MARK: - Premium Upgrade
    func resetUsageForPremium() {
        canAddClothing = true
        shouldShowPaywall = false
        usageLimitError = nil
        updateUsageLimits()
    }
    
    // MARK: - Private Methods
    private func updateUsageLimits() {
        if subscriptionManager.subscriptionStatus.isPremium {
            canAddClothing = true
        } else {
            canAddClothing = clothingCount < UsageLimits.freeClothingLimit
        }
    }
    
    private func resetDailyCountersIfNeeded() {
        let today = DateFormatter.dayFormatter.string(from: Date())
        
        if lastResetDateString != today {
            dailyGenerations = 0
            lastResetDateString = today
        }
    }
    
    // MARK: - Usage Statistics
    func getUsageStatistics() -> UsageStatistics {
        return UsageStatistics(
            clothingCount: clothingCount,
            dailyGenerations: dailyGenerations,
            isPremium: subscriptionManager.subscriptionStatus.isPremium,
            remainingClothingSlots: remainingClothingSlots,
            remainingDailyGenerations: remainingDailyGenerations
        )
    }
}

// MARK: - Usage Statistics
struct UsageStatistics {
    let clothingCount: Int
    let dailyGenerations: Int
    let isPremium: Bool
    let remainingClothingSlots: Int
    let remainingDailyGenerations: Int
    
    var clothingUsageText: String {
        if isPremium {
            return "Sınırsız"
        } else {
            return "\(clothingCount)/\(UsageLimits.freeClothingLimit)"
        }
    }
    
    var outfitUsageText: String {
        if isPremium {
            return "Sınırsız"
        } else {
            return "\(dailyGenerations)/\(UsageLimits.freeOutfitGenerationLimit)"
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}