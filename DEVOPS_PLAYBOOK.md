# Flutter CI/CD Playbook
### Azure Pipelines + Fastlane — Multi-App Operations Manual

> Built from real production experience shipping Life Mathematics (Android, iOS, macOS).
> Use this as a copy-paste reference for every new Flutter app.

---

## Table of Contents
1. [System Architecture](#1-system-architecture)
2. [One-Time Account Setup](#2-one-time-account-setup)
3. [Per-App Launch Checklist](#3-per-app-launch-checklist)
4. [Pipeline File Reference](#4-pipeline-file-reference)
5. [Secure Files Reference](#5-secure-files-reference)
6. [Pipeline Variables Reference](#6-pipeline-variables-reference)
7. [Release Triggers](#7-release-triggers)
8. [Scaling to 60 Apps](#8-scaling-to-60-apps)
9. [Feedback & Release Management](#9-feedback--release-management)
10. [Common Errors & Fixes](#10-common-errors--fixes)
11. [Maintenance Calendar](#11-maintenance-calendar)

---

## 1. System Architecture

```
GitHub Push/Tag
      │
      ▼
┌─────────────────────────────────────┐
│         Azure Pipelines             │
│                                     │
│  Stage 1: Test (every push + PR)    │
│  ├── flutter analyze                │
│  └── flutter test                   │
│                                     │
│  Stage 2: Beta (main branch only)   │  ← push to main
│  ├── Android → Play Store Internal  │
│  ├── iOS     → TestFlight           │
│  └── macOS   → TestFlight           │
│                                     │
│  Stage 3: Production (v* tags only) │  ← git tag v1.0.0
│  ├── Android → Play Store (prod)    │
│  ├── iOS     → App Store            │
│  └── macOS   → Mac App Store        │
└─────────────────────────────────────┘
```

**Tools:**
- **Azure Pipelines** — CI/CD runner (free macOS minutes for open source)
- **Fastlane** — App Store + Play Store automation
- **GitHub** — Source control + webhook trigger

---

## 2. One-Time Account Setup

> Do this once. All 60 apps share these.

### 2.1 Azure DevOps
```bash
# Install CLI extension
az extension add --name azure-devops

# Create PAT at: https://dev.azure.com/YOUR_ORG/_usersSettings/tokens
# Scopes: Full access, 1 year expiry — store in password manager
export AZURE_DEVOPS_EXT_PAT=your_pat_here

az devops configure --defaults \
  organization="https://dev.azure.com/YOUR_ORG" \
  project="YOUR_PROJECT"
```

### 2.2 Apple Certificates (shared across all iOS/macOS apps)
These certificates belong to your developer account, not individual apps.

| Certificate | Used For | Expires |
|---|---|---|
| Apple Distribution | iOS app signing | 1 year |
| Mac Installer Distribution | macOS .pkg signing | 1 year |

**Create once, reuse for all apps:**
1. Keychain Access → Certificate Assistant → Request CSR → Save to disk
2. developer.apple.com → Certificates → + → Apple Distribution → upload CSR
3. Download .cer → double-click to install
4. Keychain → My Certificates → right-click → Export → .p12 with password
5. Repeat for Mac Installer Distribution

**Store the .p12 files + passwords in your password manager. Back them up.**

### 2.3 App Store Connect API Key (shared across all apps)
One key works for all your apps.
1. App Store Connect → Users and Access → Integrations → App Store Connect API
2. Create key → Role: **App Manager** (or Admin)
3. Download `AuthKey_XXXXXXXXXX.p8` — **can only download once**
4. Note the Key ID and Issuer ID

### 2.4 Google Play Service Account (shared across all apps)
One service account works for all your Play Store apps.
1. Google Play Console → Setup → API access → Link to Google Cloud project
2. Create service account → download JSON key
3. Back in Play Console → Grant access → Release manager

---

## 3. Per-App Launch Checklist

> Copy this checklist for every new app. Takes ~2 hours on first run.

### Phase 1 — Apple Setup
- [ ] Register App ID in Apple Developer portal (`com.yourorg.appname`)
- [ ] Create iOS App Store provisioning profile → download `.mobileprovision`
- [ ] Create macOS App Store provisioning profile → download `.provisionprofile`
- [ ] Create app record in App Store Connect (name, bundle ID, category)

### Phase 2 — Google Setup
- [ ] Create app in Google Play Console
- [ ] Complete store listing (minimum: title, description, icon, screenshots)
- [ ] Upload first APK/AAB **manually** (Play Store requires one manual upload before API access works)
- [ ] Generate Android keystore (do this once per app, back it up immediately)

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias YOUR_APP_ALIAS
```

### Phase 3 — Azure DevOps Setup
- [ ] Create GitHub service connection (if not already done for this org)
- [ ] Create pipeline pointing to `azure-pipelines.yml`
- [ ] Upload secure files (see Section 5)
- [ ] Authorize all secure files for the pipeline
- [ ] Set pipeline variables (see Section 6)
- [ ] Run `bundle install` locally → commit `Gemfile.lock`

### Phase 4 — Code Setup
- [ ] Copy `.azure/` templates folder from this repo
- [ ] Copy `Gemfile` from this repo
- [ ] Create `android/fastlane/Fastfile` + `Appfile`
- [ ] Create `ios/fastlane/Fastfile` + `Appfile`
- [ ] Create `macos/fastlane/Fastfile` + `Appfile` (if macOS target)
- [ ] Add `post_install` hook to `ios/Podfile` (disable Pod signing)
- [ ] Update bundle ID everywhere
- [ ] Update Team ID everywhere (`DLQ4JM3YPQ` → yours)

### Phase 5 — First Run
- [ ] Push to `main` → verify Beta stage passes
- [ ] Check TestFlight for iOS build
- [ ] Check Play Store Internal Testing for Android build
- [ ] Tag `v0.1.0` → verify Production stage passes

---

## 4. Pipeline File Reference

### `azure-pipelines.yml` (root)
```yaml
trigger:
  branches:
    include: [main]
  tags:
    include: ['v*']
pr:
  branches:
    include: [main]

stages:
- stage: Test
  jobs:
  - job: Flutter_Test
    pool: {vmImage: 'ubuntu-latest'}
    steps:
    - template: .azure/templates/flutter-install-steps.yml
    - script: flutter analyze
    - script: flutter test

- stage: Beta
  dependsOn: Test
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: Android_Internal
    pool: {vmImage: 'ubuntu-latest'}
    steps:
    - template: .azure/templates/flutter-install-steps.yml
    - template: .azure/templates/android-signing-steps.yml
    - template: .azure/templates/fastlane-install-steps.yml
    - task: DownloadSecureFile@1
      name: googlePlayKey
      inputs: {secureFile: 'google-play-api-key.json'}
    - script: bundle exec fastlane internal
      workingDirectory: android
      env: {GOOGLE_PLAY_JSON_KEY_PATH: $(googlePlayKey.secureFilePath)}

  - job: iOS_Beta
    pool: {vmImage: 'macos-latest'}
    steps:
    - template: .azure/templates/flutter-install-steps.yml
    - template: .azure/templates/apple-signing-steps.yml
      parameters: {provisioningProfile: 'ios-distribution.mobileprovision'}
    - template: .azure/templates/fastlane-install-steps.yml
    - script: bundle exec fastlane beta
      workingDirectory: ios
      env:
        ASC_KEY_ID: $(ASC_KEY_ID)
        ASC_ISSUER_ID: $(ASC_ISSUER_ID)
        ASC_KEY_PATH: $(ascKey.secureFilePath)

- stage: Production
  dependsOn: Test
  condition: and(succeeded(), startsWith(variables['Build.SourceBranch'], 'refs/tags/v'))
  # ... same structure as Beta but with 'production' and 'release' lanes
```

### `.azure/templates/flutter-install-steps.yml`
```yaml
steps:
- task: Cache@2
  inputs:
    key: '"flutter-stable" | "$(Agent.OS)"'
    path: $(Pipeline.Workspace)/flutter
    cacheHitVar: FLUTTER_CACHE_HIT

- script: git clone https://github.com/flutter/flutter.git --depth 1 -b stable $(Pipeline.Workspace)/flutter
  condition: ne(variables.FLUTTER_CACHE_HIT, 'true')

- script: echo "##vso[task.prependpath]$(Pipeline.Workspace)/flutter/bin"

- script: flutter --version && flutter config --no-analytics

- task: Cache@2
  inputs:
    key: '"pub" | "$(Agent.OS)" | pubspec.lock'
    path: $(Pipeline.Workspace)/.pub-cache
    cacheHitVar: PUB_CACHE_HIT

- script: flutter pub get
  env: {PUB_CACHE: $(Pipeline.Workspace)/.pub-cache}
```

### `.azure/templates/fastlane-install-steps.yml`
```yaml
steps:
- task: Cache@2
  inputs:
    key: '"gems" | "$(Agent.OS)" | Gemfile.lock'
    path: $(System.DefaultWorkingDirectory)/vendor/bundle
    cacheHitVar: GEMS_CACHE_HIT

- script: |
    sudo gem install bundler --no-document
    bundle config set --local path vendor/bundle
    bundle install --jobs 4 --retry 3
  condition: ne(variables.GEMS_CACHE_HIT, 'true')

- script: |
    sudo gem install bundler --no-document
    bundle config set --local path vendor/bundle
  condition: eq(variables.GEMS_CACHE_HIT, 'true')
```

### `.azure/templates/apple-signing-steps.yml`
```yaml
parameters:
- name: provisioningProfile
  type: string

steps:
- task: DownloadSecureFile@1
  name: ascKey
  inputs: {secureFile: 'AuthKey_XXXXXXXXXX.p8'}

- task: InstallAppleCertificate@2
  inputs:
    certSecureFile: 'distribution.p12'
    certPwd: '$(P12_PASSWORD)'
    keychain: 'temp'

- task: InstallAppleCertificate@2           # macOS only
  inputs:
    certSecureFile: 'mac-installer-distribution.p12'
    certPwd: '$(MAC_INSTALLER_P12_PASSWORD)'
    keychain: 'temp'
  condition: eq(variables['Agent.OS'], 'Darwin')

- task: InstallAppleProvisioningProfile@1
  inputs:
    provisioningProfileLocation: 'secureFiles'
    provProfileSecureFile: '${{ parameters.provisioningProfile }}'
```

### `ios/Podfile` — critical post_install hook
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'  # ← must have this
    end
  end
end
```

---

## 5. Secure Files Reference

Upload at: **Pipelines → Library → Secure files**
After upload, authorize each file for the pipeline via REST API or UI.

| File | Scope | Notes |
|---|---|---|
| `upload-keystore.jks` | Per app | Back up immediately. If lost, can't update app on Play Store |
| `google-play-api-key.json` | Shared (all apps) | One service account for all |
| `AuthKey_XXXXXXXXXX.p8` | Shared (all apps) | Download once — Apple won't show it again |
| `distribution.p12` | Shared (all apps) | Re-export when cert renews (yearly) |
| `mac-installer-distribution.p12` | Shared (all apps) | Re-export when cert renews (yearly) |
| `ios-distribution.mobileprovision` | Per app | Renew yearly, tied to bundle ID |
| `macos-distribution.provisionprofile` | Per app | Renew yearly, tied to bundle ID |

**Authorize a secure file for a pipeline:**
```bash
curl -X PATCH \
  -H "Authorization: Basic $(echo -n ':YOUR_PAT' | base64)" \
  -H "Content-Type: application/json" \
  -d '{"pipelines":[{"id": PIPELINE_ID, "authorized": true}]}' \
  "https://dev.azure.com/ORG/PROJECT/_apis/pipelines/pipelinePermissions/securefile/SECURE_FILE_ID?api-version=7.1-preview.1"
```

---

## 6. Pipeline Variables Reference

| Variable | Secret | Scope | Description |
|---|---|---|---|
| `KEYSTORE_PASSWORD` | ✅ | Per app | Android keystore password |
| `KEY_PASSWORD` | ✅ | Per app | Android key password (often same as above) |
| `KEY_ALIAS` | ❌ | Per app | Android key alias |
| `ASC_KEY_ID` | ❌ | Shared | App Store Connect key ID (10 chars) |
| `ASC_ISSUER_ID` | ❌ | Shared | App Store Connect issuer UUID |
| `P12_PASSWORD` | ✅ | Shared | Apple Distribution .p12 export password |
| `MAC_INSTALLER_P12_PASSWORD` | ✅ | Shared | Mac Installer .p12 export password |

---

## 7. Release Triggers

### Beta release (TestFlight + Play Store Internal)
```bash
git push origin main
```
Triggers automatically on every push to `main`.

### Production release (App Store + Play Store Production)
```bash
git tag v1.0.0
git push origin v1.0.0
```
Semantic versioning: `vMAJOR.MINOR.PATCH`

### Manual re-run
```bash
az pipelines run --id PIPELINE_ID --branch main
```

### Release naming convention for 60 apps
```
v{MAJOR}.{MINOR}.{PATCH}

Examples:
v1.0.0  → initial App Store release
v1.1.0  → new feature
v1.1.1  → bug fix
v2.0.0  → breaking redesign
```

---

## 8. Scaling to 60 Apps

### 8.1 Organization Strategy

```
dev.azure.com/YOUR_ORG/
├── Shared Library          ← shared secure files, variable groups
│   ├── Secure Files: distribution.p12, AuthKey_*.p8, google-play-api-key.json
│   └── Variable Group: "apple-shared" (ASC_KEY_ID, ASC_ISSUER_ID, P12_PASSWORD)
│
├── Project: App-01-Calculator
│   ├── Pipeline: CI/CD
│   └── Secure Files: upload-keystore.jks, ios-distribution.mobileprovision
│
├── Project: App-02-Budgeter
│   └── ...
└── ...
```

**Use Variable Groups** for shared variables instead of setting them per pipeline:
```bash
az pipelines variable-group create \
  --name "apple-shared" \
  --variables ASC_KEY_ID=KFMUN9Z5NJ ASC_ISSUER_ID=6e580434-...
```

Reference in pipeline:
```yaml
variables:
- group: apple-shared
```

### 8.2 Template Repository (critical for 60 apps)

Create a dedicated repo `flutter-cicd-templates` with:
```
flutter-cicd-templates/
├── templates/
│   ├── flutter-install-steps.yml
│   ├── fastlane-install-steps.yml
│   ├── android-signing-steps.yml
│   ├── apple-signing-steps.yml
│   └── azure-pipelines-base.yml
├── fastlane/
│   ├── ios/Fastfile.template
│   ├── android/Fastfile.template
│   └── macos/Fastfile.template
└── Gemfile
```

Reference templates from other repos:
```yaml
resources:
  repositories:
  - repository: templates
    type: github
    name: YOUR_ORG/flutter-cicd-templates
    ref: main

steps:
- template: templates/flutter-install-steps.yml@templates
```

### 8.3 New App Setup Script

Create a script `scripts/new-app-setup.sh` that automates Phase 3 of the checklist:
```bash
#!/bin/bash
APP_NAME=$1
BUNDLE_ID=$2
PIPELINE_ID=$3

# Authorize shared secure files
for SF_ID in $DIST_CERT_ID $ASC_KEY_ID $GOOGLE_PLAY_ID; do
  curl -X PATCH -H "Authorization: Basic $AUTH" \
    -d "{\"pipelines\":[{\"id\":$PIPELINE_ID,\"authorized\":true}]}" \
    "$ADO_BASE/_apis/pipelines/pipelinePermissions/securefile/$SF_ID?api-version=7.1-preview.1"
done

echo "Done. Upload $APP_NAME keystore and provisioning profiles manually."
```

### 8.4 Capacity Planning

| Resource | Limit | At 60 apps |
|---|---|---|
| Azure free macOS minutes | 1,800 min/month | ~30 min/app → fine for monthly releases |
| Azure cache storage | 10 GB/pipeline | ~800MB per pipeline → fine |
| Apple Distribution cert | 1 cert, all apps | Shared, no limit |
| ASC API calls | 3,600/hour | Fine |
| Play Store API | 200 req/hour per app | Fine |

> If releasing all 60 apps simultaneously, macOS minute quota will be hit.
> Stagger release days or upgrade to a paid Azure plan (~$40/month for unlimited minutes).

---

## 9. Feedback & Release Management

### 9.1 TestFlight Feedback Loop
- Testers submit feedback directly in the TestFlight app
- View at: App Store Connect → Your App → TestFlight → Feedback
- Set `skip_waiting_for_build_processing: true` in Fastfile for fast CI (build processes async)
- Promote to App Store: App Store Connect → Prepare for Submission

### 9.2 Play Store Feedback Loop
- Internal Testing → Alpha → Beta → Production (promote in Play Console)
- Fastlane lane per track:
  ```ruby
  lane :internal do  # CI auto-uploads here
  lane :alpha   do  # promote manually after internal validation
  lane :beta    do  # promote after alpha sign-off
  lane :production do  # triggered by v* tag
  ```

### 9.3 Crash Reporting (add to all apps)
Add Firebase Crashlytics or Sentry to every app:
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^4.0.0
  # or
  sentry_flutter: ^8.0.0
```

### 9.4 Release Notes Automation
Add to Fastfile to auto-generate changelog from git commits:
```ruby
changelog = changelog_from_git_commits(
  commits_count: 10,
  pretty: "- %s"
)
```

### 9.5 Notifications
Add Slack/email notifications on failure to Fastfile:
```ruby
error do |lane, exception|
  slack(
    message: "#{lane} failed: #{exception.message}",
    slack_url: ENV["SLACK_WEBHOOK_URL"],
    success: false
  )
end
```

---

## 10. Common Errors & Fixes

| Error | Cause | Fix |
|---|---|---|
| `bundle: command not found` | Bundler not pre-installed on agent | Add `sudo gem install bundler --no-document` before bundle commands |
| `You don't have write permissions for /var/lib/gems` | System Ruby on Ubuntu | Use `bundle config set --local path vendor/bundle` |
| `No Accounts` / `No signing certificate found` | Cert not installed on agent | Use `InstallAppleCertificate@2` task with .p12 secure file |
| `Pods-Runner does not support provisioning profiles` | Manual profile applied to all targets | Add `CODE_SIGNING_ALLOWED = 'NO'` in Podfile `post_install` for Pod targets |
| `No signing certificate "Mac Installer Distribution" found` | macOS needs 2 certs | Install both `distribution.p12` and `mac-installer-distribution.p12` |
| `Google Api Error: The caller does not have permission` | Service account not authorized in Play Console | Grant access in Play Console → Setup → API access |
| `flutter: command not found` (line after clone) | `##vso[task.prependpath]` only takes effect in next step | Split clone and PATH into separate steps |
| `Could not find option 'optional'` in Fastlane | Invalid parameter passed to action | Remove `optional: true` — not a valid param |
| Stale cache breaking build | Cache key not invalidating | Clear cache in Azure DevOps Library → Caches |
| `ITMS-90725: SDK version issue` | Built with older SDK | Update `macos-latest` agent when Xcode 26 is available (deadline: April 28, 2026) |

---

## 11. Maintenance Calendar

| When | Task |
|---|---|
| **Yearly (Feb)** | Renew Apple Distribution + Mac Installer Distribution certs, re-export .p12, re-upload to Azure |
| **Yearly (per app)** | Renew iOS + macOS provisioning profiles, re-upload to Azure |
| **Every 30 days** | Rotate Azure DevOps PAT and GitHub PAT |
| **When Flutter stable releases** | Clear Flutter cache in Azure (`Pipeline.Workspace/flutter`) to pick up new version |
| **Before April 28, 2026** | Update CI to use Xcode 26 for iOS 26 SDK requirement |
| **When Play Store API key expires** | Regenerate service account key, re-upload JSON to Azure |
| **Monthly** | Review TestFlight + Play Console crash reports |
| **Per release** | Tag `vX.X.X` in git → pipeline auto-ships to production |

---

## Quick Reference Card

```
NEW APP SETUP (2 hours)
━━━━━━━━━━━━━━━━━━━━━━
1. Register App ID (Apple) + Create app (Play Console)
2. Create provisioning profiles (iOS + macOS)
3. Generate keystore → back it up
4. Manual first upload to Play Store
5. Create Azure pipeline + upload app-specific secure files
6. Set KEYSTORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS variables
7. Copy .azure/ templates + Fastfiles → update bundle ID + Team ID
8. bundle install → commit Gemfile.lock
9. Push to main → verify Beta stage

RELEASE FLOW
━━━━━━━━━━━━
Beta:       git push origin main
Production: git tag v1.x.x && git push origin v1.x.x

SHARED ACROSS ALL APPS (set up once)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• distribution.p12 + P12_PASSWORD
• mac-installer-distribution.p12 + MAC_INSTALLER_P12_PASSWORD
• AuthKey_XXXXXXXXXX.p8 + ASC_KEY_ID + ASC_ISSUER_ID
• google-play-api-key.json

PER APP (set up each time)
━━━━━━━━━━━━━━━━━━━━━━━━━━
• upload-keystore.jks + KEYSTORE_PASSWORD + KEY_PASSWORD + KEY_ALIAS
• ios-distribution.mobileprovision
• macos-distribution.provisionprofile
```
