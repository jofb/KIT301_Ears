import 'package:flutter/material.dart';

final themeOne = ThemeData(
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.redAccent[100],
  errorColor: Colors.redAccent,
  indicatorColor: Colors.green,
  dividerColor: Colors.grey,
  accentColor: Colors.grey[300]
);

final themeTwo = ThemeData(
  primarySwatch: primeswatch,
  primaryColor: const Color.fromARGB(255, 28, 56, 102),
  scaffoldBackgroundColor: Colors.white,
  cardColor: const Color.fromARGB(255, 221, 123, 39),
  errorColor: Colors.redAccent,
  indicatorColor: Colors.green,
  dividerColor: Colors.black,
  accentColor: Colors.grey[300]
);

class ThemeModel with ChangeNotifier {
  ThemeData _currentTheme = themeOne;

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == themeOne ? themeTwo : themeOne;
    notifyListeners();
  }
}

const MaterialColor primeswatch = MaterialColor(_primeswatchPrimaryValue, <int, Color>{
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

const MaterialColor primeswatchAccent = MaterialColor(_primeswatchAccentValue, <int, Color>{
  100: Color(0xFF6283FF),
  200: Color(_primeswatchAccentValue),
  400: Color(0xFF0035FB),
  700: Color(0xFF0030E1),
});
const int _primeswatchAccentValue = 0xFF2F5BFF;