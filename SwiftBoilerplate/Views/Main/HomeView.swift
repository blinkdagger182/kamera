import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome header
                    welcomeHeader
                    
                    // Subscription status card
                    subscriptionStatusCard
                    
                    // Features grid
                    featuresGrid
                    
                    // Quick actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Profile or settings action
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(authViewModel.currentUser?.fullName ?? "User")")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Here's what's new today")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    // MARK: - Subscription Status Card
    
    private var subscriptionStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Subscription")
                        .font(.headline)
                    
                    if let user = authViewModel.currentUser, user.hasActiveSubscription {
                        Text("Premium (Active)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        Text("Free Plan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                NavigationLink(destination: SubscriptionsView()) {
                    Text(authViewModel.currentUser?.hasActiveSubscription ?? false ? "Manage" : "Upgrade")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            
            if let user = authViewModel.currentUser, user.hasActiveSubscription {
                if let expiryDate = user.subscriptionExpiryDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        
                        Text("Renews on \(formattedDate(expiryDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Upgrade to Premium for full access")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Features Grid
    
    private var featuresGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                featureCard(icon: "doc.text", title: "Documents", isPremium: false)
                featureCard(icon: "photo", title: "Photos", isPremium: false)
                featureCard(icon: "lock.shield", title: "Secure Storage", isPremium: true)
                featureCard(icon: "arrow.down.circle", title: "Downloads", isPremium: true)
            }
        }
    }
    
    private func featureCard(icon: String, title: String, isPremium: Bool) -> some View {
        let isAccessible = !isPremium || (authViewModel.currentUser?.hasActiveSubscription ?? false)
        
        return VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(isAccessible ? .blue : .gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(isAccessible ? .primary : .secondary)
            
            if isPremium && !isAccessible {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                quickActionButton(icon: "arrow.clockwise", title: "Sync") {
                    // Sync action
                }
                
                quickActionButton(icon: "square.and.arrow.up", title: "Share") {
                    // Share action
                }
                
                quickActionButton(icon: "gear", title: "Settings") {
                    // Settings action
                }
                
                quickActionButton(icon: "questionmark.circle", title: "Help") {
                    // Help action
                }
            }
        }
    }
    
    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(StoreKitManager())
    }
} 