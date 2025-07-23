import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var subscriptionStatus: SubscriptionStatus = .loading
    @Published var availableProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @AppStorage("isPremium") var isPremium: Bool = false
    
    private let productIdentifiers: Set<String> = Set(SubscriptionType.allCases.map { $0.rawValue })
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        do {
            isLoading = true
            errorMessage = nil
            
            // Debug: Print product identifiers being requested
            print("🛒 ClosAI: Requesting products with IDs: \(productIdentifiers)")
            
            let products = try await Product.products(for: productIdentifiers)
            
            if products.isEmpty {
                errorMessage = "ClosAI Premium planları yüklenemedi. Lütfen internet bağlantınızı kontrol edin."
                subscriptionStatus = .error("ClosAI Premium planları yüklenemedi")
            } else {
                // Debug: Print found products
                print("✅ ClosAI: Found \(products.count) products: \(products.map { "\($0.id) - \($0.displayPrice)" })")
                
                availableProducts = products.sorted { product1, product2 in
                    // Sort by subscription type order: weekly, monthly, yearly
                    let type1 = SubscriptionType(rawValue: product1.id) ?? .monthly
                    let type2 = SubscriptionType(rawValue: product2.id) ?? .monthly
                    
                    let order: [SubscriptionType] = [.weekly, .monthly, .yearly]
                    let index1 = order.firstIndex(of: type1) ?? 1
                    let index2 = order.firstIndex(of: type2) ?? 1
                    
                    return index1 < index2
                }
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Ürün bilgisi alınamadı. Lütfen bağlantınızı kontrol edin."
            subscriptionStatus = .error(error.localizedDescription)
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Methods
    func purchaseProduct(_ product: Product) async {
        do {
            isLoading = true
            errorMessage = nil
            
            print("🛒 ClosAI: Starting purchase for product: \(product.id) - \(product.displayPrice)")
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("✅ Purchase successful and verified: \(transaction.productID)")
                    // Transaction is verified, grant access
                    await handleSuccessfulPurchase(transaction)
                    await transaction.finish()
                    errorMessage = nil // Clear any previous errors
                    
                case .unverified(_, let error):
                    print("❌ Purchase unverified: \(error)")
                    errorMessage = "Satın alma doğrulanamadı. Lütfen tekrar deneyin."
                }
                
            case .userCancelled:
                print("🚫 Purchase cancelled by user")
                errorMessage = nil // Don't show error for user cancellation
                
            case .pending:
                print("⏳ Purchase pending")
                errorMessage = "Satın alma işlemi beklemede. Lütfen bekleyin."
                
            @unknown default:
                print("❓ Unknown purchase result")
                errorMessage = "Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin."
            }
            
            isLoading = false
        } catch {
            isLoading = false
            print("❌ Purchase failed with error: \(error)")
            
            if error.localizedDescription.contains("cancelled") {
                errorMessage = nil // Don't show error for cancellation
            } else {
                errorMessage = "Satın alma başarısız. Lütfen internet bağlantınızı kontrol edin."
            }
            errorMessage = "Satın alma başarısız: \(error.localizedDescription)"
            print("Purchase failed: \(error)")
        }
    }
    
    func purchaseSubscription(_ type: SubscriptionType) async {
        guard let product = availableProducts.first(where: { $0.id == type.rawValue }) else {
            print("❌ Product not found for type: \(type.rawValue)")
            errorMessage = "Seçilen abonelik planı bulunamadı. Lütfen ürünleri yeniden yükleyin."
            // Try to reload products
            await loadProducts()
            return
        }
        
        await purchaseProduct(product)
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            isLoading = true
            errorMessage = nil
            
            try await AppStore.sync()
            await checkSubscriptionStatus()
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Satın almalar geri yüklenemedi: \(error.localizedDescription)"
            print("Restore failed: \(error)")
        }
    }
    
    // MARK: - Subscription Status
    func checkSubscriptionStatus() async {
        var hasActiveSubscription = false
        
        for await result in StoreKit.Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIdentifiers.contains(transaction.productID) {
                    hasActiveSubscription = true
                    
                    if let subscriptionType = SubscriptionType(rawValue: transaction.productID) {
                        let expiryDate = transaction.expirationDate ?? Date.distantFuture
                        subscriptionStatus = .premium(expiryDate: expiryDate, type: subscriptionType)
                    }
                    break
                }
                
            case .unverified(_, let error):
                print("Unverified transaction: \(error)")
            }
        }
        
        if !hasActiveSubscription {
            subscriptionStatus = .free
            isPremium = false
        } else {
            isPremium = true
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await self.handleSuccessfulPurchase(transaction)
                    await transaction.finish()
                    
                case .unverified(_, let error):
                    print("Unverified transaction update: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func handleSuccessfulPurchase(_ transaction: StoreKit.Transaction) async {
        guard let subscriptionType = SubscriptionType(rawValue: transaction.productID) else { 
            print("❌ Unknown product ID: \(transaction.productID)")
            return 
        }
        
        let expiryDate = transaction.expirationDate ?? Date.distantFuture
        subscriptionStatus = .premium(expiryDate: expiryDate, type: subscriptionType)
        isPremium = true
        
        print("🎉 Successfully activated premium: \(subscriptionType.displayName) until \(expiryDate)")
        
        // Clear any error messages
        errorMessage = nil
    }
    
    func getProduct(for type: SubscriptionType) -> Product? {
        return availableProducts.first { $0.id == type.rawValue }
    }
    
    // MARK: - Product Information
    func getDisplayPrice(for product: Product) -> String {
        return product.displayPrice
    }
    
    func getLocalizedPrice(for type: SubscriptionType) -> String {
        if let product = getProduct(for: type) {
            return product.displayPrice
        }
        return type.price // Fallback to hardcoded price
    }
}