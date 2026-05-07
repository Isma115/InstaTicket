// region Estilos Aplicación: tema principal
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF2457F5),
      secondary: Color(0xFF24B9C2),
      tertiary: Color(0xFF0F3555),
      surface: Color(0xFFF5F7FB),
      error: Color(0xFFB3261E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: const Color(0xFFEFF3F8),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Color(0xFF173B5E),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF173B5E),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: Color(0xFF354C67),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF5F738A),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF70839A),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6DDE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6DDE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF173B5E),
          side: const BorderSide(color: Color(0xFFD5E2EC)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: Color(0xFFD9E1EC)),
        ),
      ),
    );
  }
}
// endregion
