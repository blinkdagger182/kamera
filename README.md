# Swift Boilerplate for iOS Apps

A production-ready Swift boilerplate to kickstart your iOS app development with essential features already integrated.

## 🚀 Features

- **SwiftUI**: Modern UI framework with MVVM architecture
- **Apple Authentication**: Integrated Sign in with Apple
- **In-App Purchases**: Support for subscriptions and one-time purchases
- **Supabase Backend**: Authentication, database, and real-time syncing
- **Swift Package Manager**: Dependency management
- **Organized Project Structure**: Clean architecture for easy scaling

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- macOS Ventura+ (for development)

## 🛠️ Installation

### Option 1: Clone the Repository

```bash
git clone https://github.com/yourusername/SwiftBoilerplate.git
cd SwiftBoilerplate
./Scripts/setup.sh
```

### Option 2: Use as Xcode Template

1. Copy the template to Xcode's template directory:

```bash
cp -R SwiftBoilerplate ~/Library/Developer/Xcode/Templates/
```

2. Create a new project in Xcode and select "SwiftBoilerplate" template

## ⚙️ Configuration

### Supabase Setup

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Get your API URL and public API key
4. Update the values in `Configs/SupabaseConfig.swift`

```swift
struct SupabaseConfig {
    static let apiURL = "YOUR_SUPABASE_URL"
    static let apiKey = "YOUR_SUPABASE_API_KEY"
}
```

### Apple Sign In Setup

1. Enable "Sign in with Apple" capability in your Xcode project
2. Configure your Apple Developer account with the appropriate identifiers
3. Update your `Info.plist` with the required entries

### In-App Purchase Setup

1. Configure products in App Store Connect
2. Update the product IDs in `Services/StoreKitService.swift`

## 📂 Project Structure

```
SwiftBoilerplate/
│── App.swift                 # Main app entry point
│── Views/                    # All SwiftUI views
│   ├── Authentication/       # Login, registration screens
│   ├── Main/                 # Main app screens
│   ├── Settings/             # Settings screens
│   └── Components/           # Reusable UI components
│── ViewModels/               # Business logic (MVVM)
│── Services/                 # API calls, IAP, authentication
│   ├── SupabaseService.swift # Supabase integration
│   ├── AuthService.swift     # Authentication handling
│   └── StoreKitService.swift # In-app purchase management
│── Models/                   # Data models
│── Extensions/               # Utility functions
│── Resources/                # Images, Colors, Fonts
│── Configs/                  # Environment variables, API keys
```

## 🧪 Testing

Run the tests using Xcode's test navigator or via command line:

```bash
xcodebuild test -scheme SwiftBoilerplate -destination 'platform=iOS Simulator,name=iPhone 14'
```

## 📱 Example App

The boilerplate includes a simple example app that demonstrates:

- User authentication flow
- Subscription management
- Data synchronization with Supabase

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
"# kamera" 
