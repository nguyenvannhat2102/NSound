import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nsound/data/services/hive_box.dart';

abstract class ThemeColor {
  final String themeName;
  final Color primaryColor;
  final Color secondaryColor;
  final ColorScheme colorScheme;
  final LinearGradient linearGradient;

  const ThemeColor({
    required this.themeName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.colorScheme,
    required this.linearGradient,
  });
}

class BlackTheme extends ThemeColor {
  BlackTheme()
      : super(
          themeName: 'Black',
          primaryColor: const Color(0xff000000),
          secondaryColor: const Color(0xFF1B1B1B),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff000000),
              Color(0xFF1B1B1B),
            ],
          ),
        );
}

class WhiteTheme extends ThemeColor {
  WhiteTheme()
      : super(
          themeName: 'White',
          primaryColor: const Color(0XFFD3CCE3),
          secondaryColor: const Color(0xFFE9E4F0),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
            brightness: Brightness.light,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0XFFD3CCE3),
              Color(0xFFE9E4F0),
            ],
          ),
        );
}

class Themes {
  static final List<ThemeColor> _themes = [
    WhiteTheme(),
    BlackTheme(),
  ];

  static final List<String> _themeNames = [
    'White',
    'Black',
  ];

  static get themes => _themes;

  static List<String> get themeNames => _themeNames;

  static ThemeColor getThemeFromKey(String key) {
    switch (key) {
      case 'White':
        return _themes[0];
      case 'Black':
        return _themes[1];
      default:
        return _themes[0];
    }
  }

  static Future<void> setTheme(String themeName) async {
    final Box<dynamic> box = Hive.box(HiveBox.boxName);
    await box.put(HiveBox.themeKey, themeName);
  }

  static String getThemeName() {
    final Box<dynamic> box = Hive.box(HiveBox.boxName);
    final String? themeName = box.get(HiveBox.themeKey) as String?;
    return themeName ?? 'White';
  }

  static ThemeColor getTheme() {
    final Box<dynamic> box = Hive.box(HiveBox.boxName);
    final String? themeName = box.get(HiveBox.themeKey) as String?;
    return getThemeFromKey(themeName ?? 'White');
  }
}
