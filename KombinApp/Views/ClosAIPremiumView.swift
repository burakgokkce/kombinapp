import SwiftUI
import StoreKit

struct ClosAIPremiumView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedPlan: SubscriptionType = .monthly
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient - Pembe-Lila Pastel Tema
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.92, blue: 0.96), // Açık pembe
                        Color(red: 0.94, green: 0.94, blue: 0.98), // Açık lila
                        Color(red: 0.96, green: 0.90, blue: 0.98)  // Pembe-lila karışımı
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header Section
                        headerSection
                        
                        // Features Section
                        featuresSection
                        
                        // Subscription Plans Section
                        subscriptionPlansSection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        // Footer
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
                
                ToolbarItem(placement: .principal) {
                    Text("ClosAI Premium")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Tamam") {
                if alertTitle == "Premium Aktif!" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            Task {
                await subscriptionManager.loadProducts()
            }
        }
        .onChange(of: subscriptionManager.errorMessage) { errorMessage in
            if let error = errorMessage {
                alertTitle = "Hata"
                alertMessage = error
                showingAlert = true
            }
        }
        .onChange(of: subscriptionManager.isPremium) { isPremium in
            if isPremium && subscriptionManager.errorMessage == nil {
                alertTitle = "Premium Aktif!"
                alertMessage = "ClosAI Premium üyeliğiniz başarıyla aktifleştirildi! Artık sınırsız kıyafet ekleyebilir ve yapay zeka ile kombin önerilerinden yararlanabilirsiniz."
                showingAlert = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Premium Badge
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
                Text("CLOSAI PREMIUM")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.15 : 0.8))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            
            // Main Title
            VStack(spacing: 8) {
                Text("Yapay Zeka ile")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Sınırsız Kombin")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Gardırobunuzu AI ile optimize edin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("Premium Özellikler")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                FeatureCard(
                    icon: "tshirt.fill",
                    title: "Sınırsız Kıyafet Ekleme",
                    description: "İstediğiniz kadar kıyafet ekleyin ve organize edin",
                    color: .pink
                )
                
                FeatureCard(
                    icon: "brain.head.profile",
                    title: "Yapay Zeka ile Kombin Önerisi",
                    description: "AI algoritması ile kişiselleştirilmiş kombin önerileri",
                    color: .purple
                )
                
                FeatureCard(
                    icon: "sparkles",
                    title: "Günlük Stil Önerileri",
                    description: "Her gün yeni ve trend kombin önerileri",
                    color: .blue
                )
                
                FeatureCard(
                    icon: "heart.fill",
                    title: "Sınırsız Favori",
                    description: "Beğendiğiniz kombinleri kaydedin ve organize edin",
                    color: .red
                )
            }
        }
    }
    
    // MARK: - Subscription Plans Section
    private var subscriptionPlansSection: some View {
        VStack(spacing: 20) {
            Text("Abonelik Planları")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if subscriptionManager.isLoading && subscriptionManager.availableProducts.isEmpty {
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.pink)
                    
                    Text("Abonelik planları yükleniyor...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.7))
                )
            } else if subscriptionManager.availableProducts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 50))
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
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.pink, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.7))
                )
            } else {
                VStack(spacing: 15) {
                    ForEach(SubscriptionType.allCases, id: \.self) { plan in
                        if let product = subscriptionManager.getProduct(for: plan) {
                            PremiumPlanCard(
                                plan: plan,
                                product: product,
                                isSelected: selectedPlan == plan,
                                colorScheme: colorScheme
                            ) {
                                selectedPlan = plan
                            }
                        } else {
                            PremiumPlanCard(
                                plan: plan,
                                isSelected: selectedPlan == plan,
                                colorScheme: colorScheme
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
        VStack(spacing: 16) {
            // Subscribe Button
            Button(action: {
                Task {
                    await subscriptionManager.purchaseSubscription(selectedPlan)
                }
            }) {
                HStack(spacing: 12) {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                        Text("Premium'a Başla")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.4, blue: 0.7), // Pembe
                            Color(red: 0.7, green: 0.5, blue: 0.9)  // Lila
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                .scaleEffect(subscriptionManager.isLoading ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: subscriptionManager.isLoading)
            }
            .disabled(subscriptionManager.isLoading || subscriptionManager.availableProducts.isEmpty)
            
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
        VStack(spacing: 12) {
            HStack(spacing: 25) {
                Button("Kullanım Şartları") {
                    // Terms action
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Button("Gizlilik Politikası") {
                    // Privacy action
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Text("Abonelik otomatik olarak yenilenir. İptal etmek için App Store ayarlarından aboneliklerinizi yönetin.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 35, height: 35)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Premium Plan Card
struct PremiumPlanCard: View {
    let plan: SubscriptionType
    var product: Product?
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onTap: () -> Void
    
    init(plan: SubscriptionType, product: Product? = nil, isSelected: Bool, colorScheme: ColorScheme, onTap: @escaping () -> Void) {
        self.plan = plan
        self.product = product
        self.isSelected = isSelected
        self.colorScheme = colorScheme
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(plan.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if plan.isRecommended {
                                Text("ÖNERİLEN")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.orange)
                                    )
                            }
                            
                            Spacer()
                        }
                        
                        if let product = product {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text(product.displayPrice)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("/ \(plan.duration)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text(plan.price)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("/ \(plan.duration)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(isSelected ? .pink : .gray)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
                
                // Features for this plan
                VStack(alignment: .leading, spacing: 8) {
                    ClosAIFeatureRow(text: "Sınırsız kıyafet ekleme")
                    ClosAIFeatureRow(text: "Yapay zeka ile kombin önerisi")
                    ClosAIFeatureRow(text: "Günlük stil önerileri")
                    ClosAIFeatureRow(text: "Sınırsız favori")
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(colorScheme == .dark ? (isSelected ? 0.2 : 0.1) : (isSelected ? 0.95 : 0.7)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: isSelected ? [Color.pink, Color.purple] : [Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
                    .shadow(
                        color: .black.opacity(isSelected ? 0.15 : 0.05),
                        radius: isSelected ? 12 : 4,
                        x: 0,
                        y: isSelected ? 6 : 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - ClosAI Feature Row
struct ClosAIFeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.bold)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    ClosAIPremiumView()
}