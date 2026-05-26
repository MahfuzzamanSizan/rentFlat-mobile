#!/bin/bash
# RentEase Flutter Mobile App - Setup Script
# Run this after installing Flutter

set -e
echo "================================================"
echo "  RentEase Mobile App Setup"
echo "================================================"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo ""
    echo "Flutter not found. Install it first:"
    echo "  brew install --cask flutter"
    echo "  OR"
    echo "  Download from: https://docs.flutter.dev/get-started/install/macos"
    echo ""
    exit 1
fi

echo ""
echo "Flutter found: $(flutter --version | head -1)"
echo ""

# Check Xcode for iOS
if ! command -v xcode-select &> /dev/null; then
    echo "Xcode required for iOS. Install from App Store."
    exit 1
fi

echo "Step 1: Creating Flutter project scaffold..."
cd "$(dirname "$0")"

# Create a temp flutter project to get platform files, then overlay our code
TEMP_DIR=$(mktemp -d)
flutter create --platforms=ios,android --org=com.rentease --project-name=rentflat_mobile "$TEMP_DIR/scaffold"

# Copy platform directories
echo "Step 2: Copying iOS and Android platform files..."
cp -r "$TEMP_DIR/scaffold/ios" .
cp -r "$TEMP_DIR/scaffold/android" .
cp -r "$TEMP_DIR/scaffold/test" .
cp "$TEMP_DIR/scaffold/.gitignore" .

# Cleanup temp
rm -rf "$TEMP_DIR"

echo "Step 3: Installing dependencies..."
flutter pub get

echo "Step 4: Running Flutter doctor..."
flutter doctor

echo ""
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo ""
echo "To run on iOS Simulator:"
echo "  flutter run -d ios"
echo ""
echo "To run on a connected iPhone:"
echo "  flutter run -d 'iPhone name'"
echo ""
echo "To build iOS IPA:"
echo "  flutter build ios --release"
echo ""
echo "IMPORTANT: Update the API base URL in:"
echo "  lib/core/constants/api_constants.dart"
echo "  -> Change baseUrl to your backend IP/domain"
echo ""
