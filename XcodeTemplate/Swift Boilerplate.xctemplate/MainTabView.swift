//
//  MainTabView.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            NavigationView {
                Text("Home Screen")
                    .navigationTitle("Home")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            // Explore tab
            NavigationView {
                Text("Explore Screen")
                    .navigationTitle("Explore")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }
            .tag(1)
            
            // Profile tab
            NavigationView {
                Text("Profile Screen")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(2)
            
            // Settings tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(StoreKitManager())
    }
} 