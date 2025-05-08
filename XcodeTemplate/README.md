# Swift Boilerplate Xcode Template

This Xcode template provides a solid foundation to quickly start an iOS project with SwiftUI, including authentication, subscription management, and other common features.

## Installation

To install this template, follow these steps:

1. Clone this repository or download it
2. Open a terminal and navigate to the template folder
3. Run the following command to copy the template to the Xcode templates folder:

```bash
mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates/iOS
cp -R "Swift Boilerplate.xctemplate" ~/Library/Developer/Xcode/Templates/Project\ Templates/iOS/
```

Alternatively, you can run the included installation script:

```bash
./install.sh
```

## Usage

Once installed, you can use this template to create a new project:

1. Open Xcode
2. Select "File" > "New" > "Project..."
3. Scroll down to the "iOS" section and select "Swift Boilerplate"
4. Follow the instructions to configure your new project

## Included Features

- MVVM Architecture
- Authentication (email/password, social networks)
- Subscription and in-app purchase management
- Customizable theme with dark mode support
- Common screens (login, registration, settings, etc.)
- Supabase integration for backend
- Push notification management
- Biometric authentication support

## Customization

After creating your project, you can customize:

- Colors in `Resources/Assets.xcassets/Colors`
- App icon in `Resources/Assets.xcassets/AppIcon.appiconset`
- App logo in `Resources/Assets.xcassets/AppLogo.imageset`
- API connection information in `Config/APIConfig.swift`

## Requirements

- Xcode 14.0+
- iOS 15.0+
- Swift 5.7+

## License

This template is available under the MIT License. See the LICENSE file for more details.
