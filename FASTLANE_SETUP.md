# Fastlane Setup Guide — Life Mathematics

## Overview

This document describes how to set up Fastlane for automated builds and store distribution across all platforms:
- **Android**: Google Play Store (internal testing, production)
- **iOS**: TestFlight beta distribution and App Store releases
- **macOS**: TestFlight beta distribution and App Store releases

## Architecture

Fastlane is configured **per-platform** with separate directories:

```
android/fastlane/
├── Appfile       # Package name and JSON key path
└── Fastfile      # Build and upload lanes

ios/fastlane/
├── Appfile       # App identifier, team ID, Apple ID
└── Fastfile      # Build and upload lanes

macos/fastlane/
├── Appfile       # App identifier, team ID, Apple ID
└── Fastfile      # Build and upload lanes

Gemfile           # Ruby dependencies (project root)
```

---

## Android Setup

### Prerequisites

- Google Play Console account
- App registered (package: `com.nextjedi.lifemathematics`)
- Upload keystore file: `android/app/upload-keystore.jks`
- Key properties configured in `android/key.properties`
- Google Play API JSON key (for automated uploads)

### Authentication

**Option A — Service Account (recommended for CI/CD):**

1. Go to Google Play Console → Setup → API access
2. Create a service account or use existing
3. Grant permissions: Release to production, Release to testing tracks
4. Download JSON key file
5. Store securely and reference in Fastfile

```bash
export GOOGLE_PLAY_JSON_KEY_PATH="/path/to/google-play-api-key.json"
```

**Option B — Manual upload:**
- Use `bundle exec fastlane supply init` to download existing metadata
- Upload manually through Play Console

### Signing Configuration

The app is configured to use release signing via `android/key.properties`:

```properties
storePassword=LifeMath2026Secure!
keyPassword=LifeMath2026Secure!
keyAlias=lifemathematics
storeFile=upload-keystore.jks
```

**Security Note:** Keep `key.properties` and `upload-keystore.jks` secure. Add to `.gitignore` in production environments.

### Setup Steps

#### 1. Create android/fastlane/Appfile

```ruby
json_key_file(ENV["GOOGLE_PLAY_JSON_KEY_PATH"] || "/path/to/google-play-api-key.json")
package_name("com.nextjedi.lifemathematics")
```

#### 2. Create android/fastlane/Fastfile

```ruby
default_platform(:android)

PROJECT_ROOT = File.expand_path("../..", __dir__)

platform :android do

  desc "Build and upload to Play Store Internal Testing"
  lane :internal do
    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "appbundle", "--release")
    end

    upload_to_play_store(
      track: 'internal',
      aab: File.join(PROJECT_ROOT, "build", "app", "outputs", "bundle", "release", "app-release.aab"),
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )

    UI.success("Uploaded to Play Store Internal Testing!")
  end

  desc "Build and upload to Play Store Production"
  lane :production do
    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "appbundle", "--release")
    end

    upload_to_play_store(
      track: 'production',
      aab: File.join(PROJECT_ROOT, "build", "app", "outputs", "bundle", "release", "app-release.aab"),
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )

    UI.success("Uploaded to Play Store Production!")
  end

  desc "Build and upload to Play Store Beta"
  lane :beta do
    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "appbundle", "--release")
    end

    upload_to_play_store(
      track: 'beta',
      aab: File.join(PROJECT_ROOT, "build", "app", "outputs", "bundle", "release", "app-release.aab"),
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )

    UI.success("Uploaded to Play Store Beta!")
  end
end
```

### Android Asset Requirements

#### App Icon
- **Location**: `assets/icon/app_icon.png`
- **Size**: 1024x1024 px
- **Configuration**: Managed by `flutter_launcher_icons` package
- **Generation**: Run `flutter pub run flutter_launcher_icons` to update all platforms

#### Play Store Assets

**Screenshots** (see `PLAY_STORE_SCREENSHOTS.md` for details):
- Minimum: 2 screenshots required
- Recommended: 1080 x 1920 pixels (9:16 ratio)
- Format: PNG or JPEG (max 8MB each)
- Example: `screenshot_light_initial.png` (14.7MB - needs optimization)

**Feature Graphic**:
- **Location**: `assets/play_store/feature_graphic_generator.html`
- **Size**: 1024 x 500 pixels
- **Usage**: Open HTML file in browser, customize, download
- **Required**: Yes, for Play Store listing

**Other Assets** (optional but recommended):
- High-res icon: 512 x 512 px
- Promo graphic: 180 x 120 px
- TV banner: 1280 x 720 px (if supporting Android TV)

---

## iOS/macOS Setup

### Prerequisites

- Apple Developer account with Team ID `DLQ4JM3YPQ`
- App registered in App Store Connect (bundle ID: `com.nextjedi.lifemathematics`)
- Xcode installed with command line tools
- Ruby (system or Homebrew)

### Authentication (pick one)

**Option A — Apple ID (simpler for local dev):**
```bash
export APPLE_ID="your@email.com"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
# Generate app-specific password at https://appleid.apple.com/account/manage
```

**Option B — App Store Connect API Key (better for CI, no 2FA):**
```bash
export ASC_KEY_ID="XXXXXXXXXX"
export ASC_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ASC_KEY_PATH="/path/to/AuthKey_XXXXXXXXXX.p8"
# Generate at https://appstoreconnect.apple.com/access/integrations/api
```

## Setup Steps

### 1. Create Gemfile (project root)

```ruby
source "https://rubygems.org"

gem "fastlane", "~> 2.225"
gem "cocoapods", "~> 1.16"
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Create ios/fastlane/Appfile

```ruby
app_identifier("com.nextjedi.lifemathematics")
apple_id(ENV["APPLE_ID"] || "your-apple-id@example.com")
team_id("DLQ4JM3YPQ")
itc_team_id(ENV["ITC_TEAM_ID"])
```

### 4. Create ios/fastlane/Fastfile

```ruby
default_platform(:ios)

PROJECT_ROOT = File.expand_path("../..", __dir__)
IOS_DIR = File.expand_path("..", __dir__)
EXPORT_OPTIONS_PLIST = File.join(IOS_DIR, "ExportOptions.plist")
WORKSPACE = File.join(IOS_DIR, "Runner.xcworkspace")
ARCHIVE_PATH = File.join(PROJECT_ROOT, "build", "ios", "Runner.xcarchive")
EXPORT_DIR = File.join(PROJECT_ROOT, "build", "ios", "ipa")

platform :ios do

  desc "Build and upload to TestFlight"
  lane :beta do
    api_key = app_store_connect_api_key(
      key_id: ENV["ASC_KEY_ID"],
      issuer_id: ENV["ASC_ISSUER_ID"],
      key_filepath: ENV["ASC_KEY_PATH"],
      optional: true
    )

    build_number = latest_testflight_build_number(
      api_key: api_key,
      app_identifier: "com.nextjedi.lifemathematics",
      initial_build_number: 0
    ) + 1

    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "ios", "--release", "--no-codesign", "--build-number=#{build_number}")
    end

    # Archive without signing (workaround for missing distribution cert)
    sh(
      "xcodebuild", "-workspace", WORKSPACE, "-scheme", "Runner",
      "-configuration", "Release", "-archivePath", ARCHIVE_PATH, "archive",
      "CODE_SIGNING_REQUIRED=NO", "CODE_SIGNING_ALLOWED=NO"
    )

    # Export with signing via App Store Connect
    sh(
      "xcodebuild", "-exportArchive",
      "-archivePath", ARCHIVE_PATH,
      "-exportOptionsPlist", EXPORT_OPTIONS_PLIST,
      "-exportPath", EXPORT_DIR,
      "-allowProvisioningUpdates"
    )

    ipa_path = Dir.glob(File.join(EXPORT_DIR, "*.ipa")).first
    UI.user_error!("No IPA found in #{EXPORT_DIR}") unless ipa_path

    upload_to_testflight(
      api_key: api_key,
      ipa: ipa_path,
      skip_waiting_for_build_processing: true,
      skip_submission: true
    )

    UI.success("Uploaded iOS build #{build_number} to TestFlight!")
  end

  desc "Build and upload to App Store"
  lane :release do
    api_key = app_store_connect_api_key(
      key_id: ENV["ASC_KEY_ID"],
      issuer_id: ENV["ASC_ISSUER_ID"],
      key_filepath: ENV["ASC_KEY_PATH"],
      optional: true
    )

    build_number = latest_testflight_build_number(
      api_key: api_key,
      app_identifier: "com.nextjedi.lifemathematics",
      initial_build_number: 0
    ) + 1

    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "ios", "--release", "--no-codesign", "--build-number=#{build_number}")
    end

    sh(
      "xcodebuild", "-workspace", WORKSPACE, "-scheme", "Runner",
      "-configuration", "Release", "-archivePath", ARCHIVE_PATH, "archive",
      "CODE_SIGNING_REQUIRED=NO", "CODE_SIGNING_ALLOWED=NO"
    )

    sh(
      "xcodebuild", "-exportArchive",
      "-archivePath", ARCHIVE_PATH,
      "-exportOptionsPlist", EXPORT_OPTIONS_PLIST,
      "-exportPath", EXPORT_DIR,
      "-allowProvisioningUpdates"
    )

    ipa_path = Dir.glob(File.join(EXPORT_DIR, "*.ipa")).first
    UI.user_error!("No IPA found in #{EXPORT_DIR}") unless ipa_path

    deliver(
      api_key: api_key,
      ipa: ipa_path,
      skip_metadata: true,
      skip_screenshots: true,
      submit_for_review: false,
      force: true
    )

    UI.success("Uploaded iOS build #{build_number} to App Store Connect!")
  end
end
```

### 5. Create macos/ExportOptions.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>DLQ4JM3YPQ</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

### 6. Create macos/fastlane/Appfile

```ruby
app_identifier("com.nextjedi.lifemathematics")
apple_id(ENV["APPLE_ID"] || "your-apple-id@example.com")
team_id("DLQ4JM3YPQ")
itc_team_id(ENV["ITC_TEAM_ID"])
```

### 7. Create macos/fastlane/Fastfile

```ruby
default_platform(:mac)

PROJECT_ROOT = File.expand_path("../..", __dir__)
MACOS_DIR = File.expand_path("..", __dir__)
WORKSPACE = File.join(MACOS_DIR, "Runner.xcworkspace")
ARCHIVE_PATH = File.join(PROJECT_ROOT, "build", "macos", "Runner.xcarchive")
EXPORT_DIR = File.join(PROJECT_ROOT, "build", "macos", "pkg")

platform :mac do

  desc "Build and upload to TestFlight"
  lane :beta do
    api_key = app_store_connect_api_key(
      key_id: ENV["ASC_KEY_ID"],
      issuer_id: ENV["ASC_ISSUER_ID"],
      key_filepath: ENV["ASC_KEY_PATH"],
      optional: true
    )

    build_number = latest_testflight_build_number(
      api_key: api_key,
      app_identifier: "com.nextjedi.lifemathematics",
      platform: "osx",
      initial_build_number: 0
    ) + 1

    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "macos", "--release", "--build-number=#{build_number}")
    end

    # Archive with signing overrides (macOS project has CODE_SIGN_IDENTITY="-" by default)
    sh(
      "xcodebuild", "-workspace", WORKSPACE, "-scheme", "Runner",
      "-configuration", "Release", "-archivePath", ARCHIVE_PATH, "archive",
      "DEVELOPMENT_TEAM=DLQ4JM3YPQ",
      "CODE_SIGN_IDENTITY=Apple Distribution",
      "CODE_SIGN_STYLE=Automatic"
    )

    export_options_path = File.join(MACOS_DIR, "ExportOptions.plist")
    UI.user_error!("Missing #{export_options_path}") unless File.exist?(export_options_path)

    sh(
      "xcodebuild", "-exportArchive",
      "-archivePath", ARCHIVE_PATH,
      "-exportOptionsPlist", export_options_path,
      "-exportPath", EXPORT_DIR,
      "-allowProvisioningUpdates"
    )

    pkg_path = Dir.glob(File.join(EXPORT_DIR, "*.pkg")).first
    UI.user_error!("No .pkg found in #{EXPORT_DIR}") unless pkg_path

    upload_to_testflight(
      api_key: api_key,
      pkg: pkg_path,
      skip_waiting_for_build_processing: true,
      skip_submission: true,
      platform: "osx"
    )

    UI.success("Uploaded macOS build #{build_number} to TestFlight!")
  end

  desc "Build and upload to App Store"
  lane :release do
    api_key = app_store_connect_api_key(
      key_id: ENV["ASC_KEY_ID"],
      issuer_id: ENV["ASC_ISSUER_ID"],
      key_filepath: ENV["ASC_KEY_PATH"],
      optional: true
    )

    build_number = latest_testflight_build_number(
      api_key: api_key,
      app_identifier: "com.nextjedi.lifemathematics",
      platform: "osx",
      initial_build_number: 0
    ) + 1

    Dir.chdir(PROJECT_ROOT) do
      sh("flutter", "clean")
      sh("flutter", "pub", "get")
      sh("flutter", "build", "macos", "--release", "--build-number=#{build_number}")
    end

    sh(
      "xcodebuild", "-workspace", WORKSPACE, "-scheme", "Runner",
      "-configuration", "Release", "-archivePath", ARCHIVE_PATH, "archive",
      "DEVELOPMENT_TEAM=DLQ4JM3YPQ",
      "CODE_SIGN_IDENTITY=Apple Distribution",
      "CODE_SIGN_STYLE=Automatic"
    )

    export_options_path = File.join(MACOS_DIR, "ExportOptions.plist")
    UI.user_error!("Missing #{export_options_path}") unless File.exist?(export_options_path)

    sh(
      "xcodebuild", "-exportArchive",
      "-archivePath", ARCHIVE_PATH,
      "-exportOptionsPlist", export_options_path,
      "-exportPath", EXPORT_DIR,
      "-allowProvisioningUpdates"
    )

    pkg_path = Dir.glob(File.join(EXPORT_DIR, "*.pkg")).first
    UI.user_error!("No .pkg found in #{EXPORT_DIR}") unless pkg_path

    deliver(
      api_key: api_key,
      pkg: pkg_path,
      skip_metadata: true,
      skip_screenshots: true,
      submit_for_review: false,
      force: true,
      platform: "osx"
    )

    UI.success("Uploaded macOS build #{build_number} to App Store Connect!")
  end
end
```

### 8. Update .gitignore

Add to `.gitignore`:

```
# Fastlane
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots
**/fastlane/test_output
**/fastlane/README.md

# Bundler
vendor/bundle
.bundle

# Android signing (IMPORTANT: Protect in production!)
# For development/solo projects these may be committed
# For production/team projects, use CI/CD secrets instead
android/key.properties
android/app/*.jks
android/app/*.keystore

# Google Play API keys
google-play-api-key.json
**/google-play-*.json

# Apple certificates and profiles (if stored locally)
*.p12
*.mobileprovision
*.provisionprofile
*.certSigningRequest

# App Store Connect API keys
AuthKey_*.p8
```

## Azure Pipelines Setup

The pipeline file is `azure-pipelines.yml` at the project root. Step templates live in `.azure/templates/`.

### Flow

```
PR to main     →  Test only (flutter analyze + flutter test)
Merge to main  →  Test → Beta   (Android Internal + iOS/macOS TestFlight) [parallel]
Push v* tag    →  Test → Production (Play Store + App Store) [parallel]
```

### One-time Azure DevOps configuration

#### 1. Create a Pipeline

1. Go to Azure DevOps → Pipelines → New Pipeline
2. Connect your GitHub/Azure repo
3. Select "Existing Azure Pipelines YAML file"
4. Choose `/azure-pipelines.yml`

#### 2. Upload Secure Files

Go to **Pipelines → Library → Secure files** and upload:

| File to upload | Name it exactly |
|---|---|
| `android/app/upload-keystore.jks` | `upload-keystore.jks` |
| Google Play Service Account JSON | `google-play-api-key.json` |
| App Store Connect API key (.p8) | `asc-api-key.p8` |

#### 3. Set Pipeline Variables

Go to **Pipelines → [your pipeline] → Edit → Variables** and add:

| Variable | Value | Secret? |
|---|---|---|
| `KEYSTORE_PASSWORD` | `LifeMath2026Secure!` | ✅ Yes |
| `KEY_PASSWORD` | `LifeMath2026Secure!` | ✅ Yes |
| `KEY_ALIAS` | `lifemathematics` | No |
| `ASC_KEY_ID` | Your ASC key ID | No |
| `ASC_ISSUER_ID` | Your ASC issuer ID | No |

> The ASC key file is handled via Secure Files above. No need to paste the key content into a variable.

#### 4. Commit Gemfile.lock

Run locally once, then commit the lock file so CI uses exact gem versions:

```bash
bundle install
git add Gemfile Gemfile.lock
git commit -m "chore: Add Gemfile.lock for reproducible CI builds"
```

---

## Usage

```bash
# Install dependencies (one time)
bundle install

# ==================== ANDROID ====================
# Play Store Internal Testing
cd android && bundle exec fastlane internal

# Play Store Beta Track
cd android && bundle exec fastlane beta

# Play Store Production
cd android && bundle exec fastlane production

# ==================== iOS ====================
# iOS TestFlight
cd ios && bundle exec fastlane beta

# iOS App Store
cd ios && bundle exec fastlane release

# ==================== macOS ====================
# macOS TestFlight
cd macos && bundle exec fastlane beta

# macOS App Store
cd macos && bundle exec fastlane release
```

## Release Workflows & Git Strategy

### Branch Structure

**Main Branch: `main`**
- Protected branch (should be configured with branch protection)
- Always production-ready
- All releases are tagged from this branch
- Requires pull request reviews before merge

**Feature Branches: `feature/*`**
- For new features (e.g., `feature/compound-interest-calculator`)
- Created from `main`
- Merged back to `main` via PR

**Hotfix Branches: `hotfix/*`**
- For urgent production fixes (e.g., `hotfix/crash-on-division-by-zero`)
- Created from `main`
- Merged back to `main` via PR
- Can be fast-tracked if critical

**Release Branches: `release/*`** (optional, for large releases)
- For stabilizing before major releases (e.g., `release/1.0.0`)
- Created from `main` when feature-complete
- Only bug fixes allowed
- Merged to `main` when stable

### Git Workflow Rules

1. **Never commit directly to `main`** - always use PRs
2. **Branch naming convention**:
   - Features: `feature/descriptive-name`
   - Hotfixes: `hotfix/issue-description`
   - Releases: `release/version-number`
3. **Commit message format**: Follow conventional commits
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation
   - `chore:` for maintenance
   - `refactor:` for code refactoring
4. **PR requirements**:
   - Descriptive title and description
   - All CI checks pass (if configured)
   - Code review approval
   - No merge conflicts

### Recommended Branch Protection (GitHub/GitLab)

Configure `main` branch with:
- ✅ Require pull request reviews (minimum 1 approval for solo dev)
- ✅ Require status checks to pass (if CI/CD configured)
- ✅ Require branches to be up to date before merging
- ✅ Include administrators (enforce rules for everyone)
- ✅ Restrict who can push to matching branches
- ❌ Do not allow force pushes
- ❌ Do not allow deletions

### Release Workflow by Platform

#### Android - Internal Testing
```
feature/new-feature → main (merge) → cd android && fastlane internal
```
- Build number auto-increments
- Version from pubspec.yaml (e.g., `0.1.1+2`)
- Available to internal testers immediately
- Use for quick testing before beta/production

#### Android - Beta/Production Release
```
main (stable) → bump version in pubspec.yaml → git tag → cd android && fastlane beta/production
```
1. Update version: `version: 1.0.0+1` → `version: 1.0.1+2` in `pubspec.yaml`
2. Commit: `git commit -m "chore: Bump version to 1.0.1+2"`
3. Tag: `git tag v1.0.1 && git push origin v1.0.1`
4. Run: `cd android && bundle exec fastlane beta` or `fastlane production`

#### iOS/macOS - TestFlight (Beta)
```
feature/new-feature → main (merge) → cd ios && fastlane beta
```
- Build number auto-increments from latest TestFlight build
- Version stays same (from pubspec.yaml)
- Available to TestFlight testers after processing
- Use for beta testing before App Store submission

#### iOS/macOS - App Store (Production)
```
main (stable) → bump version in pubspec.yaml → git tag → cd ios && fastlane release
```
1. Update version: `version: 1.0.0+1` → `version: 1.0.1+2` in `pubspec.yaml`
2. Commit: `git commit -m "chore: Bump version to 1.0.1+2"`
3. Tag: `git tag v1.0.1 && git push origin v1.0.1`
4. Run: `cd ios && bundle exec fastlane release` (or `cd macos && ...`)
5. Submit for review in App Store Connect

### Common Workflows

#### 1. Small Bug Fix (Hotfix)
```bash
# From main branch
git checkout -b hotfix/fix-division-crash

# Make fixes and test
git add .
git commit -m "fix: Prevent crash on division by zero"

# Push and create PR
git push origin hotfix/fix-division-crash

# After PR approval and merge to main
git checkout main
git pull

# Bump patch version (1.0.0+1 → 1.0.1+2)
# Edit pubspec.yaml: version: 1.0.1+2
git commit -am "chore: Bump version to 1.0.1+2 for hotfix"
git tag v1.0.1
git push origin main --tags

# Deploy to Android internal for quick test
cd android && bundle exec fastlane internal

# If verified, deploy to production
cd android && bundle exec fastlane production
cd ../ios && bundle exec fastlane release
cd ../macos && bundle exec fastlane release
```

#### 2. New Feature Development
```bash
# From main branch
git checkout -b feature/loan-calculator

# Develop feature with multiple commits
git add .
git commit -m "feat: Add loan calculator UI"
git commit -m "feat: Add loan calculation logic"
git commit -m "test: Add loan calculator tests"

# Push and create PR
git push origin feature/loan-calculator

# After PR approval and merge to main
git checkout main
git pull

# Test with beta before production (optional)
cd android && bundle exec fastlane internal
cd ../ios && bundle exec fastlane beta

# When ready for release, bump minor version (1.0.0 → 1.1.0)
# Edit pubspec.yaml: version: 1.1.0+3
git commit -am "chore: Bump version to 1.1.0 for loan calculator release"
git tag v1.1.0
git push origin main --tags

# Deploy to production
cd android && bundle exec fastlane production
cd ../ios && bundle exec fastlane release
cd ../macos && bundle exec fastlane release
```

#### 3. Multi-Platform Release (All Platforms)
```bash
# After version bump and tagging on main
git checkout main
git pull

# Verify version in pubspec.yaml
cat pubspec.yaml | grep version

# Deploy to all platforms
# Option A: Sequential (safer, can catch issues early)
cd android && bundle exec fastlane production
cd ../ios && bundle exec fastlane release
cd ../macos && bundle exec fastlane release

# Option B: Parallel (faster, for experienced use)
# Open 3 terminal windows and run simultaneously:
# Terminal 1: cd android && bundle exec fastlane production
# Terminal 2: cd ios && bundle exec fastlane release
# Terminal 3: cd macos && bundle exec fastlane release
```

### Version Numbering Strategy

Follow Semantic Versioning (SemVer):
- **Format**: `MAJOR.MINOR.PATCH+BUILD`
- **Example**: `1.2.3+45`
  - `1` = Major version (breaking changes)
  - `2` = Minor version (new features, backward compatible)
  - `3` = Patch version (bug fixes)
  - `45` = Build number (auto-incremented by Fastlane for iOS/macOS)

**When to bump:**
- **Major** (1.0.0 → 2.0.0): Complete redesign, major feature overhaul
- **Minor** (1.0.0 → 1.1.0): New calculator type, significant new feature
- **Patch** (1.0.0 → 1.0.1): Bug fixes, small improvements
- **Build** (+1 → +2): Auto-incremented by Fastlane, or manual for Android

### Tagging Convention

Always tag releases:
```bash
git tag v1.0.1
git push origin v1.0.1

# View all tags
git tag -l

# Delete tag if needed (be careful!)
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1
```

## Asset Management

### App Icons

**Source Icon**: `assets/icon/app_icon.png` (1024x1024 px)

Generated for all platforms using `flutter_launcher_icons` package:
```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  remove_alpha_ios: true
```

**Update icons:**
```bash
flutter pub run flutter_launcher_icons
```

This generates:
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- macOS: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

### Play Store Assets

**Location**: `assets/play_store/`

**Feature Graphic** (1024x500 px):
- Tool: `feature_graphic_generator.html`
- Open in browser, customize, download
- Upload to Play Console: Main store listing → Feature Graphic

**Screenshots** (see `PLAY_STORE_SCREENSHOTS.md`):
- Minimum: 2 required (phone)
- Size: 1080x1920 px (9:16 ratio)
- Capture: `adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png`
- Current: `screenshot_light_initial.png` (needs optimization - 14.7MB → ~2MB)

**Optimize screenshots:**
```bash
# Using ImageMagick
convert screenshot_light_initial.png -quality 85 -resize 1080x1920 screenshot_optimized.png

# Or use online tools: tinypng.com, compressor.io
```

### App Store Assets (iOS/macOS)

**App Preview/Screenshots**:
- iOS: 6.5" display (1284x2778 px) and 5.5" display (1242x2208 px)
- macOS: 1280x800 px minimum
- Upload via App Store Connect or `deliver` (Fastlane)

**App Icon**:
- Auto-generated from `assets/icon/app_icon.png`
- Validated during Xcode build

### Asset Checklist Before Release

- [ ] App icon generated and looks correct on all platforms
- [ ] Android: Feature graphic created (1024x500 px)
- [ ] Android: 2+ screenshots captured and optimized
- [ ] iOS: Screenshots for all required device sizes
- [ ] macOS: Screenshots for macOS size requirements
- [ ] All assets under 8MB file size limit
- [ ] No alpha channels in iOS icons (handled automatically)

## Design Notes

### Android
- **Release signing** configured via `android/key.properties`
- **Upload keystore** (`upload-keystore.jks`) used for Play Store uploads
- **AAB format** (Android App Bundle) required for Play Store
- **Build number** taken from `pubspec.yaml` version (e.g., `0.1.1+2` → build 2)
- **Language restriction**: Set to English only (`resourceConfigurations.addAll(listOf("en"))`)

### iOS
- **Archives without signing** then exports with `-allowProvisioningUpdates` — workaround for missing Apple Distribution certificate
- **Build numbers** auto-increment from latest TestFlight build
- **ExportOptions.plist** configures signing method (`app-store-connect`, automatic)
- **Team ID**: `DLQ4JM3YPQ`

### macOS
- **Overrides `CODE_SIGN_IDENTITY` and `DEVELOPMENT_TEAM`** at build time since Xcode project defaults to ad-hoc signing
- **Build numbers** auto-increment from latest TestFlight build
- **`platform: "osx"`** required in all TestFlight/App Store Fastlane actions
- **PKG format** for distribution

---

## Quick Reference

### Daily Development Commands

```bash
# Check git status and current branch
git status
git branch

# Create feature branch
git checkout -b feature/my-feature

# Run app locally
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/ test/
```

### Pre-Release Checklist

- [ ] All tests passing (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] Code formatted (`flutter format .`)
- [ ] Version bumped in `pubspec.yaml`
- [ ] Changelog/release notes prepared
- [ ] Assets optimized (screenshots < 8MB)
- [ ] Git branch up to date with main
- [ ] All changes committed and pushed
- [ ] PR reviewed and approved (if using PR workflow)
- [ ] Merged to main branch

### Release Commands (Copy-Paste)

**Android Internal Test:**
```bash
cd android && bundle exec fastlane internal && cd ..
```

**Android Beta:**
```bash
cd android && bundle exec fastlane beta && cd ..
```

**Android Production:**
```bash
cd android && bundle exec fastlane production && cd ..
```

**iOS TestFlight:**
```bash
cd ios && bundle exec fastlane beta && cd ..
```

**iOS App Store:**
```bash
cd ios && bundle exec fastlane release && cd ..
```

**macOS TestFlight:**
```bash
cd macos && bundle exec fastlane beta && cd ..
```

**macOS App Store:**
```bash
cd macos && bundle exec fastlane release && cd ..
```

**All Platforms (Sequential):**
```bash
cd android && bundle exec fastlane production && cd .. && \
cd ios && bundle exec fastlane release && cd .. && \
cd macos && bundle exec fastlane release && cd ..
```

### Version Bump Commands

```bash
# View current version
grep version pubspec.yaml

# Edit version (manually)
# Change: version: 1.0.0+1 → version: 1.0.1+2
nano pubspec.yaml

# Commit version bump
git add pubspec.yaml
git commit -m "chore: Bump version to 1.0.1+2"

# Create and push tag
git tag v1.0.1
git push origin main --tags
```

### Troubleshooting

**Build fails with signing errors:**
- iOS: Check Team ID in `ios/fastlane/Appfile`
- Android: Verify `android/key.properties` exists and keystore path is correct
- macOS: Ensure signing overrides in Fastfile are correct

**Fastlane can't find Ruby gems:**
```bash
bundle install
bundle update fastlane
```

**Android build fails:**
```bash
cd android && ./gradlew clean && cd ..
flutter clean
flutter pub get
```

**iOS/macOS build fails:**
```bash
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
# or for macOS
cd macos && rm -rf Pods Podfile.lock && pod install && cd ..
```

**Upload keystore not found:**
- Ensure `android/app/upload-keystore.jks` exists
- Check `storeFile` path in `android/key.properties`

**TestFlight build not appearing:**
- Check App Store Connect → TestFlight tab
- Processing can take 5-30 minutes
- Look for email from Apple about build status

**Play Store upload rejected:**
- Ensure version code is higher than previous build
- Check Play Console for specific error messages
- Verify signing configuration is correct

### Environment Variables Reference

**Android:**
- `GOOGLE_PLAY_JSON_KEY_PATH`: Path to Google Play API JSON key

**iOS/macOS:**
- `APPLE_ID`: Your Apple ID email
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`: App-specific password
- `ASC_KEY_ID`: App Store Connect API Key ID
- `ASC_ISSUER_ID`: App Store Connect API Issuer ID
- `ASC_KEY_PATH`: Path to App Store Connect API key (.p8 file)
- `ITC_TEAM_ID`: App Store Connect Team ID (if multiple teams)

**Set environment variables:**
```bash
# Temporary (current session)
export APPLE_ID="your@email.com"

# Permanent (add to ~/.bashrc, ~/.zshrc, or ~/.bash_profile)
echo 'export APPLE_ID="your@email.com"' >> ~/.zshrc
```

### Useful Links

- **Google Play Console**: https://play.google.com/console
- **App Store Connect**: https://appstoreconnect.apple.com
- **Fastlane Documentation**: https://docs.fastlane.tools
- **Flutter Deployment Docs**: https://docs.flutter.dev/deployment
- **Semantic Versioning**: https://semver.org
- **Conventional Commits**: https://www.conventionalcommits.org

### Support

For issues or questions:
1. Check this documentation first
2. Review Fastlane logs for error messages
3. Consult official Fastlane docs: https://docs.fastlane.tools
4. Check Flutter deployment guide: https://docs.flutter.dev/deployment

---

**Last Updated**: 2026-02-27
**Current Version**: 0.1.1+2
**Platforms**: Android, iOS, macOS
