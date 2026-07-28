import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  final ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => false;

  void toggleTheme(bool dark) {
    // Sempre fixado em Light Mode
  }
}

final themeController = ThemeController();
