import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedPlan: SubscriptionType = .monthly
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.94, blue: 0.96), // Light Pink
                        Color(red: 0.97, green: 0.97, blue: 1.0)  // Light Purple
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerSection
                        
                        // Features
                        featuresSection
                        
                        // Subscription Plans
                        subscriptionPlansSection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        // Footer Links
                        footerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            // Auto-retry loading products if they failed to load initially
            if subscriptionManager.availableProducts.isEmpty && subscriptionManager.errorMessage != nil {
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                    await subscriptionManager.loadProducts()
                }
            }
        }
        .sheet(isPresented: $showingTerms) {
            SafariView(url: URL(string: "https://example.com/terms")!)
        }
        .sheet(isPresented: $showingPrivacy) {
            SafariView(url: URL(string: "https://example.com/privacy")!)
        }
        .alert("Hata", isPresented: .constant(subscriptionManager.errorMessage != nil)) {
            Button("Tamam") {
                subscriptionManager.errorMessage = nil
            }
        } message: {
            Text(subscriptionManager.errorMessage ?? "")
        }
        .alert("Premium Aktif!", isPresented: .constant(subscriptionManager.isPremium && subscriptionManager.errorMessage == nil)) {
            Button("Harika!") {
                dismiss()
            }
        } message: {
            Text("Premium üyeliğiniz başarıyla aktifleştirildi. Artık tüm özellikleri kullanabilirsiniz!")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 15) {
            // Premium Badge
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("PREMIUM")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            
            // Title
            Text("Daha fazla kombin için\nPremium'a geç")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            // Subtitle
            Text("Sınırsız kıyafet, kombin ve özel özellikler")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 15) {
            ForEach(PremiumFeature.allCases, id: \.self) { feature in
                PaywallFeatureRow(feature: feature)
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Subscription Plans Section
    private var subscriptionPlansSection: some View {
        VStack(spacing: 15) {
            Text("Abonelik Seçenekleri")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if subscriptionManager.isLoading && subscriptionManager.availableProducts.isEmpty {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Ürünler yükleniyor...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.7))
                )
            } else if subscriptionManager.availableProducts.isEmpty && subscriptionManager.errorMessage != nil {
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text("Abonelik planları yüklenemedi")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Lütfen internet bağlantınızı kontrol edin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Tekrar Dene") {
                        Task {
                            await subscriptionManager.loadProducts()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.7))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(SubscriptionType.allCases, id: \.self) { plan in
                        if let product = subscriptionManager.getProduct(for: plan) {
                            SubscriptionPlanCard(
                                plan: plan,
                                product: product,
                                isSelected: selectedPlan == plan,
                                isRecommended: plan.isRecommended
                            ) {
                                selectedPlan = plan
                            }
                        } else {
                            SubscriptionPlanCard(
                                plan: plan,
                                isSelected: selectedPlan == plan,
                                isRecommended: plan.isRecommended
                            ) {
                                selectedPlan = plan
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            // Subscribe Button
            Button(action: {
                Task {
                    await subscriptionManager.purchaseSubscription(selectedPlan)
                    // If purchase was successful, dismiss the paywall
                    if subscriptionManager.isPremium {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "crown.fill")
                        Text("Premium'a Başla")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.4, blue: 0.7), // Pink
                            Color(red: 0.7, green: 0.5, blue: 0.9)  // Purple
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .disabled(subscriptionManager.isLoading)
            
            // Restore Button
            Button("Satın Alımları Geri Yükle") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .disabled(subscriptionManager.isLoading)
        }
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                Button("Kullanım Şartları") {
                    showingTerms = true
                }
                
                Button("Gizlilik Politikası") {
                    showingPrivacy = true
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text("Abonelik otomatik olarak yenilenir. İptal etmek için App Store ayarlarından aboneliklerinizi yönetin.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
    }
}

// MARK: - Paywall Feature Row
struct PaywallFeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: feature.iconName)
                .font(.title2)
                .foregroundColor(.pink)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

// MARK: - Subscription Plan Card
struct SubscriptionPlanCard: View {
    let plan: SubscriptionType
    var product: Product?
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    init(plan: SubscriptionType, product: Product? = nil, isSelected: Bool, isRecommended: Bool, onTap: @escaping () -> Void) {
        self.plan = plan
        self.product = product
        self.isSelected = isSelected
        self.isRecommended = isRecommended
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(plan.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if isRecommended {
                            Text("ÖNERİLEN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange)
                                )
                        }
                        
                        Spacer()
                    }
                    
                    if let product = product {
                        Text("\(product.displayPrice) / \(plan.duration)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(plan.price) / \(plan.duration)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .pink : .gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(isSelected ? 0.9 : 0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isSelected ? Color.pink : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: .black.opacity(isSelected ? 0.1 : 0.05),
                        radius: isSelected ? 8 : 3,
                        x: 0,
                        y: isSelected ? 4 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

import SafariServices

#Preview {
    PaywallView()
}