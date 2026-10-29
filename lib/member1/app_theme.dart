import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const ink = Color(0xFF070B16);
  static const panel = Color(0xFF111A2B);
  static const cyan = Color(0xFF62F4D4);
  static const blue = Color(0xFF7D9BFF);
  static const violet = Color(0xFFB78CFF);

  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      primary: cyan,
      secondary: violet,
      surface: panel,
      onSurface: Color(0xFFEAF0FF),
      onSurfaceVariant: Color(0xFF9DAAC4),
      primaryContainer: Color(0xFF163B43),
      onPrimaryContainer: Color(0xFFC7FFF3),
      outline: Color(0xFF29364B),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        foregroundColor: Color(0xFFEAF0FF),
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFEAF0FF)),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF263149))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0C1423),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF29364B))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF29364B))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: cyan, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: cyan, foregroundColor: ink, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF263149)),
    );
  }
}
