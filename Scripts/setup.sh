#!/bin/bash

echo "🚀 Setting up the iOS boilerplate..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

# Create necessary directories if they don't exist
mkdir -p SwiftBoilerplate/Resources
mkdir -p SwiftBoilerplate/Tests
mkdir -p SwiftBoilerplate/UITests

# Clean the project
echo "🧹 Cleaning project..."
if [ -d "SwiftBoilerplate.xcodeproj" ]; then
    xcodebuild clean -project SwiftBoilerplate.xcodeproj
fi

# Update Swift packages
echo "📦 Updating Swift packages..."
if [ -f "Package.swift" ]; then
    swift package update
fi

# Set up git if not already initialized
if [ ! -d ".git" ]; then
    echo "🔄 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit from SwiftBoilerplate setup"
fi

# Set executable permissions for this script
chmod +x Scripts/setup.sh

echo "✅ Done! Open SwiftBoilerplate.xcodeproj and start building!"
echo "📝 Remember to configure your Supabase credentials in Configs/SupabaseConfig.swift"
echo "🔑 Don't forget to set up Sign in with Apple in your Apple Developer account"
echo "💰 Configure your in-app purchases in App Store Connect and update the product IDs" 