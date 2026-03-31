import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Calculus Dark — "The Obsidian Architect"
/// Primary: #a8a4ff Electric Indigo, bg: #0e0e0e The Void
class AppTheme {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF1A1919);
  static const Color surfaceContainerHigh = Color(0xFF201F1F);
  static const Color surfaceContainerHighest = Color(0xFF262626);
  static const Color surfaceContainerLowest = Color(0xFF000000);

  static const Color primary = Color(0xFFa8a4ff);
  static const Color primaryDim = Color(0xFF675df9);
  static const Color onPrimary = Color(0xFF1e009f);

  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFadaaaa);

  static const Color error = Color(0xFFff6e84);
  static const Color errorContainer = Color(0xFF3D1515);

  // Button-specific
  static const Color btnNumber = surfaceContainerHigh;     // #201f1f
  static const Color btnOperator = surfaceContainerLowest; // #000
  static const Color btnClear = errorContainer;            // red tinted
  static const Color btnFunction = surfaceContainer;       // #1a1919

  static const Color indigo = primary;
  static const Color green = Color(0xFF00C853);
  static const Color greenDark = Color(0xFF069E46);

  // ── Typography ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme() {
    final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme();
    final manrope = GoogleFonts.manropeTextTheme();
    return TextTheme(
      // Display — Space Grotesk (numbers, heroes)
      displayLarge: spaceGrotesk.displayLarge?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      displayMedium: spaceGrotesk.displayMedium?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displaySmall: spaceGrotesk.displaySmall?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w400,
      ),
      // Headlines — Space Grotesk
      headlineLarge: spaceGrotesk.headlineLarge?.copyWith(color: onSurface),
      headlineMedium: spaceGrotesk.headlineMedium?.copyWith(color: onSurface),
      headlineSmall: spaceGrotesk.headlineSmall?.copyWith(color: onSurface),
      // Titles — Space Grotesk
      titleLarge: spaceGrotesk.titleLarge?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: spaceGrotesk.titleMedium?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: spaceGrotesk.titleSmall?.copyWith(color: onSurface),
      // Body — Manrope
      bodyLarge: manrope.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: manrope.bodyMedium?.copyWith(color: onSurfaceVariant),
      bodySmall: manrope.bodySmall?.copyWith(color: onSurfaceVariant),
      // Labels — Manrope
      labelLarge: manrope.labelLarge?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: manrope.labelMedium?.copyWith(color: onSurfaceVariant),
      labelSmall: manrope.labelSmall?.copyWith(
        color: onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }

  // ── Single dark theme (Calculus Dark is always dark) ───────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // Light theme kept for theme-toggle compatibility — uses same palette
  // with a lighter surface tint but keeps the indigo accent
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final cs = isDark
        ? const ColorScheme.dark(
            primary: primary,
            onPrimary: onPrimary,
            secondary: Color(0xFFe5e2e1),
            onSecondary: Color(0xFF403f3f),
            surface: background,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            error: error,
            outline: Color(0xFF767575),
            outlineVariant: Color(0xFF484847),
            surfaceContainerLowest: surfaceContainerLowest,
            surfaceContainerLow: surfaceContainerLow,
            surfaceContainer: surfaceContainer,
            surfaceContainerHigh: surfaceContainerHigh,
            surfaceContainerHighest: surfaceContainerHighest,
          )
        : const ColorScheme.light(
            primary: primary,
            onPrimary: Colors.white,
            secondary: Color(0xFF474746),
            surface: Color(0xFF1a1919),
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            error: error,
          );

    final tt = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      textTheme: tt,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        centerTitle: true,
        titleTextStyle: tt.titleMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: onSurfaceVariant),
        hintStyle: const TextStyle(color: onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(color: Colors.transparent),
      iconTheme: const IconThemeData(color: onSurfaceVariant),
    );
  }
}
