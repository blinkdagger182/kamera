//
//  SettingsView.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var biometricAuthEnabled = true
    @State private var dataUsageOption = 0
    
    private let dataUsageOptions = ["Wi-Fi Only", "Wi-Fi & Cellular", "Always Ask"]
    
    var body: some View {
        List {
            // Account section
            Section(header: Text("ACCOUNT")) {
                if let user = authViewModel.currentUser {
                    // User profile
                    HStack(spacing: 12) {
                        // Profile image
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Text(user.initials)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        // User info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullName)
                                .font(.headline)
                            
                            if let email = user.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Edit profile button
                        NavigationLink(destination: Text("Edit Profile")) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Subscription status
                    NavigationLink(destination: Text("Subscription")) {
                        HStack {
                            Image(systemName: "creditcard")
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                            
                            Text("Subscription")
                            
                            Spacer()
                            
                            Text(user.hasActiveSubscription ? "Premium" : "Free")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Purchases
                    NavigationLink(destination: Text("Purchases")) {
                        HStack {
                            Image(systemName: "bag")
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                            
                            Text("Purchases")
                            
                            Spacer()
                            
                            Text("\(user.purchasedProducts.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Preferences section
            Section(header: Text("PREFERENCES")) {
                // Notifications
                Toggle(isOn: $notificationsEnabled) {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Notifications")
                    }
                }
                
                // Dark mode
                Toggle(isOn: $darkModeEnabled) {
                    HStack {
                        Image(systemName: "moon")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Dark Mode")
                    }
                }
                
                // Biometric authentication
                Toggle(isOn: $biometricAuthEnabled) {
                    HStack {
                        Image(systemName: "faceid")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Biometric Authentication")
                    }
                }
                
                // Data usage
                Picker(selection: $dataUsageOption, label: 
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Data Usage")
                    }
                ) {
                    ForEach(0..<dataUsageOptions.count, id: \.self) { index in
                        Text(dataUsageOptions[index]).tag(index)
                    }
                }
            }
            
            // Support section
            Section(header: Text("SUPPORT")) {
                // Help center
                NavigationLink(destination: Text("Help Center")) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Help Center")
                    }
                }
                
                // Contact us
                NavigationLink(destination: Text("Contact Us")) {
                    HStack {
                        Image(systemName: "envelope")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Contact Us")
                    }
                }
                
                // Privacy policy
                NavigationLink(destination: Text("Privacy Policy")) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Privacy Policy")
                    }
                }
                
                // Terms of service
                NavigationLink(destination: Text("Terms of Service")) {
                    HStack {
                        Image(systemName: "doc.text")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Terms of Service")
                    }
                }
            }
            
            // App info section
            Section(header: Text("APP INFO")) {
                // App version
                HStack {
                    Image(systemName: "info.circle")
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                    
                    Text("App Version")
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                // Restore purchases
                Button(action: {
                    Task {
                        await storeKitManager.updatePurchasedProducts()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        
                        Text("Restore Purchases")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // Account actions section
            Section {
                // Sign out button
                Button(action: {
                    showSignOutAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                        
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
                
                // Delete account button
                Button(action: {
                    showDeleteAccountAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                        
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .alert(isPresented: $showSignOutAlert) {
            Alert(
                title: Text("Sign Out"),
                message: Text("Are you sure you want to sign out?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    authViewModel.signOut()
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showDeleteAccountAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Handle account deletion
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AuthViewModel())
                .environmentObject(StoreKitManager())
        }
    }
} 