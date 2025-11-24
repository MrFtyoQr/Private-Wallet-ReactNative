import 'package:flutter/material.dart';

import 'package:smart_wallet/core/constants/theme_constants.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ThemeConstants.primaryColor,
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.accentColor,
      surface: ThemeConstants.surfaceColor,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ThemeConstants.backgroundColor,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConstants.surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ThemeConstants.surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ThemeConstants.primaryColor,
      brightness: Brightness.dark,
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.accentColor,
      surface: const Color(0xFF1E1E1E),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
