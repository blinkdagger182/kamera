import Foundation
import StoreKit
import Combine

// MARK: - Product Types

enum ProductType: String {
    case consumable = "consumable"
    case nonConsumable = "non-consumable"
    case autoRenewableSubscription = "auto-renewable"
    case nonRenewableSubscription = "non-renewable"
}

// MARK: - Product Identifiers

struct ProductIdentifier {
    // Replace these with your actual product IDs from App Store Connect
    static let premiumSubscriptionMonthly = "com.yourapp.subscription.premium.monthly"
    static let premiumSubscriptionYearly = "com.yourapp.subscription.premium.yearly"
    static let removeAds = "com.yourapp.purchase.removeads"
    static let extraContent = "com.yourapp.purchase.extracontent"
    
    // All product IDs in an array for easy fetching
    static let allProductIDs: Set<String> = [
        premiumSubscriptionMonthly,
        premiumSubscriptionYearly,
        removeAds,
        extraContent
    ]
    
    // Mapping of product IDs to their types
    static let productTypes: [String: ProductType] = [
        premiumSubscriptionMonthly: .autoRenewableSubscription,
        premiumSubscriptionYearly: .autoRenewableSubscription,
        removeAds: .nonConsumable,
        extraContent: .consumable
    ]
}

// MARK: - StoreKit Manager

class StoreKitManager: NSObject, ObservableObject {
    // Published properties for UI updates
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var error: Error?
    
    // Services
    private let authService: AuthServiceProtocol
    
    // StoreKit properties
    private var productRequest: SKProductsRequest?
    private var updateListenerTask: Task<Void, Error>?
    private var transactionListener: Task<Void, Error>?
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        super.init()
        
        // Start listening for transactions
        startObservingPaymentQueue()
        
        // Listen for user changes to update purchased products
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user = user {
                    self?.purchasedProductIDs = Set(user.purchasedProducts)
                } else {
                    self?.purchasedProductIDs = []
                }
            }
            .store(in: &cancellables)
        
        // Request products
        Task {
            await requestProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
        transactionListener?.cancel()
    }
    
    // MARK: - Product Fetching
    
    @MainActor
    func requestProducts() async {
        isLoading = true
        
        do {
            // Request products from the App Store
            let storeProducts = try await Product.products(for: ProductIdentifier.allProductIDs)
            
            // Update the published products
            self.products = storeProducts
            isLoading = false
            
            // Check for purchased products
            await updatePurchasedProducts()
        } catch {
            self.error = error
            isLoading = false
            print("Failed to request products: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Purchase Processing
    
    @MainActor
    func purchase(_ product: Product) async throws {
        isLoading = true
        
        do {
            // Start a purchase
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check if the transaction is verified
                switch verification {
                case .verified(let transaction):
                    // Handle successful purchase
                    await handleSuccessfulPurchase(productID: transaction.productID)
                    await transaction.finish()
                case .unverified(_, let error):
                    throw error
                }
            case .userCancelled:
                print("User cancelled the purchase")
            case .pending:
                print("Purchase is pending approval")
            @unknown default:
                throw StoreKitError.unknown
            }
            
            isLoading = false
        } catch {
            isLoading = false
            self.error = error
            throw error
        }
    }
    
    // MARK: - Transaction Handling
    
    func startObservingPaymentQueue() {
        // Cancel existing listener if any
        transactionListener?.cancel()
        
        // Set up a transaction listener for StoreKit 2
        transactionListener = Task.detached {
            // Iterate through any transactions that don't have the `finished` state
            for await result in Transaction.updates {
                do {
                    switch result {
                    case .verified(let transaction):
                        // Handle successful transaction
                        await self.handleSuccessfulPurchase(productID: transaction.productID)
                        await transaction.finish()
                    case .unverified(_, let error):
                        print("Unverified transaction: \(error.localizedDescription)")
                    }
                } catch {
                    print("Transaction update error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func handleSuccessfulPurchase(productID: String) async {
        // Add to purchased products
        purchasedProductIDs.insert(productID)
        
        // Update user's purchase in database
        if let user = authService.getCurrentUser() {
            let updatedUser = user.withAddedPurchase(productId: productID)
            
            // Check if this is a subscription
            if productID == ProductIdentifier.premiumSubscriptionMonthly || 
               productID == ProductIdentifier.premiumSubscriptionYearly {
                
                // Get subscription expiry date
                if let expiryDate = await getSubscriptionExpiryDate(for: productID) {
                    let userWithSubscription = updatedUser.withUpdatedSubscription(
                        isSubscribed: true,
                        expiryDate: expiryDate
                    )
                    
                    try? await (authService as? AuthService)?.updateUser(userWithSubscription)
                } else {
                    try? await (authService as? AuthService)?.updateUser(updatedUser)
                }
            } else {
                try? await (authService as? AuthService)?.updateUser(updatedUser)
            }
        }
    }
    
    // MARK: - Subscription Management
    
    private func getSubscriptionExpiryDate(for productID: String) async -> Date? {
        do {
            // Get all transactions for the product
            let transactions = await Transaction.currentEntitlements
            
            // Find the transaction for this product
            for await result in transactions where result.productID == productID {
                switch result {
                case .verified(let transaction):
                    if let subscription = transaction as? Transaction.Subscription {
                        // Get the subscription status
                        let status = try await subscription.status
                        
                        // Check if the subscription is active
                        if status.state == .subscribed {
                            return status.expirationDate
                        }
                    }
                case .unverified:
                    continue
                }
            }
            
            return nil
        } catch {
            print("Failed to get subscription expiry date: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    func updatePurchasedProducts() async {
        do {
            // Get all transactions
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    // Add to purchased products
                    purchasedProductIDs.insert(transaction.productID)
                case .unverified:
                    continue
                }
            }
            
            // Update user if needed
            if let user = authService.getCurrentUser() {
                var updatedUser = user
                
                // Add all purchased products
                for productID in purchasedProductIDs {
                    updatedUser = updatedUser.withAddedPurchase(productId: productID)
                }
                
                // Check subscription status
                let hasActiveSubscription = await checkSubscriptionStatus()
                if hasActiveSubscription != user.hasActiveSubscription {
                    if hasActiveSubscription {
                        // Get the expiry date of the subscription
                        let expiryDate = await getSubscriptionExpiryDate(for: ProductIdentifier.premiumSubscriptionMonthly) ??
                                         await getSubscriptionExpiryDate(for: ProductIdentifier.premiumSubscriptionYearly)
                        
                        updatedUser = updatedUser.withUpdatedSubscription(
                            isSubscribed: true,
                            expiryDate: expiryDate
                        )
                    } else {
                        updatedUser = updatedUser.withUpdatedSubscription(
                            isSubscribed: false,
                            expiryDate: nil
                        )
                    }
                }
                
                // Update user in database if changes were made
                if updatedUser != user {
                    try? await (authService as? AuthService)?.updateUser(updatedUser)
                }
            }
        } catch {
            print("Failed to update purchased products: \(error.localizedDescription)")
        }
    }
    
    private func checkSubscriptionStatus() async -> Bool {
        // Check if user has an active subscription
        let subscriptionIDs = [
            ProductIdentifier.premiumSubscriptionMonthly,
            ProductIdentifier.premiumSubscriptionYearly
        ]
        
        for productID in subscriptionIDs {
            if let expiryDate = await getSubscriptionExpiryDate(for: productID),
               expiryDate > Date() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Product Helpers
    
    func product(for identifier: String) -> Product? {
        return products.first { $0.id == identifier }
    }
    
    func isPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    func subscriptionProducts() -> [Product] {
        return products.filter { product in
            if let type = ProductIdentifier.productTypes[product.id] {
                return type == .autoRenewableSubscription || type == .nonRenewableSubscription
            }
            return false
        }
    }
    
    func nonConsumableProducts() -> [Product] {
        return products.filter { product in
            if let type = ProductIdentifier.productTypes[product.id] {
                return type == .nonConsumable
            }
            return false
        }
    }
    
    func consumableProducts() -> [Product] {
        return products.filter { product in
            if let type = ProductIdentifier.productTypes[product.id] {
                return type == .consumable
            }
            return false
        }
    }
}

// MARK: - Custom Errors

enum StoreKitError: Error, LocalizedError {
    case unknown
    case productNotFound
    case purchaseFailed
    case receiptValidationFailed
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred"
        case .productNotFound:
            return "The requested product could not be found"
        case .purchaseFailed:
            return "The purchase could not be completed"
        case .receiptValidationFailed:
            return "Receipt validation failed"
        }
    }
} 