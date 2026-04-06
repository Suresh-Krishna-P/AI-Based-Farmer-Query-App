# AI-Based Farmer Query App - Setup Guide

## Prerequisites

### 1. Install Flutter Development Environment

**Option A: Download Flutter SDK**
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Extract to your desired location (e.g., C:\flutter or ~/flutter)
```

**Option B: Using Package Manager**
```bash
# Windows (using Chocolatey)
choco install flutter

# macOS (using Homebrew)
brew install --cask flutter

# Linux
sudo snap install flutter --classic
```

### 2. Set Up Environment Variables

**Windows:**
```cmd
# Add to System Environment Variables
Path: C:\flutter\bin
```

**macOS/Linux:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/flutter/bin"
```

### 3. Verify Flutter Installation
```bash
flutter doctor
```

This will check if all dependencies are installed. Follow any recommendations to fix issues.

### 4. Install Required Dependencies

```bash
# Install Android Studio (for Android development)
# Download from: https://developer.android.com/studio

# Install Xcode (for iOS development - macOS only)
# Download from: App Store or https://developer.apple.com/xcode/

# Install VS Code (recommended editor)
# Download from: https://code.visualstudio.com/
```

## Project Setup

### 1. Clone or Download Project
```bash
# If using git
git clone <your-repo-url>
cd AI-Based-Farmer-Query-App

# Or extract the downloaded project files
```

### 2. Install Dependencies
```bash
# Navigate to project directory
cd AI-Based-Farmer-Query-App

# Install Flutter packages
flutter pub get
```

### 3. Configure API Keys (Optional)

The app is designed to work with free APIs, but you can optionally add API keys for enhanced functionality:

**Create a `.env` file in the project root:**
```env
# Optional API Keys (not required for basic functionality)
OPENAI_API_KEY=your_openai_key_here
GOOGLE_VISION_API_KEY=your_google_vision_key_here
WEATHER_API_KEY=your_weather_api_key_here
PLANTNET_API_KEY=your_plantnet_key_here
```

**Note:** The app will work without these keys using fallback mechanisms.

### 4. Set Up Android/iOS Development

**For Android:**
```bash
# Connect Android device or start Android emulator
flutter devices

# Enable USB debugging on Android device if using physical device
```

**For iOS (macOS only):**
```bash
# Open iOS simulator
open -a Simulator

# Or connect iOS device via USB
```

## Running the App

### 1. Run on Connected Device/Emulator
```bash
# Run the app
flutter run
```

### 2. Run on Specific Platform
```bash
# Android only
flutter run -d android

# iOS only (macOS)
flutter run -d ios

# Web (if enabled)
flutter run -d chrome
```

### 3. Build for Production
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (requires Xcode setup)
flutter build ios

# Web
flutter build web
```

## Testing the App

### 1. Basic Functionality Test
Once the app is running, test these features:

1. **Language Detection**: Type queries in Tamil and English
2. **Text Search**: Try queries like "rice disease treatment" or "அரிசி நோய் தடுப்பு"
3. **Image Search**: Use the camera or gallery to test image recognition
4. **Voice Search**: Test voice input functionality
5. **Context-Aware Features**: Set location and crop preferences

### 2. Run Automated Tests
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test --tags=widget

# Run integration tests (if any)
flutter drive --target=test_driver/integration_test.dart
```

### 3. Performance Testing
```bash
# Run performance profiling
flutter run --profile

# Run with verbose logging
flutter run --verbose
```

## Troubleshooting

### Common Issues:

**1. Flutter Doctor Shows Issues:**
```bash
# Fix Android license issues
flutter doctor --android-licenses

# Fix Xcode issues (iOS)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**2. Missing Dependencies:**
```bash
# Reinstall dependencies
flutter pub cache repair

# Clean and rebuild
flutter clean
flutter pub get
```

**3. Build Failures:**
```bash
# Check Flutter version compatibility
flutter --version

# Update Flutter
flutter upgrade
```

**4. API Connection Issues:**
- The app uses free APIs that may have rate limits
- Check internet connection
- Try again after a few minutes if rate limited

### Debug Mode Features:
The app includes a built-in testing framework. To access it:

1. Open the app
2. Look for a "Test" or "Debug" option in the settings
3. Run the comprehensive system tests
4. View performance reports and system health

## Development Tips

### Hot Reload:
- Make changes to Dart code
- Save the file (Ctrl+S/Cmd+S)
- Changes appear instantly on device/emulator

### Debugging:
```bash
# Enable debug mode
flutter run --debug

# View logs
flutter logs

# Use Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Code Analysis:
```bash
# Check code quality
flutter analyze

# Format code
flutter format lib/
```

## Next Steps

1. **Customize the App**: Modify colors, text, and features in the code
2. **Add API Keys**: For enhanced functionality, add your API keys to .env
3. **Test on Real Devices**: Test with actual farmers in Tamil Nadu
4. **Deploy**: Build and deploy to Google Play Store or Apple App Store

## Support

If you encounter issues:

1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Review the project's README.md
3. Check Flutter community forums
4. Create issues on the project repository

## Performance Notes

- The app is optimized for low-end devices common in rural areas
- Offline functionality is available for areas with poor connectivity
- Image processing may be slower on older devices
- Text-based queries work best in areas with limited internet

Happy coding! 🚀