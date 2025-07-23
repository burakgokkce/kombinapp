import SwiftUI

struct PremiumFeatureGate<Content: View>: View {
    let feature: PremiumFeature
    let content: () -> Content
    
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageTracker: UsageTracker
    @State private var showPaywall = false
    
    init(feature: PremiumFeature, @ViewBuilder content: @escaping () -> Content) {
        self.feature = feature
        self.content = content
        self._usageTracker = StateObject(wrappedValue: UsageTracker(subscriptionManager: SubscriptionManager()))
    }
    
    var body: some View {
        Group {
            if usageTracker.canAccessFeature(feature) {
                content()
            } else {
                lockedFeatureView
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onChange(of: usageTracker.shouldShowPaywall) { shouldShow in
            if shouldShow {
                showPaywall = true
                usageTracker.shouldShowPaywall = false
            }
        }
    }
    
    private var lockedFeatureView: some View {
        VStack(spacing: 15) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("Premium Özellik")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(feature.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Premium'a Geç") {
                showPaywall = true
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(
                    colors: [Color.pink, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Usage Limit Gate
struct UsageLimitGate<Content: View>: View {
    let limitType: UsageLimitType
    let content: () -> Content
    let onLimitReached: (() -> Void)?
    
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageTracker: UsageTracker
    @State private var showPaywall = false
    
    init(
        limitType: UsageLimitType,
        onLimitReached: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.limitType = limitType
        self.onLimitReached = onLimitReached
        self.content = content
        self._usageTracker = StateObject(wrappedValue: UsageTracker(subscriptionManager: SubscriptionManager()))
    }
    
    var body: some View {
        Group {
            if canProceed {
                content()
            } else {
                limitReachedView
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onChange(of: usageTracker.shouldShowPaywall) { shouldShow in
            if shouldShow {
                showPaywall = true
                usageTracker.shouldShowPaywall = false
            }
        }
    }
    
    private var canProceed: Bool {
        switch limitType {
        case .clothing:
            return usageTracker.canAccessFeature(.unlimitedClothing)
        case .outfitGeneration:
            return usageTracker.canAccessFeature(.unlimitedOutfits)
        }
    }
    
    private var limitReachedView: some View {
        VStack(spacing: 20) {
            Image(systemName: limitType.iconName)
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text(limitType.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(limitType.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                Button("Premium'a Geç") {
                    showPaywall = true
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [Color.pink, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                if let onLimitReached = onLimitReached {
                    Button("Geri Dön") {
                        onLimitReached()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Usage Limit Type
enum UsageLimitType {
    case clothing
    case outfitGeneration
    
    var iconName: String {
        switch self {
        case .clothing:
            return "tshirt.fill"
        case .outfitGeneration:
            return "sparkles"
        }
    }
    
    var title: String {
        switch self {
        case .clothing:
            return "Kıyafet Limiti Doldu"
        case .outfitGeneration:
            return "Günlük Limit Doldu"
        }
    }
    
    var message: String {
        switch self {
        case .clothing:
            return "Ücretsiz kullanımda en fazla 3 kıyafet ekleyebilirsiniz. Premium ile sınırsız kıyafet ekleyin!"
        case .outfitGeneration:
            return "Günlük kombin oluşturma limitiniz doldu. Premium ile sınırsız kombin oluşturun!"
        }
    }
}

// MARK: - Premium Status Badge
struct PremiumStatusBadge: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        Group {
            if subscriptionManager.subscriptionStatus.isPremium {
                HStack(spacing: 5) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                    Text("PREMIUM")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.8))
                )
            }
        }
    }
}

// MARK: - Usage Counter View
struct UsageCounterView: View {
    let type: UsageCounterType
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageTracker: UsageTracker
    
    init(type: UsageCounterType) {
        self.type = type
        self._usageTracker = StateObject(wrappedValue: UsageTracker(subscriptionManager: SubscriptionManager()))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: type.iconName)
                .font(.caption)
                .foregroundColor(type.color)
            
            Text(usageText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var usageText: String {
        let stats = usageTracker.getUsageStatistics()
        
        switch type {
        case .clothing:
            return stats.clothingUsageText
        case .outfitGeneration:
            return stats.outfitUsageText
        }
    }
}

enum UsageCounterType {
    case clothing
    case outfitGeneration
    
    var iconName: String {
        switch self {
        case .clothing:
            return "tshirt.fill"
        case .outfitGeneration:
            return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing:
            return .blue
        case .outfitGeneration:
            return .purple
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumFeatureGate(feature: .themeCustomization) {
            Text("Theme Customization Content")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
        }
        
        UsageCounterView(type: .clothing)
        UsageCounterView(type: .outfitGeneration)
        PremiumStatusBadge()
    }
    .padding()
}