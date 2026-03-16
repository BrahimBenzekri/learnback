import 'package:flutter/material.dart';

class AppTheme {
  // Use a primary brand color, maybe a nice learning-oriented blue/indigo
  static const _primaryColor = Color(0xFF4F46E5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'SpaceGrotesk',
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      fontFamily: 'SpaceGrotesk',
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}
