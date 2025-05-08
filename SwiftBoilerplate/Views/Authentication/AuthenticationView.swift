import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo and welcome text
                VStack(spacing: 20) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("Welcome to SwiftBoilerplate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Sign in to access all features")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Sign in buttons
                VStack(spacing: 16) {
                    // Sign in with Apple button
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleSignInWithAppleResult(result)
                        }
                    )
                    .frame(height: 50)
                    .cornerRadius(8)
                    
                    // Continue as guest button
                    Button(action: {
                        // Handle guest login
                        authViewModel.signInAnonymously()
                    }) {
                        Text("Continue as Guest")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Authentication Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Process Apple ID credential
                authViewModel.signInWithApple(credential: appleIDCredential) { success, error in
                    isLoading = false
                    
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            } else {
                isLoading = false
                errorMessage = "Could not get Apple ID credentials"
                showError = true
            }
            
        case .failure(let error):
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
} 