import SwiftUI
import Supabase

@main
struct SwiftBoilerplateApp: App {
    // Initialize app-wide services and state
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var storeKitManager = StoreKitManager()
    
    // Initialize Supabase client
    init() {
        // Setup will be done in the AuthService
        print("SwiftBoilerplate App Initializing")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(storeKitManager)
                .onAppear {
                    // Initialize services when app appears
                    authViewModel.checkAuthStatus()
                    storeKitManager.startObservingPaymentQueue()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            SubscriptionsView()
                .tabItem {
                    Label("Subscriptions", systemImage: "creditcard")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
} 