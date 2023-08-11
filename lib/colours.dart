import 'package:flutter/material.dart';

final themeOne = ThemeData(
    primarySwatch: Colors.blueGrey,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.redAccent[100],
    errorColor: Colors.redAccent,
    indicatorColor: Colors.green,
    dividerColor: Colors.grey,
    accentColor: Colors.grey[300]);

final themeTwo = ThemeData(
    primarySwatch: primeswatch,
    primaryColor: const Color.fromARGB(255, 28, 56, 102),
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color.fromARGB(255, 221, 123, 39),
    errorColor: Colors.redAccent,
    indicatorColor: Colors.green,
    dividerColor: Colors.grey[800],
    accentColor: Colors.grey[300]);

final themeThree = ThemeData(
    primarySwatch: const MaterialColor(_customPrimaryValue, <int, Color>{
      50: Color(0xFFEAE4F3),
      100: Color(0xFFCBBAE1),
      200: Color(0xFFA98DCD),
      300: Color(0xFF865FB8),
      400: Color(0xFF6C3CA9),
      500: Color(_customPrimaryValue),
      600: Color(0xFF4B1792),
      700: Color(0xFF411388),
      800: Color(0xFF380F7E),
      900: Color(0xFF28086C),
    }),
    primaryColor: const Color(_customPrimaryValue),
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color.fromARGB(255, 190, 161, 229),
    errorColor: Colors.redAccent,
    indicatorColor: Colors.green,
    dividerColor: Colors.grey,
    accentColor: Colors.grey[300]);

const int _customPrimaryValue = 0xFF521A9A;

class ThemeModel with ChangeNotifier {
  final List<ThemeData> _themes = [themeOne, themeTwo, themeThree];
  int _currentThemeIndex = 0;

  ThemeData get currentTheme => _themes[_currentThemeIndex];

  void toggleTheme() {
    _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
    notifyListeners();
  }
}

const MaterialColor primeswatch =
    MaterialColor(_primeswatchPrimaryValue, <int, Color>{
  50: Color(0xFFE2E5EA),
  100: Color(0xFFB7BFCA),
  200: Color(0xFF8894A7),
  300: Color(0xFF586984),
  400: Color(0xFF344969),
  500: Color(_primeswatchPrimaryValue),
  600: Color(0xFF0E2448),
  700: Color(0xFF0C1F3F),
  800: Color(0xFF091936),
  900: Color(0xFF050F26),
});
const int _primeswatchPrimaryValue = 0xFF10294F;
