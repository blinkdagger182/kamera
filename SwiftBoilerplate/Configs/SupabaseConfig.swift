import Foundation

struct SupabaseConfig {
    // Replace these values with your Supabase project credentials
    static let apiURL = "YOUR_SUPABASE_URL"
    static let apiKey = "YOUR_SUPABASE_API_KEY"
    
    // Table names
    struct Tables {
        static let users = "users"
        static let purchases = "purchases"
        static let subscriptions = "subscriptions"
    }
    
    // Function names
    struct Functions {
        static let validateReceipt = "validate_receipt"
    }
    
    // Bucket names for storage
    struct Buckets {
        static let userAvatars = "user_avatars"
        static let appAssets = "app_assets"
    }
} 