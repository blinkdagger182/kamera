//
//  AuthView.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isSignIn = true
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 50)
                    
                    // Title
                    Text(isSignIn ? "Sign In" : "Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Form fields
                    VStack(spacing: 20) {
                        if !isSignIn {
                            // First name field (sign up only)
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            // Last name field (sign up only)
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Email field
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        // Password field
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Error message
                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Sign in/up button
                    Button(action: {
                        if isSignIn {
                            authViewModel.signIn(email: email, password: password)
                        } else {
                            authViewModel.signUp(firstName: firstName, lastName: lastName, email: email, password: password)
                        }
                    }) {
                        Text(isSignIn ? "Sign In" : "Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(authViewModel.isLoading)
                    
                    // Toggle between sign in and sign up
                    Button(action: {
                        isSignIn.toggle()
                    }) {
                        Text(isSignIn ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                            .foregroundColor(.blue)
                    }
                    
                    // Forgot password (sign in only)
                    if isSignIn {
                        Button(action: {
                            // Handle forgot password
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if authViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
} 