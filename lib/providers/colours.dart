import 'package:flutter/material.dart';

class ThemeModel with ChangeNotifier {
  List<AppThemeData> _themes = [];
  int _currentThemeIndex = 1;

  ThemeModel() {
    // classic theme
    final themeOne = createTheme(
      swatch: Colors.blueGrey,
      primary: Colors.blueGrey,
      secondary: Colors.grey[300],
      background: Colors.white,
      error: Colors.redAccent,
      card: Colors.redAccent[100],
      divider: Colors.grey,
      indicator: Colors.green,
    );

    // ses theme
    final themeTwo = createTheme(
      swatch: createMaterialColor(const Color(0xFF1C3866)),
      primary: const Color.fromARGB(255, 28, 56, 102),
      secondary: Colors.grey[300],
      background: Colors.white,
      error: Colors.redAccent,
      card: const Color.fromARGB(255, 221, 123, 39),
      divider: Colors.grey[800],
      indicator: Colors.green,
    );

    // protanopia theme
    final themeThree = createTheme(
      swatch: createMaterialColor(const Color(0xFF003771)),
      primary: const Color(0xFF003771),
      secondary: const Color(0xFFD9D4D4),
      background: Colors.white,
      error: const Color(0xFF6A6B7A),
      card: const Color(0xFF6D87D1),
      divider: Colors.grey,
      indicator: const Color(0xFFCBB400),
    );

    // deuteranopia theme
    final themeFour = createTheme(
      swatch: createMaterialColor(const Color(0xFF003A61)),
      primary: const Color(0xFF003A61),
      secondary: const Color(0xFFE9CED7),
      background: Colors.white,
      error: const Color(0xFF81674E),
      card: const Color(0xFF6488CF),
      divider: Colors.grey,
      indicator: const Color(0xFFE4AA2F),
    );

    // tritanopia theme
    final themeFive = createTheme(
      swatch: createMaterialColor(const Color(0xFF003E43)),
      primary: const Color(0xFF003E43),
      secondary: const Color(0xFFD7D3E3),
      background: Colors.white,
      error: const Color(0xFFD12929),
      card: const Color(0xFF5A919C),
      divider: Colors.grey,
      indicator: const Color(0xFF5FC2D1),
    );

    // initialize themes
    _themes = [
      AppThemeData('Classic', themeOne),
      AppThemeData('SES Theme', themeTwo),
      AppThemeData('Protanopia', themeThree),
      AppThemeData('Deuteranopia', themeFour),
      AppThemeData('Tritanopia', themeFive),
    ];
  }

  ThemeData get currentTheme => _themes[_currentThemeIndex].theme;

  List<AppThemeData> get themeList => _themes;

  int get themeIndex => _currentThemeIndex;

  void setTheme(index) {
    _currentThemeIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
    notifyListeners();
  }

  static ThemeData createTheme({
    required MaterialColor swatch,
    required Color? primary,
    required Color? secondary,
    required Color? background,
    required Color? error,
    required Color? card,
    required Color? divider,
    required Color? indicator,
  }) {
    return ThemeData(
      primarySwatch: swatch,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: card,
      dividerColor: divider,
      indicatorColor: indicator,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: swatch)
          .copyWith(secondary: secondary, error: error),
    );
  }

  // used to create a material colour swatch from a colour
  // https://medium.com/@nickysong/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class AppThemeData {
  final ThemeData theme;
  final String name;

  AppThemeData(this.name, this.theme);
}
