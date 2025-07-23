# Premium Membership System Design

## Overview

The premium membership system will transform the Kombin app into a freemium model with subscription-based premium features. The system will integrate with iOS StoreKit for secure in-app purchases, implement usage tracking for free users, and provide a seamless upgrade experience with a beautifully designed paywall.

## Architecture

### Core Components

1. **SubscriptionManager**: Central service managing subscription state and StoreKit integration
2. **UsageTracker**: Monitors free user limitations and triggers upgrade prompts
3. **PaywallView**: Premium subscription interface with pastel pink/purple theme
4. **PremiumFeatureGate**: Wrapper component that controls access to premium features
5. **SubscriptionStatusView**: Displays current subscription information in settings

### Data Flow

```
User Action → UsageTracker → SubscriptionManager → StoreKit → Apple Servers
     ↓              ↓              ↓              ↓
UI Updates ← Feature Gates ← Local Storage ← Receipt Validation
```

## Components and Interfaces

### SubscriptionManager

```swift
class SubscriptionManager: ObservableObject {
    @Published var subscriptionStatus: SubscriptionStatus
    @Published var availableProducts: [SKProduct]
    
    func loadProducts()
    func purchaseProduct(_ product: SKProduct)
    func restorePurchases()
    func validateReceipt()
    func checkSubscriptionStatus()
}

enum SubscriptionStatus {
    case free
    case premium(expiryDate: Date, type: SubscriptionType)
    case loading
    case error(String)
}

enum SubscriptionType: String, CaseIterable {
    case weekly = "com.kombinapp.premium.weekly"
    case monthly = "com.kombinapp.premium.monthly" 
    case yearly = "com.kombinapp.premium.yearly"
    
    var displayName: String
    var price: String
    var duration: String
}
```

### UsageTracker

```swift
class UsageTracker: ObservableObject {
    @AppStorage("clothingItemCount") private var clothingCount: Int = 0
    @Published var canAddClothing: Bool = true
    @Published var shouldShowPaywall: Bool = false
    
    func trackClothingAddition()
    func checkUsageLimits()
    func resetUsageForPremium()
}
```

### PaywallView

```swift
struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Pastel pink/purple themed subscription interface
        // Monthly plan highlighted as recommended
        // Clean, modern design with benefit explanations
    }
}
```

### PremiumFeatureGate

```swift
struct PremiumFeatureGate<Content: View>: View {
    let feature: PremiumFeature
    let content: () -> Content
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        // Shows content if premium, paywall if not
    }
}

enum PremiumFeature {
    case unlimitedClothing
    case unlimitedOutfits
    case themeCustomization
    case unlimitedFavorites
    case dailyStyleSuggestions
}
```

## Data Models

### Subscription Models

```swift
struct SubscriptionPlan {
    let id: String
    let name: String
    let price: String
    let duration: String
    let features: [String]
    let isRecommended: Bool
}

struct UserSubscription {
    let type: SubscriptionType
    let purchaseDate: Date
    let expiryDate: Date
    let isActive: Bool
    let autoRenewing: Bool
}
```

### Usage Tracking Models

```swift
struct UsageLimits {
    static let freeClothingLimit = 3
    static let freeOutfitGenerationLimit = 10 // per day
    static let premiumUnlimited = -1
}

struct UserUsage {
    var clothingItemCount: Int
    var dailyOutfitGenerations: Int
    var lastResetDate: Date
}
```

## Error Handling

### Purchase Error Handling

```swift
enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed(String)
    case receiptValidationFailed
    case networkError
    case userCancelled
    
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
        }
    }
}
```

### Usage Limit Error Handling

```swift
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
```

## Testing Strategy

### Unit Tests
- SubscriptionManager purchase flow testing
- UsageTracker limit enforcement testing
- Receipt validation testing
- Error handling scenarios

### Integration Tests
- StoreKit sandbox testing
- Subscription state persistence testing
- UI flow testing (free → premium transition)

### User Acceptance Tests
- Complete purchase flow testing
- Subscription restoration testing
- Limit enforcement testing
- Paywall presentation testing

## UI/UX Design Specifications

### PaywallView Design

**Color Scheme:**
- Primary: Soft Pink (#FFB6C1)
- Secondary: Light Purple (#DDA0DD)
- Accent: Rose Gold (#E8B4B8)
- Background: Light Pink Gradient (#FFF0F5 to #F8F8FF)

**Layout Structure:**
1. Header with app logo and premium badge
2. Feature benefits list with icons
3. Subscription plan cards (3 options)
4. Primary CTA button (Subscribe)
5. Secondary actions (Restore, Terms, Privacy)

**Typography:**
- Headlines: SF Pro Display, Bold
- Body text: SF Pro Text, Regular
- Prices: SF Pro Display, Semibold

**Animations:**
- Smooth slide-in transition
- Gentle pulse animation on recommended plan
- Loading states with subtle animations

### Premium Status Indicators

**Free User Indicators:**
- Usage counter in navigation bar
- Progress bar showing clothing limit
- Lock icons on premium features

**Premium User Indicators:**
- Premium badge in profile
- Unlimited indicators where relevant
- Special premium-themed accents

## Security Considerations

### Receipt Validation
- Server-side receipt validation (recommended)
- Local receipt validation as fallback
- Secure storage of validation results

### Data Protection
- Subscription data encrypted in Keychain
- No sensitive data in UserDefaults
- Proper handling of purchase receipts

### Fraud Prevention
- Receipt signature verification
- Purchase timestamp validation
- Device-specific validation tokens

## Performance Considerations

### Subscription Status Caching
- Cache subscription status locally
- Periodic background refresh
- Immediate validation on app launch

### StoreKit Optimization
- Product loading optimization
- Purchase queue management
- Proper transaction finishing

### Memory Management
- Weak references in delegates
- Proper cleanup of StoreKit observers
- Efficient image loading for paywall

## Accessibility

### VoiceOver Support
- Proper accessibility labels for all elements
- Subscription plan navigation support
- Purchase flow accessibility

### Dynamic Type Support
- Scalable text in paywall
- Flexible layout for larger text sizes
- Proper contrast ratios maintained

### Localization Ready
- Turkish language support
- Currency formatting for Turkish Lira
- Cultural considerations for pricing display