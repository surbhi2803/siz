#!/bin/bash

# 🍎 iOS Setup Script for Siz App
# Run this script on macOS to set up iOS development

echo "🍎 Setting up Siz for iOS development..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from App Store."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Install iOS dependencies
echo "🍎 Installing iOS dependencies..."
cd ios
pod install
cd ..

echo "✅ iOS dependencies installed"

# Check if GoogleService-Info.plist exists
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  GoogleService-Info.plist not found!"
    echo "📋 Please follow these steps:"
    echo "1. Go to Firebase Console"
    echo "2. Add iOS app with bundle ID: com.siz.siz"
    echo "3. Download GoogleService-Info.plist"
    echo "4. Place it in ios/Runner/GoogleService-Info.plist"
    echo ""
    echo "📄 Template file created at: ios/Runner/GoogleService-Info.plist.template"
fi

# Check if app icons are set up
echo "🎨 Checking app icons..."
if [ -f "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" ]; then
    echo "✅ App icons are set up"
else
    echo "⚠️  App icons need to be updated with your cat logo"
    echo "📋 Please replace the default icons in:"
    echo "   ios/Runner/Assets.xcassets/AppIcon.appiconset/"
fi

echo ""
echo "🎉 iOS setup complete!"
echo ""
echo "📱 To run on your iPhone:"
echo "1. Connect your iPhone via USB"
echo "2. Trust the computer on your phone"
echo "3. Run: flutter run -d ios"
echo ""
echo "🚀 To build for release:"
echo "flutter build ios --release"
echo ""
echo "📱 Your Siz app is ready for iOS! 🍎"
