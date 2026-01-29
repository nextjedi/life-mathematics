# Flutter Setup Instructions

This guide will help you set up your development environment for the Life Mathematics Flutter app.

## Prerequisites

### 1. Install Flutter SDK

#### Windows
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to desired location (e.g., C:\src\flutter)
# Add Flutter to PATH
```

#### macOS
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/macos
# Extract to desired location
cd ~/development
unzip ~/Downloads/flutter_macos_*.zip
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Linux
```bash
# Download Flutter SDK
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_*.tar.xz
tar xf flutter_linux_*.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

This command checks your environment and displays a report. Install any missing dependencies.

### 3. Install Platform-Specific Requirements

#### Android Development
- Install [Android Studio](https://developer.android.com/studio)
- Install Android SDK (via Android Studio)
- Accept Android licenses:
  ```bash
  flutter doctor --android-licenses
  ```

#### iOS Development (macOS only)
- Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835)
- Install Xcode command-line tools:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```
- Install CocoaPods:
  ```bash
  sudo gem install cocoapods
  ```

#### Web Development
- Chrome browser (installed by default)

### 4. Install an IDE

Choose one:

**VS Code** (Recommended)
- Download from [code.visualstudio.com](https://code.visualstudio.com/)
- Install Flutter extension
- Install Dart extension

**Android Studio**
- Install Flutter plugin
- Install Dart plugin

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/life-mathematics.git
cd life-mathematics
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on Chrome (web)
flutter run -d chrome

# Run on Android emulator
flutter run -d android

# Run on iOS simulator (macOS only)
flutter run -d ios
```

## Creating a New Flutter Project (From Scratch)

If you want to create a similar project from scratch:

```bash
# Create new Flutter project
flutter create --org com.lifemathematics life_mathematics

# Navigate to project directory
cd life_mathematics

# Run the app
flutter run
```

### Project Structure

```
life_mathematics/
├── android/           # Android-specific code
├── ios/              # iOS-specific code
├── lib/              # Main Dart code
│   ├── main.dart     # App entry point
│   ├── models/       # Data models
│   ├── screens/      # UI screens
│   ├── widgets/      # Reusable widgets
│   ├── utils/        # Helper functions
│   └── constants/    # Constants and themes
├── test/             # Unit and widget tests
├── web/              # Web-specific code
├── pubspec.yaml      # Dependencies and metadata
└── README.md         # Project documentation
```

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run the app in release mode
flutter run --release

# Build APK for Android
flutter build apk

# Build iOS app (macOS only)
flutter build ios

# Build web app
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build files
flutter clean

# Upgrade Flutter SDK
flutter upgrade
```

## Troubleshooting

### Flutter Doctor Issues

Run `flutter doctor -v` for detailed diagnostics.

### Android License Issues

```bash
flutter doctor --android-licenses
```

### iOS CocoaPods Issues

```bash
cd ios
pod install
cd ..
```

### Cache Issues

```bash
flutter clean
flutter pub get
```

## Development Tips

1. **Hot Reload**: Press `r` in the terminal while the app is running to hot reload
2. **Hot Restart**: Press `R` to hot restart
3. **DevTools**: Press `p` to toggle performance overlay
4. **Inspector**: Use Flutter DevTools for debugging (`flutter pub global activate devtools`)

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Pub.dev](https://pub.dev/) - Flutter packages

## Need Help?

- Check existing [GitHub Issues](https://github.com/yourusername/life-mathematics/issues)
- Create a new issue with the `question` label
- Join Flutter community on [Discord](https://discord.gg/flutter)

Happy coding! 🚀
