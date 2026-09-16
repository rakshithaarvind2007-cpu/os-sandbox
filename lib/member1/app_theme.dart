import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 4),
    ),
  );
}
