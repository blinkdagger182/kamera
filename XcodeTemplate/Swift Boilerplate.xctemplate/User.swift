//
//  User.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let hasActiveSubscription: Bool
    let purchasedProducts: [String]
    
    var fullName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let lastName = lastName {
            return lastName
        } else {
            return "User"
        }
    }
    
    var initials: String {
        let firstInitial = firstName?.prefix(1) ?? ""
        let lastInitial = lastName?.prefix(1) ?? ""
        
        if firstInitial.isEmpty && lastInitial.isEmpty {
            return "U"
        } else {
            return "\(firstInitial)\(lastInitial)"
        }
    }
} 