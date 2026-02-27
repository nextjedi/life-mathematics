# Fastlane Setup Guide — Life Mathematics

## Overview

This document describes how to set up Fastlane for automated iOS and macOS builds, TestFlight beta distribution, and App Store releases.

## Architecture

Fastlane is configured **per-platform** with separate directories:

```
ios/fastlane/
├── Appfile       # App identifier, team ID, Apple ID
└── Fastfile      # Build and upload lanes

macos/fastlane/
├── Appfile       # App identifier, team ID, Apple ID
└── Fastfile      # Build and upload lanes

Gemfile           # Ruby dependencies (project root)
```

## Prerequisites

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
```

## Usage

```bash
# Install dependencies (one time)
bundle install

# iOS TestFlight
cd ios && bundle exec fastlane beta

# iOS App Store
cd ios && bundle exec fastlane release

# macOS TestFlight
cd macos && bundle exec fastlane beta

# macOS App Store
cd macos && bundle exec fastlane release
```

## Release Workflows

### Test Release (TestFlight)
```
feature-branch → main (merge) → fastlane beta → TestFlight
```
Build number auto-increments. Version stays the same.

### Production Release (App Store)
```
main (stable) → bump version in pubspec.yaml → fastlane release → App Store Review
```
Tag the commit: `git tag v1.0.0 && git push origin v1.0.0`

### Small Bug Fix (Hotfix)
```
main → hotfix/fix-bug → main → bump patch (1.0.0 → 1.0.1) → fastlane beta → verify → fastlane release
```

### Large Feature Launch
```
main → feature/new-calc → multiple beta builds → merge to main → bump minor/major → fastlane release
```

## Design Notes

- **iOS archives without signing** then exports with `-allowProvisioningUpdates` — workaround for missing Apple Distribution certificate
- **macOS overrides `CODE_SIGN_IDENTITY` and `DEVELOPMENT_TEAM`** at build time since the Xcode project defaults to ad-hoc signing
- **Build numbers** are auto-incremented from the latest TestFlight build, no manual bumping needed
- **`platform: "osx"`** is required in all macOS TestFlight/App Store actions
