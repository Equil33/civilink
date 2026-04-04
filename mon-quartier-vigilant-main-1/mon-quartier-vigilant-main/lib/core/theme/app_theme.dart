import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF0072B2);

  static ThemeMode getThemeMode(String? modeString) {
    switch (modeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'AppReadable',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFAFAF8),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
      ),
      textTheme: _textTheme(ThemeData.light().textTheme, colorScheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          fontSize: 15,
          height: 1.35,
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        helperStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B4E8A),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF2B632),
          foregroundColor: const Color(0xFF1E1A10),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'AppReadable',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0D1723),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
      ),
      textTheme: _textTheme(ThemeData.dark().textTheme, colorScheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          fontSize: 15,
          height: 1.35,
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        helperStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6BB2FF),
          foregroundColor: const Color(0xFF0B1726),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF2B632),
          foregroundColor: const Color(0xFF1E1A10),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color textColor) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 34, fontWeight: FontWeight.w800, color: textColor),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
      titleLarge: base.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
      titleMedium: base.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.45, color: textColor),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 16, height: 1.45, color: textColor),
      bodySmall: base.bodySmall?.copyWith(fontSize: 14, height: 1.35, color: textColor),
      labelLarge: base.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
