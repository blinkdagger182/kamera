import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let createdAt: Date
    let updatedAt: Date
    var isSubscribed: Bool
    var subscriptionExpiryDate: Date?
    var purchasedProducts: [String]
    
    // Computed properties
    var fullName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let lastName = lastName {
            return lastName
        } else {
            return "User"
        }
    }
    
    var hasActiveSubscription: Bool {
        guard isSubscribed, let expiryDate = subscriptionExpiryDate else {
            return false
        }
        return expiryDate > Date()
    }
    
    // Initializer with default values
    init(
        id: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSubscribed: Bool = false,
        subscriptionExpiryDate: Date? = nil,
        purchasedProducts: [String] = []
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSubscribed = isSubscribed
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.purchasedProducts = purchasedProducts
    }
    
    // Equatable implementation
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helper methods
    func hasPurchased(productId: String) -> Bool {
        return purchasedProducts.contains(productId)
    }
    
    // Create a copy with updated subscription status
    func withUpdatedSubscription(isSubscribed: Bool, expiryDate: Date?) -> User {
        var updatedUser = self
        updatedUser.isSubscribed = isSubscribed
        updatedUser.subscriptionExpiryDate = expiryDate
        return updatedUser
    }
    
    // Add a purchased product
    func withAddedPurchase(productId: String) -> User {
        var updatedUser = self
        if !updatedUser.purchasedProducts.contains(productId) {
            updatedUser.purchasedProducts.append(productId)
        }
        return updatedUser
    }
}

// MARK: - Supabase Mapping Extensions

extension User {
    // Convert from Supabase JSON response
    static func fromSupabase(_ json: [String: Any]) -> User? {
        guard let id = json["id"] as? String else { return nil }
        
        let email = json["email"] as? String
        let firstName = json["first_name"] as? String
        let lastName = json["last_name"] as? String
        
        // Parse dates
        let createdAt: Date
        if let createdAtString = json["created_at"] as? String,
           let date = ISO8601DateFormatter().date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = Date()
        }
        
        let updatedAt: Date
        if let updatedAtString = json["updated_at"] as? String,
           let date = ISO8601DateFormatter().date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = Date()
        }
        
        // Subscription details
        let isSubscribed = json["is_subscribed"] as? Bool ?? false
        
        let subscriptionExpiryDate: Date?
        if let expiryString = json["subscription_expiry_date"] as? String,
           let date = ISO8601DateFormatter().date(from: expiryString) {
            subscriptionExpiryDate = date
        } else {
            subscriptionExpiryDate = nil
        }
        
        // Purchased products
        let purchasedProducts: [String]
        if let productsArray = json["purchased_products"] as? [String] {
            purchasedProducts = productsArray
        } else {
            purchasedProducts = []
        }
        
        return User(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSubscribed: isSubscribed,
            subscriptionExpiryDate: subscriptionExpiryDate,
            purchasedProducts: purchasedProducts
        )
    }
    
    // Convert to Supabase JSON format
    func toSupabase() -> [String: Any] {
        var json: [String: Any] = [
            "id": id,
            "is_subscribed": isSubscribed,
            "purchased_products": purchasedProducts
        ]
        
        if let email = email {
            json["email"] = email
        }
        
        if let firstName = firstName {
            json["first_name"] = firstName
        }
        
        if let lastName = lastName {
            json["last_name"] = lastName
        }
        
        if let expiryDate = subscriptionExpiryDate {
            json["subscription_expiry_date"] = ISO8601DateFormatter().string(from: expiryDate)
        }
        
        return json
    }
} 