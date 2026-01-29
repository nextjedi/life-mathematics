# GitHub Repository Setup Guide

This guide will help you create and configure a GitHub repository for the Life Mathematics project.

## Step 1: Create Repository on GitHub

1. Go to [GitHub](https://github.com) and log in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Configure your repository:
   - **Repository name**: `life-mathematics` or `Life-mathematics`
   - **Description**: "A comprehensive all-purpose calculator app built with Flutter for everyday calculations and financial planning"
   - **Visibility**: ✅ Public (for open source)
   - **Initialize repository**: ❌ Do NOT initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

## Step 2: Link Local Repository to GitHub

After creating the repository, GitHub will show you setup instructions. Use these commands:

```bash
# Add the remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/life-mathematics.git

# Verify the remote was added
git remote -v

# Push your code to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Configure Repository Settings

### Enable Issues
1. Go to your repository on GitHub
2. Click "Settings"
3. Under "Features", ensure "Issues" is checked

### Add Topics
1. Go to your repository main page
2. Click the gear icon next to "About"
3. Add topics:
   - `flutter`
   - `dart`
   - `calculator`
   - `material-design`
   - `mobile-app`
   - `financial-calculator`
   - `cross-platform`
   - `open-source`

### Set Repository Description
Add this description in the "About" section:
```
🧮 A comprehensive all-purpose calculator app built with Flutter for everyday calculations and financial planning. Supports basic arithmetic, compound interest, loans, EMI, and more. Features modern UI with dark mode.
```

### Add Website (Optional)
If you deploy the web version, add the URL here.

## Step 4: Create GitHub Issues

Use the `ISSUES.md` file to create issues for tracking development. For each issue in that file:

1. Go to the "Issues" tab
2. Click "New issue"
3. Copy the title from ISSUES.md
4. Copy the description, tasks, and acceptance criteria
5. Add appropriate labels:
   - `feature` - New features
   - `bug` - Bug fixes
   - `documentation` - Documentation updates
   - `enhancement` - Improvements to existing features
   - `testing` - Testing related
   - `ui` - User interface
   - `calculator` - Calculator related
   - `financial` - Financial calculators
   - `core` - Core functionality
   - `setup` - Project setup
   - `priority: high` - High priority
   - `priority: medium` - Medium priority
   - `priority: low` - Low priority
   - `good first issue` - Good for newcomers
   - `help wanted` - Help wanted

### Quick Label Setup

Create these labels in Settings > Labels:

| Label | Color | Description |
|-------|-------|-------------|
| feature | #0E8A16 | New feature or request |
| bug | #D73A4A | Something isn't working |
| documentation | #0075CA | Documentation improvements |
| enhancement | #A2EEEF | Improvement to existing feature |
| testing | #D4C5F9 | Testing related |
| ui | #F9D0C4 | User interface |
| calculator | #C2E0C6 | Calculator functionality |
| financial | #FFD700 | Financial calculators |
| core | #FF6B6B | Core functionality |
| setup | #FBCA04 | Project setup |
| priority: high | #B60205 | High priority |
| priority: medium | #FFA500 | Medium priority |
| priority: low | #FBCA04 | Low priority |
| good first issue | #7057FF | Good for newcomers |
| help wanted | #008672 | Help wanted |

## Step 5: Create Project Milestones

1. Go to Issues > Milestones
2. Create these milestones:

### Phase 1 (MVP) - Target: 2-4 weeks
- Basic calculator ✅
- Simple interest calculator
- Compound interest calculator
- History feature
- Settings and themes

### Phase 2 - Target: 1-2 months
- Loan calculator
- EMI calculator
- Percentage calculator
- Enhanced UI/UX
- Onboarding

### Phase 3 - Target: 2-3 months
- Investment calculator
- Export functionality
- Localization
- Accessibility improvements

### Phase 4 - Target: 3+ months
- Scientific calculator
- Unit conversions
- Currency converter
- Cloud sync (optional)

## Step 6: Set Up GitHub Actions (CI/CD)

Create `.github/workflows/flutter.yml`:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Analyze code
      run: flutter analyze

    - name: Run tests
      run: flutter test

    - name: Build APK
      run: flutter build apk
```

## Step 7: Add Community Files

GitHub will automatically recognize these files:
- ✅ `LICENSE` - Already added (MIT License)
- ✅ `CONTRIBUTING.md` - Already added
- Consider adding:
  - `CODE_OF_CONDUCT.md` - Code of conduct for contributors
  - `SECURITY.md` - Security policy
  - `.github/PULL_REQUEST_TEMPLATE.md` - PR template
  - `.github/ISSUE_TEMPLATE/` - Issue templates

## Step 8: Create Initial Release

Once you have the basic calculator working:

1. Go to "Releases" in your repository
2. Click "Create a new release"
3. Tag version: `v0.1.0`
4. Release title: `v0.1.0 - Initial Release`
5. Description:
```markdown
## 🎉 Initial Release

This is the first release of Life Mathematics!

### Features
- ✅ Basic arithmetic calculator
- ✅ Modern Material Design 3 UI
- ✅ Dark mode support
- ✅ Haptic feedback
- ✅ Responsive design

### What's Next
- Compound interest calculator
- Loan calculator
- History feature
- And many more features planned!

### Installation
Download the APK for Android or build from source using the instructions in `SETUP.md`.

### Feedback
Please report bugs and suggest features in the [Issues](https://github.com/YOUR_USERNAME/life-mathematics/issues) section.
```

## Step 9: Update README with Real URLs

Replace placeholders in README.md:
- `https://github.com/yourusername/life-mathematics` → Your actual repo URL
- `your.email@example.com` → Your actual email (or remove)

## Step 10: Promote Your Project

1. **Add to README badges** (update README.md):
```markdown
[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/life-mathematics.svg)](https://github.com/YOUR_USERNAME/life-mathematics/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/YOUR_USERNAME/life-mathematics.svg)](https://github.com/YOUR_USERNAME/life-mathematics/network)
[![GitHub issues](https://img.shields.io/github/issues/YOUR_USERNAME/life-mathematics.svg)](https://github.com/YOUR_USERNAME/life-mathematics/issues)
```

2. **Share on social media**:
   - Reddit: r/FlutterDev, r/opensource
   - Twitter/X with hashtags: #Flutter #FlutterDev #OpenSource
   - LinkedIn
   - Dev.to

3. **Submit to directories**:
   - [Awesome Flutter](https://github.com/Solido/awesome-flutter)
   - [Flutter Gallery](https://gallery.flutter.dev/)
   - [Made with Flutter](https://madewithflutter.net/)

## Quick Command Reference

```bash
# Check current remote
git remote -v

# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/life-mathematics.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main

# Create and switch to a new branch
git checkout -b feature/compound-interest

# Push new branch
git push -u origin feature/compound-interest

# Pull latest changes
git pull origin main
```

## Collaboration Workflow

1. Contributors fork your repository
2. They create a feature branch
3. Make changes and commit
4. Push to their fork
5. Create a Pull Request to your main branch
6. You review and merge

## Need Help?

- [GitHub Docs](https://docs.github.com)
- [GitHub Community](https://github.community/)
- [Open Source Guide](https://opensource.guide/)

---

Good luck with your open source project! 🚀
