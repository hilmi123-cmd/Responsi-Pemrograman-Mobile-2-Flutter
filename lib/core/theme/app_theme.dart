import 'package:material_ui/material_ui.dart';

/// Konfigurasi Material 3 ThemeData dan skala Typography (TextTheme)
/// untuk menjaga konsistensi warna, keterbacaan, dan hierarki antarmuka.
class AppTheme {
  AppTheme._();

  static const Color _seedBlue = Color(0xFF1A73E8);

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.0,
        height: 1.05,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedBlue,
      brightness: Brightness.light,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF3F6FA),
      textTheme: _buildTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFFF3F6FA),
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: _buildTextTheme(
          baseTheme.textTheme,
        ).titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedBlue,
      brightness: Brightness.dark,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0E141E),
      textTheme: _buildTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFF0E141E),
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: _buildTextTheme(
          baseTheme.textTheme,
        ).titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF16202F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF16202F),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
