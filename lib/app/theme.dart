import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF6750A4);
  static const Color _lightBackground = Color(0xFFFFFBFE);
  static const Color _lightSurface = Color(0xFFF3EDF7);
  static const Color _lightOnSurface = Color(0xFF1C1B1F);

  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFFD0BCFF);
  static const Color _darkBackground = Color(0xFF1C1B1F);
  static const Color _darkSurface = Color(0xFF2B2930);
  static const Color _darkOnSurface = Color(0xFFE6E1E5);

  // Calculator Button Colors
  static const Color numberButtonLight = Color(0xFFE8DEF8);
  static const Color operatorButtonLight = Color(0xFF6750A4);
  static const Color equalButtonLight = Color(0xFF6750A4);
  static const Color clearButtonLight = Color(0xFFEF5350);

  static const Color numberButtonDark = Color(0xFF4A4458);
  static const Color operatorButtonDark = Color(0xFFD0BCFF);
  static const Color equalButtonDark = Color(0xFFD0BCFF);
  static const Color clearButtonDark = Color(0xFFFF5252);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _lightBackground,
        foregroundColor: _lightOnSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _darkBackground,
        foregroundColor: _darkOnSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  static Color getNumberButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? numberButtonLight
        : numberButtonDark;
  }

  static Color getOperatorButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? operatorButtonLight
        : operatorButtonDark;
  }

  static Color getEqualButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? equalButtonLight
        : equalButtonDark;
  }

  static Color getClearButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? clearButtonLight
        : clearButtonDark;
  }
}
