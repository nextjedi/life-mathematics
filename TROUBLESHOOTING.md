# Troubleshooting Guide

## Common Flutter Android Errors and Solutions

### Error: "No devices found"

**Cause**: No Android emulator or physical device is connected.

**Solutions**:

1. **Start an Android Emulator**:
   - Open Android Studio
   - Go to Tools > Device Manager (or AVD Manager)
   - Click "Play" button on an existing emulator
   - OR create a new emulator if none exist

2. **Connect a Physical Device**:
   - Enable Developer Options on your Android phone
   - Enable USB Debugging
   - Connect via USB cable
   - Accept USB debugging prompt on phone

3. **Verify devices**:
   ```bash
   flutter devices
   ```

---

### Error: "Android SDK not found" or "cmdline-tools not found"

**Cause**: Android SDK is not properly installed or configured.

**Solutions**:

1. **Install Android Studio** (if not installed):
   - Download from https://developer.android.com/studio
   - Run the installer
   - Follow the setup wizard

2. **Set Android SDK path**:
   ```bash
   # Add to your environment variables
   ANDROID_HOME=C:\Users\YourUsername\AppData\Local\Android\Sdk
   ```

3. **Accept Android licenses**:
   ```bash
   flutter doctor --android-licenses
   ```
   Type 'y' and press Enter for all prompts.

---

### Error: "Gradle build failed"

**Cause**: Build configuration issues or dependency problems.

**Solutions**:

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Update Gradle wrapper** (if needed):
   - Edit `android/gradle/wrapper/gradle-wrapper.properties`
   - Update to latest Gradle version

3. **Check Java version**:
   ```bash
   java -version
   ```
   Flutter requires Java 11 or higher.

---

### Error: "Failed to install APK"

**Cause**: Installation permission issues or conflicting app versions.

**Solutions**:

1. **Uninstall existing app**:
   ```bash
   adb uninstall com.lifemathematics.life_mathematics
   ```

2. **Reinstall**:
   ```bash
   flutter run
   ```

3. **Check device storage**: Ensure device has enough free space.

---

### Error: "SDK version mismatch"

**Cause**: Project's minimum SDK version is higher than device/emulator.

**Solution**:
Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Lower this if needed (minimum is 16)
        targetSdkVersion 33
    }
}
```

---

### Error: "Could not resolve dependencies"

**Cause**: Network issues or package conflicts.

**Solutions**:

1. **Clear Flutter cache**:
   ```bash
   flutter pub cache repair
   flutter clean
   flutter pub get
   ```

2. **Check internet connection**

3. **Update dependencies**:
   ```bash
   flutter pub upgrade
   ```

---

## Step-by-Step Setup (if starting fresh)

### 1. Install Prerequisites

```bash
# Check Flutter installation
flutter doctor

# Expected output should show:
# [✓] Flutter (version 3.x.x)
# [✓] Android toolchain
# [✓] Android Studio
```

### 2. Install Dependencies

```bash
cd D:\Projects\Life-mathematics
flutter pub get
```

### 3. Check Available Devices

```bash
flutter devices
```

**Expected output**:
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 13 (API 33)
Chrome (web)                • chrome        • web-javascript • Google Chrome 120.0
```

If you see "No devices found", you need to start an emulator or connect a device.

### 4. Run the App

```bash
# Run on first available device
flutter run

# Run on specific device
flutter run -d emulator-5554

# Run on Android specifically
flutter run -d android
```

---

## Quick Diagnostic Commands

Run these commands and share the output if you need help:

```bash
# 1. Check Flutter installation
flutter doctor -v

# 2. Check available devices
flutter devices

# 3. Check Android SDK
echo %ANDROID_HOME%

# 4. Check Java version
java -version

# 5. List connected ADB devices
adb devices
```

---

## Windows-Specific Issues

### Flutter commands not recognized

**Solution**: Add Flutter to PATH

1. Search for "Environment Variables" in Windows
2. Edit "System variables" > "Path"
3. Add: `C:\flutter\bin` (or wherever Flutter is installed)
4. Restart terminal/CMD

### ADB not found

**Solution**: Add Android SDK platform-tools to PATH

Add to PATH:
```
C:\Users\YourUsername\AppData\Local\Android\Sdk\platform-tools
```

---

## Create Android Emulator (if needed)

### Using Android Studio:

1. Open Android Studio
2. Click "More Actions" > "Virtual Device Manager"
3. Click "Create Device"
4. Select a device (e.g., Pixel 6)
5. Select a system image (e.g., Android 13 / API 33)
6. Click "Finish"
7. Click the "Play" button to start emulator

### Using Command Line:

```bash
# List available system images
flutter emulators

# Create emulator
flutter emulators --create

# Launch emulator
flutter emulators --launch <emulator_id>
```

---

## Still Having Issues?

1. **Copy the exact error message** from your terminal
2. Run `flutter doctor -v` and copy the output
3. Check if you can run other Flutter projects
4. Try running the Flutter demo:
   ```bash
   flutter create test_app
   cd test_app
   flutter run
   ```

---

## Useful Flutter Commands

```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Fix dependency issues
flutter pub cache repair

# Check for Flutter updates
flutter upgrade

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run with verbose output
flutter run -v

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (while app is running)
# Press 'R' in terminal

# Quit app (while running)
# Press 'q' in terminal
```

---

## Contact for Help

If you're still stuck:
1. Check GitHub Issues: https://github.com/flutter/flutter/issues
2. Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
3. Flutter Discord: https://discord.gg/flutter

Please share:
- The exact error message
- Output of `flutter doctor -v`
- Your operating system and version
- What you were trying to do when the error occurred
