import 'package:flutter/material.dart';
// SystemUiOverlayStyle is not re-exported by material.dart.
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:google_fonts/google_fonts.dart';

/// Every surface/accent colour the app paints, resolved per brightness.
///
/// Widgets read these through `context.palette` rather than referencing raw
/// constants, so a theme switch actually repaints the UI.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  final Color primary;
  final Color primaryDim;
  final Color onPrimary;

  final Color onSurface;
  final Color onSurfaceVariant;

  final Color error;
  final Color errorContainer;
  final Color green;
  final Color greenDark;
  final Color pinned;

  // Keypad
  final Color btnNumber;
  final Color btnOperator;
  final Color btnClear;
  final Color btnFunction;

  const AppPalette({
    required this.background,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.primary,
    required this.primaryDim,
    required this.onPrimary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.error,
    required this.errorContainer,
    required this.green,
    required this.greenDark,
    required this.pinned,
    required this.btnNumber,
    required this.btnOperator,
    required this.btnClear,
    required this.btnFunction,
  });

  /// Calculus Dark — "The Obsidian Architect"
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0E0E0E),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF131313),
    surfaceContainer: Color(0xFF1A1919),
    surfaceContainerHigh: Color(0xFF201F1F),
    surfaceContainerHighest: Color(0xFF262626),
    primary: Color(0xFFA8A4FF),
    primaryDim: Color(0xFF675DF9),
    onPrimary: Color(0xFF1E009F),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFADAAAA),
    error: Color(0xFFFF6E84),
    errorContainer: Color(0xFF3D1515),
    green: Color(0xFF00C853),
    greenDark: Color(0xFF069E46),
    pinned: Color(0xFFFFD600),
    // Numbers sit above the keypad, operators sink below it.
    btnNumber: Color(0xFF201F1F),
    btnOperator: Color(0xFF000000),
    btnClear: Color(0xFF3D1515),
    btnFunction: Color(0xFF1A1919),
  );

  /// Calculus Light — same geometry, inverted depth.
  static const AppPalette light = AppPalette(
    background: Color(0xFFFAF9FB),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF5F3F7),
    surfaceContainer: Color(0xFFF1EFF4),
    surfaceContainerHigh: Color(0xFFEAE7EF),
    surfaceContainerHighest: Color(0xFFE2DEE9),
    primary: Color(0xFF5B4CE0),
    primaryDim: Color(0xFF4436C4),
    onPrimary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF16151A),
    onSurfaceVariant: Color(0xFF5D5A66),
    error: Color(0xFFC0263C),
    errorContainer: Color(0xFFFBE0E4),
    green: Color(0xFF0A7A3D),
    greenDark: Color(0xFF06612F),
    pinned: Color(0xFFB98900),
    btnNumber: Color(0xFFFFFFFF),
    btnOperator: Color(0xFFE2DEE9),
    btnClear: Color(0xFFFBE0E4),
    btnFunction: Color(0xFFF1EFF4),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? primary,
    Color? primaryDim,
    Color? onPrimary,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? error,
    Color? errorContainer,
    Color? green,
    Color? greenDark,
    Color? pinned,
    Color? btnNumber,
    Color? btnOperator,
    Color? btnClear,
    Color? btnFunction,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      primary: primary ?? this.primary,
      primaryDim: primaryDim ?? this.primaryDim,
      onPrimary: onPrimary ?? this.onPrimary,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      green: green ?? this.green,
      greenDark: greenDark ?? this.greenDark,
      pinned: pinned ?? this.pinned,
      btnNumber: btnNumber ?? this.btnNumber,
      btnOperator: btnOperator ?? this.btnOperator,
      btnClear: btnClear ?? this.btnClear,
      btnFunction: btnFunction ?? this.btnFunction,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      surfaceContainerLowest:
          c(surfaceContainerLowest, other.surfaceContainerLowest),
      surfaceContainerLow: c(surfaceContainerLow, other.surfaceContainerLow),
      surfaceContainer: c(surfaceContainer, other.surfaceContainer),
      surfaceContainerHigh: c(surfaceContainerHigh, other.surfaceContainerHigh),
      surfaceContainerHighest:
          c(surfaceContainerHighest, other.surfaceContainerHighest),
      primary: c(primary, other.primary),
      primaryDim: c(primaryDim, other.primaryDim),
      onPrimary: c(onPrimary, other.onPrimary),
      onSurface: c(onSurface, other.onSurface),
      onSurfaceVariant: c(onSurfaceVariant, other.onSurfaceVariant),
      error: c(error, other.error),
      errorContainer: c(errorContainer, other.errorContainer),
      green: c(green, other.green),
      greenDark: c(greenDark, other.greenDark),
      pinned: c(pinned, other.pinned),
      btnNumber: c(btnNumber, other.btnNumber),
      btnOperator: c(btnOperator, other.btnOperator),
      btnClear: c(btnClear, other.btnClear),
      btnFunction: c(btnFunction, other.btnFunction),
    );
  }
}

/// `context.palette` — the only way widgets should reach for colour.
extension PaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme => _buildTheme(AppPalette.dark);
  static ThemeData get lightTheme => _buildTheme(AppPalette.light);

  static TextTheme _buildTextTheme(AppPalette p) {
    final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme();
    final manrope = GoogleFonts.manropeTextTheme();
    return TextTheme(
      // Display — Space Grotesk (numbers, heroes)
      displayLarge: spaceGrotesk.displayLarge?.copyWith(
        color: p.onSurface,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      displayMedium: spaceGrotesk.displayMedium?.copyWith(
        color: p.onSurface,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displaySmall: spaceGrotesk.displaySmall?.copyWith(
        color: p.onSurface,
        fontWeight: FontWeight.w400,
      ),
      // Headlines — Space Grotesk
      headlineLarge: spaceGrotesk.headlineLarge?.copyWith(color: p.onSurface),
      headlineMedium: spaceGrotesk.headlineMedium?.copyWith(color: p.onSurface),
      headlineSmall: spaceGrotesk.headlineSmall?.copyWith(color: p.onSurface),
      // Titles — Space Grotesk
      titleLarge: spaceGrotesk.titleLarge?.copyWith(
        color: p.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: spaceGrotesk.titleMedium?.copyWith(
        color: p.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: spaceGrotesk.titleSmall?.copyWith(color: p.onSurface),
      // Body — Manrope
      bodyLarge: manrope.bodyLarge?.copyWith(color: p.onSurface),
      bodyMedium: manrope.bodyMedium?.copyWith(color: p.onSurfaceVariant),
      bodySmall: manrope.bodySmall?.copyWith(color: p.onSurfaceVariant),
      // Labels — Manrope
      labelLarge: manrope.labelLarge?.copyWith(
        color: p.onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: manrope.labelMedium?.copyWith(color: p.onSurfaceVariant),
      labelSmall: manrope.labelSmall?.copyWith(
        color: p.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }

  static ThemeData _buildTheme(AppPalette p) {
    final isDark = p == AppPalette.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final cs = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.primaryDim,
      onSecondary: p.onPrimary,
      surface: p.background,
      onSurface: p.onSurface,
      onSurfaceVariant: p.onSurfaceVariant,
      error: p.error,
      onError: isDark ? const Color(0xFF3D1515) : Colors.white,
      outline: p.onSurfaceVariant,
      outlineVariant: p.surfaceContainerHighest,
      surfaceContainerLowest: p.surfaceContainerLowest,
      surfaceContainerLow: p.surfaceContainerLow,
      surfaceContainer: p.surfaceContainer,
      surfaceContainerHigh: p.surfaceContainerHigh,
      surfaceContainerHighest: p.surfaceContainerHighest,
    );

    final tt = _buildTextTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      textTheme: tt,
      scaffoldBackgroundColor: p.background,
      extensions: <ThemeExtension<dynamic>>[p],
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: p.onSurface,
        centerTitle: true,
        titleTextStyle: tt.titleMedium,
        // Without this the status bar keeps white glyphs over the light
        // background and the clock becomes unreadable.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: p.background,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceContainerHigh,
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
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: p.onSurfaceVariant),
        hintStyle: TextStyle(color: p.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(color: Colors.transparent),
      iconTheme: IconThemeData(color: p.onSurfaceVariant),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );
  }
}
