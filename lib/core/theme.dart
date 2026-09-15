import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const background = Color(0xFFFAFAFA);
  static const foreground = Color(0xFF18181B);
  static const mutedForeground = Color(0xFF71717A);
  static const border = Color(0xFFE4E4E7);

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF18181B),
          brightness: Brightness.light,
        ).copyWith(
          surface: background,
          onSurface: foreground,
          primary: foreground,
          onPrimary: Colors.white,
          outline: border,
          error: const Color(0xFFB42318),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: foreground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: foreground, fontSize: 14),
        bodySmall: TextStyle(color: mutedForeground, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: foreground, width: 1.5),
        ),
        labelStyle: const TextStyle(color: mutedForeground, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mutedForeground,
          textStyle: const TextStyle(fontSize: 13),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(color: border),
    );
  }

  static ThemeData dark() {
    const darkBackground = Color(0xFF09090B);
    const darkSurface = Color(0xFF18181B);
    const darkForeground = Color(0xFFFAFAFA);
    const darkMutedForeground = Color(0xFFA1A1AA);
    const darkBorder = Color(0xFF27272A);
    final colorScheme = const ColorScheme.dark(
      surface: darkBackground,
      onSurface: darkForeground,
      primary: darkForeground,
      onPrimary: Color(0xFF18181B),
      secondary: Color(0xFFA1A1AA),
      onSecondary: Color(0xFF18181B),
      outline: darkBorder,
      error: Color(0xFFF97066),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: darkForeground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkForeground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: darkForeground, fontSize: 14),
        bodySmall: TextStyle(color: darkMutedForeground, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkForeground, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkMutedForeground, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkMutedForeground,
          textStyle: const TextStyle(fontSize: 13),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkForeground,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(color: darkBorder),
    );
  }
}
