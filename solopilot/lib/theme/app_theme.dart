import 'package:flutter/material.dart';

class AppTheme {
  // Trustworthy Indigo brand color
  static const Color seedColor = Colors.indigo;

  static ThemeData get lightTheme {
    return ThemeData(
      colorSchemeSeed: seedColor,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
