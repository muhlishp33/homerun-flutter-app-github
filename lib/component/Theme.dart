import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/widget/constants.dart';

enum MyTheme { light, dark }

// notes status bar
// Brightness.light > bg white & text black
// Brightness.dark > bg black & text white

class ThemeNotifier with ChangeNotifier {
  static List<ThemeData> themes = [
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.red,
      backgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        color: Constants.redTheme,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleSpacing: 0,
      ),
      fontFamily: 'Poppins',
    ),
    ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.red,
      fontFamily: 'Poppins',
    ),
  ];

  MyTheme _current = MyTheme.light;
  ThemeData _currentTheme = themes[0];

  void switchTheme() => currentTheme == MyTheme.light
      ? currentTheme = MyTheme.dark
      : currentTheme = MyTheme.light;

  set currentTheme(theme) {
    if (theme != null) {
      _current = theme;
      _currentTheme = _current == MyTheme.light ? themes[0] : themes[1];

      notifyListeners();
    }
  }

  get currentTheme => _current;
  get currentThemeData => _currentTheme;
}
