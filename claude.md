# Life Mathematics - Project Instructions

## Project Overview
Life Mathematics is a comprehensive all-purpose calculator app built with Flutter. It handles everyday calculations, financial planning, compound interest, loan calculations, and more.

## Tech Stack
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: setState (basic), will migrate to Provider/Riverpod for complex features
- **Storage**: shared_preferences for settings and history
- **UI**: Material Design 3 with custom theming

## Project Structure
```
lib/
├── main.dart              # App entry point
├── app/
│   └── theme.dart         # Theme configuration
├── screens/               # UI screens
│   └── calculator_screen.dart
├── widgets/               # Reusable widgets
│   └── calculator_button.dart
└── utils/                 # Helper functions
    └── calculator_logic.dart
```

## Development Guidelines

### Code Style
- Follow the Dart style guide
- Use `flutter format` before committing
- Ensure `flutter analyze` passes with no issues
- Prefer `const` constructors where possible
- Use meaningful variable and function names

### Testing
- Write unit tests for all calculation logic
- Write widget tests for UI components
- Run `flutter test` before committing
- Aim for >80% code coverage

### Git Workflow
- Create feature branches for new features
- Follow conventional commits format
- Keep commits atomic and focused
- Write clear commit messages

### UI/UX Principles
- Follow Material Design 3 guidelines
- Ensure responsive design for all screen sizes
- Support both light and dark themes
- Add haptic feedback for button presses
- Smooth animations and transitions
- Accessibility is a priority

## Current Implementation Status

### Completed
- ✅ Project setup with documentation
- ✅ Basic calculator with modern UI
- ✅ Dark mode support
- ✅ Theme switching
- ✅ Clean, responsive layout
- ✅ Haptic feedback
- ✅ Calculation logic with operator precedence
- ✅ Unit tests for calculator logic

### In Progress
- 🔄 None currently

### TODO (Priority Order)
1. Compound Interest Calculator
2. Loan Calculator with amortization
3. Simple Interest Calculator
4. EMI Calculator
5. Calculation history feature
6. Settings screen
7. Percentage calculator suite
8. Investment return calculator

See [ISSUES.md](ISSUES.md) for detailed issue tracking.

## Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/ test/
```

## Feature Development Process

When adding new calculators:
1. Create model in `lib/models/`
2. Implement calculation logic in `lib/utils/`
3. Create screen in `lib/screens/`
4. Add reusable widgets in `lib/widgets/` if needed
5. Write unit tests
6. Write widget tests
7. Update navigation
8. Update README and documentation

## Design Decisions

### Why Material Design 3?
- Modern, clean aesthetic
- Native feel on Android
- Good component library
- Excellent dark mode support

### Why setState for now?
- Simple enough for basic calculator
- Will migrate to Provider/Riverpod when adding:
  - History feature
  - Settings persistence
  - Multiple calculator types

### Button Layout
- 4x5 grid for optimal thumb reach
- Large tap targets (minimum 48x48 dp)
- Clear visual hierarchy
- Rounded corners for modern look

## Notes for AI Assistant (Claude)

When working on this project:
- Always run tests after making changes to logic
- Ensure theme colors are consistent
- Test both light and dark modes
- Keep button layout responsive
- Add proper error handling
- Document complex calculations with comments
- Follow the existing code structure
- Update tests when adding new features

## Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Testing](https://flutter.dev/docs/testing)

## Contact
For questions or issues, please open a GitHub issue.
