//
//  StoreKitManager.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import StoreKit

class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        // Load products when initialized
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        error = nil
        
        // TODO: Replace with your actual product IDs
        let productIDs = [
            "com.yourcompany.yourapp.premium.monthly",
            "com.yourcompany.yourapp.premium.yearly",
            "com.yourcompany.yourapp.consumable.coins100"
        ]
        
        do {
            // Request products from App Store
            let storeProducts = try await Product.products(for: productIDs)
            self.products = storeProducts
            isLoading = false
        } catch {
            self.error = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async {
        isLoading = true
        error = nil
        
        do {
            // Purchase the product
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Handle successful purchase
                switch verification {
                case .verified(let transaction):
                    // Add the product ID to the list of purchased products
                    purchasedProductIDs.insert(product.id)
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                case .unverified(_, let error):
                    self.error = "Transaction verification failed: \(error.localizedDescription)"
                }
            case .userCancelled:
                // User cancelled the purchase
                break
            case .pending:
                // Purchase is pending (e.g., awaiting parental approval)
                break
            @unknown default:
                self.error = "Unknown purchase result"
            }
        } catch {
            self.error = "Purchase failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        do {
            // Get all past purchases
            var purchasedProducts = Set<String>()
            
            // Check for past purchases
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // Add the product ID to the set of purchased products
                    purchasedProducts.insert(transaction.productID)
                }
            }
            
            // Update the published property
            self.purchasedProductIDs = purchasedProducts
        } catch {
            self.error = "Failed to update purchased products: \(error.localizedDescription)"
        }
    }
} 