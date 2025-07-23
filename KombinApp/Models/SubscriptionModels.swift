import Foundation
import StoreKit

// MARK: - Subscription Status
enum SubscriptionStatus: Equatable {
    case free
    case premium(expiryDate: Date, type: SubscriptionType)
    case loading
    case error(String)
    
    var isPremium: Bool {
        switch self {
        case .premium:
            return true
        default:
            return false
        }
    }
}

// MARK: - Subscription Types
enum SubscriptionType: String, CaseIterable, Codable {
    case weekly = "com.closai.premium.weekly"
    case monthly = "com.closai.premium.monthly"
    case yearly = "com.closai.premium.yearly"
    
    var displayName: String {
        switch self {
        case .weekly:
            return "Haftalık"
        case .monthly:
            return "Aylık"
        case .yearly:
            return "Yıllık"
        }
    }
    
    var price: String {
        switch self {
        case .weekly:
            return "₺100"
        case .monthly:
            return "₺250"
        case .yearly:
            return "₺999"
        }
    }
    
    var duration: String {
        switch self {
        case .weekly:
            return "hafta"
        case .monthly:
            return "ay"
        case .yearly:
            return "yıl"
        }
    }
    
    var isRecommended: Bool {
        return self == .monthly
    }
    
    var sortOrder: Int {
        switch self {
        case .weekly:
            return 0
        case .monthly:
            return 1
        case .yearly:
            return 2
        }
    }
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly:
            return .weekOfYear
        case .monthly:
            return .month
        case .yearly:
            return .year
        }
    }
}

// MARK: - Premium Features
enum PremiumFeature: CaseIterable {
    case unlimitedClothing
    case unlimitedOutfits
    case themeCustomization
    case unlimitedFavorites
    case dailyStyleSuggestions
    
    var displayName: String {
        switch self {
        case .unlimitedClothing:
            return "Sınırsız Kıyafet"
        case .unlimitedOutfits:
            return "Sınırsız Kombin"
        case .themeCustomization:
            return "Tema Özelleştirme"
        case .unlimitedFavorites:
            return "Sınırsız Favori"
        case .dailyStyleSuggestions:
            return "Günlük Stil Önerileri"
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedClothing:
            return "İstediğin kadar kıyafet ekle"
        case .unlimitedOutfits:
            return "Sınırsız kombin oluştur"
        case .themeCustomization:
            return "Uygulamanı kişiselleştir"
        case .unlimitedFavorites:
            return "Favori kombinlerini kaydet"
        case .dailyStyleSuggestions:
            return "Her gün yeni stil önerileri"
        }
    }
    
    var iconName: String {
        switch self {
        case .unlimitedClothing:
            return "tshirt.fill"
        case .unlimitedOutfits:
            return "sparkles"
        case .themeCustomization:
            return "paintbrush.fill"
        case .unlimitedFavorites:
            return "heart.fill"
        case .dailyStyleSuggestions:
            return "star.fill"
        }
    }
}

// MARK: - Usage Limits
struct UsageLimits {
    static let freeClothingLimit = 3
    static let freeOutfitGenerationLimit = 10 // per day
    static let premiumUnlimited = -1
}

// MARK: - User Subscription
struct UserSubscription: Codable {
    let type: SubscriptionType
    let purchaseDate: Date
    let expiryDate: Date
    let isActive: Bool
    let autoRenewing: Bool
}

// MARK: - Subscription Plan
struct SubscriptionPlan {
    let id: String
    let name: String
    let price: String
    let duration: String
    let features: [String]
    let isRecommended: Bool
    
    static let allPlans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: SubscriptionType.weekly.rawValue,
            name: "Haftalık Premium",
            price: "₺59,99",
            duration: "hafta",
            features: PremiumFeature.allCases.map { $0.displayName },
            isRecommended: false
        ),
        SubscriptionPlan(
            id: SubscriptionType.monthly.rawValue,
            name: "Aylık Premium",
            price: "₺129,99",
            duration: "ay",
            features: PremiumFeature.allCases.map { $0.displayName },
            isRecommended: true
        ),
        SubscriptionPlan(
            id: SubscriptionType.yearly.rawValue,
            name: "Yıllık Premium",
            price: "₺999,99",
            duration: "yıl",
            features: PremiumFeature.allCases.map { $0.displayName },
            isRecommended: false
        )
    ]
}

// MARK: - Purchase Errors
enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed(String)
    case receiptValidationFailed
    case networkError
    case userCancelled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Ürün bulunamadı"
        case .purchaseFailed(let reason):
            return "Satın alma başarısız: \(reason)"
        case .receiptValidationFailed:
            return "Abonelik doğrulanamadı"
        case .networkError:
            return "İnternet bağlantısını kontrol edin"
        case .userCancelled:
            return "Satın alma iptal edildi"
        case .unknown:
            return "Bilinmeyen bir hata oluştu"
        }
    }
}

// MARK: - Usage Limit Errors
enum UsageLimitError: LocalizedError {
    case clothingLimitReached
    case outfitGenerationLimitReached
    case featureRequiresPremium(PremiumFeature)
    
    var errorDescription: String? {
        switch self {
        case .clothingLimitReached:
            return "Ücretsiz kullanımda en fazla 3 kıyafet ekleyebilirsiniz"
        case .outfitGenerationLimitReached:
            return "Günlük kombin oluşturma limitiniz doldu"
        case .featureRequiresPremium(let feature):
            return "\(feature.displayName) özelliği Premium üyelik gerektirir"
        }
    }
}