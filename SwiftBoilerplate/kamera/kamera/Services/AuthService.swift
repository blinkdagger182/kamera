import Foundation
import Combine
import Supabase
import AuthenticationServices

// Protocol for easier testing and dependency injection
protocol AuthServiceProtocol {
    var authStatePublisher: AnyPublisher<User?, Never> { get }
    func refreshSession() async throws
    func signInWithApple(idToken: String, userId: String, email: String?, fullName: PersonNameComponents?) async throws
    func signInAnonymously() async throws
    func signOut() async throws
    func getCurrentUser() -> User?
}

class AuthService: AuthServiceProtocol {
    // Singleton instance
    static let shared = AuthService()
    
    // Supabase client
    private let supabase: SupabaseClient
    
    // Auth state publisher
    private let authStateSubject = CurrentValueSubject<User?, Never>(nil)
    var authStatePublisher: AnyPublisher<User?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    private init() {
        // Initialize Supabase client
        let supabaseURL = URL(string: SupabaseConfig.apiURL)!
        let supabaseKey = SupabaseConfig.apiKey
        
        self.supabase = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
        
        // Try to restore session from keychain
        Task {
            do {
                try await refreshSession()
            } catch {
                print("Failed to restore session: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func refreshSession() async throws {
        do {
            let session = try await supabase.auth.session
            
            // Fetch user data from Supabase
            if let userId = session.user.id.uuidString {
                let response = try await supabase.database
                    .from("users")
                    .select()
                    .eq("id", value: userId)
                    .single()
                    .execute()
                
                if let data = response.data,
                   let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let user = User.fromSupabase(jsonObject) {
                    authStateSubject.send(user)
                } else {
                    // Create user if not exists
                    let newUser = User(id: userId)
                    try await createUserInDatabase(newUser)
                    authStateSubject.send(newUser)
                }
            }
        } catch {
            authStateSubject.send(nil)
            throw error
        }
    }
    
    func signInWithApple(idToken: String, userId: String, email: String?, fullName: PersonNameComponents?) async throws {
        do {
            // Sign in with Supabase using Apple token
            let response = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken
                )
            )
            
            let supabaseUserId = response.user.id.uuidString
            
            // Check if user exists in database
            let userResponse = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: supabaseUserId)
                .single()
                .execute()
            
            if userResponse.data == nil {
                // Create new user in database
                let newUser = User(
                    id: supabaseUserId,
                    email: email,
                    firstName: fullName?.givenName,
                    lastName: fullName?.familyName
                )
                
                try await createUserInDatabase(newUser)
                authStateSubject.send(newUser)
            } else {
                // User exists, refresh session to get latest data
                try await refreshSession()
            }
        } catch {
            print("Error signing in with Apple: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signInAnonymously() async throws {
        do {
            // Generate a random email and password for anonymous auth
            let uuid = UUID().uuidString
            let email = "\(uuid)@anonymous.com"
            let password = UUID().uuidString
            
            // Sign up with Supabase
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            guard let userId = response.user.id.uuidString else {
                throw AuthError.unknown
            }
            
            // Create user in database
            let newUser = User(id: userId)
            try await createUserInDatabase(newUser)
            
            authStateSubject.send(newUser)
        } catch {
            print("Error signing in anonymously: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            authStateSubject.send(nil)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getCurrentUser() -> User? {
        return authStateSubject.value
    }
    
    // MARK: - Helper Methods
    
    private func createUserInDatabase(_ user: User) async throws {
        let userData = user.toSupabase()
        
        try await supabase.database
            .from("users")
            .insert(userData)
            .execute()
    }
    
    func updateUser(_ user: User) async throws {
        let userData = user.toSupabase()
        
        try await supabase.database
            .from("users")
            .update(userData)
            .eq("id", value: user.id)
            .execute()
        
        // Update local state
        authStateSubject.send(user)
    }
} 