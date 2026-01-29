# Quick Start Guide

## ✅ Problem Fixed!

The build error has been resolved. The issue was:
- **Error**: `CardTheme` type mismatch
- **Fix**: Changed to `CardThemeData` in `lib/app/theme.dart`

## 🚀 Running the App

### Your Available Devices

Based on your system, you have these devices available:

1. **Android Emulator** (recommended for testing)
   - Device ID: `emulator-5554`
   - Android 16 (API 36)

2. **Windows Desktop**
   - Device ID: `windows`
   - For desktop testing

3. **Chrome Browser**
   - Device ID: `chrome`
   - For web testing

4. **Edge Browser**
   - Device ID: `edge`
   - For web testing

### Run Commands

```bash
# Run on Android Emulator (recommended)
flutter run -d emulator-5554

# Run on Windows Desktop
flutter run -d windows

# Run on Chrome (Web)
flutter run -d chrome

# Run on Edge (Web)
flutter run -d edge

# Run on first available device
flutter run
```

### Step-by-Step to Run

1. **Make sure your Android emulator is running**
   - You already have one running (emulator-5554)

2. **Navigate to project directory**
   ```bash
   cd D:\Projects\Life-mathematics
   ```

3. **Install dependencies** (first time only)
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run -d emulator-5554
   ```

5. **Wait for build to complete**
   - First build takes 2-5 minutes
   - Subsequent builds are much faster

## 🎮 App Controls (While Running)

Once the app is running, you can use these commands in the terminal:

- **r** - Hot reload (apply code changes instantly)
- **R** - Hot restart (restart the app)
- **h** - Show help
- **p** - Toggle performance overlay
- **q** - Quit and stop the app

## 🔧 If Build Fails

### Error: "No devices found"
```bash
# Check available devices
flutter devices

# Start an Android emulator
flutter emulators
flutter emulators --launch <emulator_id>
```

### Error: Gradle build failed
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### Error: Dependencies issue
```bash
# Repair pub cache
flutter pub cache repair
flutter pub get
```

## 📱 Features to Test

Once the app launches, test these features:

### Basic Calculator
- ✅ Numbers 0-9
- ✅ Operations: +, −, ×, ÷
- ✅ Decimal point
- ✅ Clear (C) and Clear Entry (CE)
- ✅ Backspace (⌫)
- ✅ Sign toggle (±)
- ✅ Equals (=)

### UI Features
- ✅ Theme toggle (light/dark mode icon in top-right)
- ✅ Responsive layout
- ✅ Smooth animations
- ✅ Haptic feedback (on physical devices)

### Test Calculations
Try these to test functionality:

1. **Basic**: `5 + 3 = 8`
2. **Decimal**: `5.5 × 2 = 11`
3. **Chain**: `5 + 3 × 2 = 16` (tests operator precedence)
4. **Division**: `15 ÷ 3 = 5`
5. **Error**: `5 ÷ 0 = Error`
6. **Sign**: `5 ± = -5`

## 🎨 Theme Testing

1. Tap the moon/sun icon in the top-right
2. App should switch between light and dark mode
3. Close and reopen app - theme should persist

## 📊 Build Times

- **First build**: 2-5 minutes (downloads dependencies)
- **Subsequent builds**: 30-60 seconds
- **Hot reload**: Instant (< 1 second)

## 🐛 Common Issues

### Issue: "Gradle build failed"
**Solution**: Wait for first build to complete. First builds take longer.

### Issue: "Could not find tools.jar"
**Solution**: Make sure Java JDK is installed (not just JRE).

### Issue: "Android license not accepted"
**Solution**:
```bash
flutter doctor --android-licenses
```
Press 'y' and Enter for all prompts.

### Issue: App crashes on launch
**Solution**:
```bash
# Clean rebuild
flutter clean
flutter pub get
flutter run -d emulator-5554
```

## 📝 Development Workflow

### Making Changes

1. **Edit code** in your IDE (VS Code, Android Studio, etc.)
2. **Save the file**
3. **Press 'r'** in terminal for hot reload
4. Changes appear instantly!

### Example: Change button color

1. Open `lib/app/theme.dart`
2. Change a color value
3. Save file
4. Press 'r' in terminal
5. See changes immediately!

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/calculator_logic_test.dart
```

## 📦 Building Release Version

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Windows Desktop
```bash
flutter build windows --release
```

### Web
```bash
flutter build web --release
```

## 🚀 Next Steps

1. **Test the current calculator**
2. **Try changing the theme**
3. **Experiment with hot reload**
4. **Look at the code structure**
5. **Check out ISSUES.md for next features to implement**

## 💡 Tips

- **Use hot reload** ('r') for UI changes - it's instant!
- **Use hot restart** ('R') if state gets messed up
- **Keep emulator running** between builds for faster development
- **Use Flutter DevTools** for debugging:
  ```bash
  flutter pub global activate devtools
  flutter pub global run devtools
  ```

## 📚 Learn More

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev/guides
- **Material Design**: https://m3.material.io/

## ✅ Success Checklist

- [x] Fixed CardTheme error
- [x] Flutter dependencies installed
- [ ] App running on emulator
- [ ] Tested basic calculations
- [ ] Tested theme switching
- [ ] Made first code change with hot reload

---

**Happy Coding! 🎉**

If you encounter any issues, check `TROUBLESHOOTING.md` for detailed solutions.
