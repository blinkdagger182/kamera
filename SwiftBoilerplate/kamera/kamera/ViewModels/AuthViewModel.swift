import Foundation
import Combine
import AuthenticationServices
import Supabase

class AuthViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    // Services
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        
        // Subscribe to auth state changes
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    
    func checkAuthStatus() {
        isLoading = true
        
        Task {
            do {
                try await authService.refreshSession()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                print("Failed to refresh session: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    isAuthenticated = false
                    currentUser = nil
                }
            }
        }
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        
        Task {
            do {
                // Get the identity token
                guard let identityToken = credential.identityToken,
                      let tokenString = String(data: identityToken, encoding: .utf8) else {
                    throw AuthError.invalidCredential
                }
                
                // Get user details
                let userId = credential.user
                let email = credential.email
                let fullName = credential.fullName
                
                // Sign in with Supabase
                try await authService.signInWithApple(
                    idToken: tokenString,
                    userId: userId,
                    email: email,
                    fullName: fullName
                )
                
                await MainActor.run {
                    isLoading = false
                    completion(true, nil)
                }
            } catch {
                print("Apple sign in failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    completion(false, error)
                }
            }
        }
    }
    
    func signInAnonymously() {
        isLoading = true
        
        Task {
            do {
                try await authService.signInAnonymously()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                print("Anonymous sign in failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        isLoading = true
        
        Task {
            do {
                try await authService.signOut()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                print("Sign out failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Custom Errors

enum AuthError: Error, LocalizedError {
    case invalidCredential
    case sessionExpired
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid authentication credentials"
        case .sessionExpired:
            return "Your session has expired. Please sign in again"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 