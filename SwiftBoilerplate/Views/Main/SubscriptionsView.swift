import SwiftUI
import StoreKit

struct SubscriptionsView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var selectedSubscriptionIndex = 0
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Premium Subscription")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock all features and remove ads")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Subscription status
                    subscriptionStatusView
                    
                    // Subscription options
                    if !storeKitManager.subscriptionProducts().isEmpty {
                        subscriptionOptionsView
                    } else {
                        loadingView
                    }
                    
                    // Features list
                    featuresListView
                    
                    // Purchase button
                    purchaseButtonView
                    
                    // Restore purchases button
                    Button(action: {
                        Task {
                            await storeKitManager.updatePurchasedProducts()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("Subscriptions")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
    }
    
    // MARK: - Subscription Status View
    
    private var subscriptionStatusView: some View {
        VStack(spacing: 10) {
            if let user = authViewModel.currentUser, user.hasActiveSubscription {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("Active Subscription")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                if let expiryDate = user.subscriptionExpiryDate {
                    Text("Expires on \(formattedDate(expiryDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("No Active Subscription")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Text("Subscribe to unlock premium features")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Subscription Options View
    
    private var subscriptionOptionsView: some View {
        VStack(spacing: 16) {
            Text("Choose a Plan")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(Array(storeKitManager.subscriptionProducts().enumerated()), id: \.element.id) { index, product in
                subscriptionOptionCard(product: product, isSelected: selectedSubscriptionIndex == index)
                    .onTapGesture {
                        selectedSubscriptionIndex = index
                    }
            }
        }
    }
    
    private func subscriptionOptionCard(product: Product, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                if let subscription = product.subscription {
                    Text("\(formattedPrice(product)) / \(subscription.subscriptionPeriod.displayUnit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(formattedPrice(product))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.title2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    // MARK: - Features List View
    
    private var featuresListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Features")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            featureRow(icon: "checkmark.circle.fill", title: "Remove all ads", description: "Enjoy an ad-free experience")
            featureRow(icon: "checkmark.circle.fill", title: "Unlimited access", description: "Access all content without restrictions")
            featureRow(icon: "checkmark.circle.fill", title: "Premium support", description: "Get priority customer support")
            featureRow(icon: "checkmark.circle.fill", title: "Offline mode", description: "Download content for offline use")
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Purchase Button View
    
    private var purchaseButtonView: some View {
        Button(action: {
            purchaseSelectedSubscription()
        }) {
            if let user = authViewModel.currentUser, user.hasActiveSubscription {
                Text("Manage Subscription")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            } else {
                let products = storeKitManager.subscriptionProducts()
                if !products.isEmpty && selectedSubscriptionIndex < products.count {
                    Text("Subscribe for \(formattedPrice(products[selectedSubscriptionIndex]))")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                } else {
                    Text("Subscribe")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        .disabled(storeKitManager.subscriptionProducts().isEmpty)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading subscription options...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func formattedPrice(_ product: Product) -> String {
        return product.displayPrice
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func purchaseSelectedSubscription() {
        let products = storeKitManager.subscriptionProducts()
        
        if let user = authViewModel.currentUser, user.hasActiveSubscription {
            // Open subscription management
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                UIApplication.shared.open(url)
            }
        } else if !products.isEmpty && selectedSubscriptionIndex < products.count {
            // Purchase the selected subscription
            let selectedProduct = products[selectedSubscriptionIndex]
            
            isLoading = true
            
            Task {
                do {
                    try await storeKitManager.purchase(selectedProduct)
                    await MainActor.run {
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    }
}

// MARK: - Subscription Period Extension

extension Product.SubscriptionPeriod {
    var displayUnit: String {
        switch self.unit {
        case .day:
            return self.value == 1 ? "day" : "\(self.value) days"
        case .week:
            return self.value == 1 ? "week" : "\(self.value) weeks"
        case .month:
            return self.value == 1 ? "month" : "\(self.value) months"
        case .year:
            return self.value == 1 ? "year" : "\(self.value) years"
        @unknown default:
            return "\(self.value) \(self.unit)"
        }
    }
}

struct SubscriptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionsView()
            .environmentObject(StoreKitManager())
            .environmentObject(AuthViewModel())
    }
} 