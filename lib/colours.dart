import 'package:flutter/material.dart';

// final themeProt = ThemeData(
//     primarySwatch: mcgpalette0,
//     primaryColor: Color.fromARGB(255, 51, 34, 136),
//     scaffoldBackgroundColor: Colors.white,
//     cardColor: Color.fromARGB(255, 204, 102, 119),
//     errorColor: Color.fromARGB(255, 212, 17, 89),
//     indicatorColor: Color.fromARGB(255, 0, 210, 0),
//     dividerColor: Colors.grey,
//     accentColor: Colors.grey[300],
// );

// const MaterialColor mcgpalette0 = MaterialColor(_mcgpalette0PrimaryValue, <int, Color>{
//   50: Color(0xFFE7E4F1),
//   100: Color(0xFFC2BDDB),
//   200: Color(0xFF9991C4),
//   300: Color(0xFF7064AC),
//   400: Color(0xFF52439A),
//   500: Color(_mcgpalette0PrimaryValue),
//   600: Color(0xFF2E1E80),
//   700: Color(0xFF271975),
//   800: Color(0xFF20146B),
//   900: Color(0xFF140C58),
// });
// const int _mcgpalette0PrimaryValue = 0xFF332288;

final themeProt = ThemeData(
    primarySwatch: mcgpalette0,
    primaryColor: Color(0xFF003771),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Color(0xFF6D87D1),
    errorColor: Color(0xFF6A6B7A),
    indicatorColor: Color(0xFFCBB400),
    dividerColor: Colors.grey,
    accentColor: Color(0xFFD9D4D4),
);

const MaterialColor mcgpalette0 = MaterialColor(_mcgpalette0PrimaryValue, <int, Color>{
  50: Color(0xFFE0E7EE),
  100: Color(0xFFB3C3D4),
  200: Color(0xFF809BB8),
  300: Color(0xFF4D739C),
  400: Color(0xFF265586),
  500: Color(_mcgpalette0PrimaryValue),
  600: Color(0xFF003169),
  700: Color(0xFF002A5E),
  800: Color(0xFF002354),
  900: Color(0xFF001642),
});
const int _mcgpalette0PrimaryValue = 0xFF003771;

final themeDeut = ThemeData(
    primarySwatch: mcgpalette1,
    primaryColor: Color(0xFF003A61),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Color(0xFF6488CF),
    errorColor: Color(0xFF81674E),
    indicatorColor: Color(0xFFE4AA2F),
    dividerColor: Colors.grey,
    accentColor: Color(0xFFE9CED7),
);

const MaterialColor mcgpalette1 = MaterialColor(_mcgpalette1PrimaryValue, <int, Color>{
  50: Color(0xFFE0E7EC),
  100: Color(0xFFB3C4D0),
  200: Color(0xFF809DB0),
  300: Color(0xFF4D7590),
  400: Color(0xFF265879),
  500: Color(_mcgpalette1PrimaryValue),
  600: Color(0xFF003459),
  700: Color(0xFF002C4F),
  800: Color(0xFF002545),
  900: Color(0xFF001833),
});
const int _mcgpalette1PrimaryValue = 0xFF003A61;

final themeTrit = ThemeData(
    primarySwatch: mcgpalette2,
    primaryColor: Color(0xFF003E43),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Color(0xFF5A919C),
    errorColor: Color(0xFFD12929),
    indicatorColor: Color(0xFF5FC2D1),
    dividerColor: Colors.grey,
    accentColor: Color(0xFFD7D3E3),
);

const MaterialColor mcgpalette2 = MaterialColor(_mcgpalette2PrimaryValue, <int, Color>{
  50: Color(0xFFE0E8E8),
  100: Color(0xFFB3C5C7),
  200: Color(0xFF809FA1),
  300: Color(0xFF4D787B),
  400: Color(0xFF265B5F),
  500: Color(_mcgpalette2PrimaryValue),
  600: Color(0xFF00383D),
  700: Color(0xFF003034),
  800: Color(0xFF00282C),
  900: Color(0xFF001B1E),
});
const int _mcgpalette2PrimaryValue = 0xFF003E43;

final themeOne = ThemeData(
    primarySwatch: Colors.blueGrey,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.redAccent[100],
    errorColor: Colors.redAccent,
    indicatorColor: Colors.green,
    dividerColor: Colors.grey,
    accentColor: Colors.grey[300],
);

final themeTwo = ThemeData(
    primarySwatch: primeswatch,
    primaryColor: const Color.fromARGB(255, 28, 56, 102),
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color.fromARGB(255, 221, 123, 39),
    errorColor: Colors.redAccent,
    indicatorColor: Colors.green,
    dividerColor: Colors.grey[800],
    accentColor: Colors.grey[300]);

class ThemeModel with ChangeNotifier {
  final List<ThemeData> _themes = [themeOne, themeTwo, themeProt, themeDeut, themeTrit];
  int _currentThemeIndex = 0;

  ThemeData get currentTheme => _themes[_currentThemeIndex];

  void setTheme(index) {
    _currentThemeIndex = index;
    notifyListeners();
  }

  int getThemeIndex() {
    return _currentThemeIndex;
  }

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
const int _primeswatchPrimaryValue = 0xFF1C3866;
