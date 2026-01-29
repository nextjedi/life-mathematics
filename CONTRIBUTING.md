# Contributing to Life Mathematics

Thank you for considering contributing to Life Mathematics! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots if applicable
- Device/platform information
- Flutter and Dart version

### Suggesting Features

Feature requests are welcome! Please include:

- Clear description of the feature
- Use case and benefits
- Any implementation ideas (optional)
- Mockups or examples (optional)

### Pull Requests

1. **Fork the repository** and create your branch from `main`
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clear, commented code
   - Follow the existing code style
   - Add tests if applicable
   - Update documentation as needed

3. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit your changes**
   - Use clear, descriptive commit messages
   - Follow conventional commits format:
     ```
     feat: add loan amortization schedule
     fix: correct compound interest calculation
     docs: update setup instructions
     style: format calculator button layout
     test: add tests for interest calculation
     ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Provide a clear title and description
   - Reference any related issues
   - Include screenshots for UI changes
   - Ensure all checks pass

## Development Setup

See [SETUP.md](SETUP.md) for detailed setup instructions.

## Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Keep functions small and focused
- Comment complex logic
- Use const constructors where possible

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── screens/               # UI screens
├── widgets/               # Reusable widgets
├── utils/                 # Helper functions
└── constants/             # Constants and themes
```

## Testing

- Write unit tests for calculations
- Write widget tests for UI components
- Ensure all tests pass before submitting PR

## Questions?

Feel free to open an issue with the `question` label or reach out to the maintainers.

## Recognition

Contributors will be recognized in the README and release notes.

Thank you for contributing! 🎉
