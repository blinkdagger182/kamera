import SwiftUI

struct AppColors {
    // Main colors
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let accent = Color("AccentColor")
    
    // Background colors
    static let background = Color("BackgroundColor")
    static let secondaryBackground = Color("SecondaryBackgroundColor")
    
    // Text colors
    static let text = Color("TextColor")
    static let secondaryText = Color("SecondaryTextColor")
    
    // Status colors
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    static let info = Color.blue
}

// MARK: - Color Extension

extension Color {
    static let appPrimary = AppColors.primary
    static let appSecondary = AppColors.secondary
    static let appAccent = AppColors.accent
    static let appBackground = AppColors.background
    static let appSecondaryBackground = AppColors.secondaryBackground
    static let appText = AppColors.text
    static let appSecondaryText = AppColors.secondaryText
    
    // Status colors
    static let appSuccess = AppColors.success
    static let appWarning = AppColors.warning
    static let appError = AppColors.error
    static let appInfo = AppColors.info
} 