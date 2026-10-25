import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppColorScheme {
  purple, // Default
  rose,
  teal,
  amber,
  indigo,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _colorSchemeKey = 'app_color_scheme';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'en'; // 'en' or 'hi'
  AppColorScheme _colorScheme = AppColorScheme.purple;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  AppColorScheme get colorScheme => _colorScheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Color scheme definitions
  static const Map<AppColorScheme, Map<String, Color>> _colorSchemes = {
    AppColorScheme.purple: {
      'primary': Color(0xFFD4C4E8),
      'dark': Color(0xFF9B7FC8),
      'light': Color(0xFFF0E6FA),
      'background': Color(0xFFFAF5FF),
      'darkBg': Color(0xFF1A1A2E),
      'darkSurface': Color(0xFF16213E),
    },
    AppColorScheme.rose: {
      'primary': Color(0xFFFFB6C1),
      'dark': Color(0xFFFF69B4),
      'light': Color(0xFFFFC0CB),
      'background': Color(0xFFFFF5F7),
      'darkBg': Color(0xFF2A1A1F),
      'darkSurface': Color(0xFF3E1620),
    },
    AppColorScheme.teal: {
      'primary': Color(0xFF80DEEA),
      'dark': Color(0xFF00BCD4),
      'light': Color(0xFFB2EBF2),
      'background': Color(0xFFF0F7F8),
      'darkBg': Color(0xFF0D2B2E),
      'darkSurface': Color(0xFF1A3F42),
    },
    AppColorScheme.amber: {
      'primary': Color(0xFFFFD54F),
      'dark': Color(0xFFFBC02D),
      'light': Color(0xFFFFE082),
      'background': Color(0xFFFFFBE6),
      'darkBg': Color(0xFF2A2410),
      'darkSurface': Color(0xFF3E3620),
    },
    AppColorScheme.indigo: {
      'primary': Color(0xFF9FA8DA),
      'dark': Color(0xFF5C6BC0),
      'light': Color(0xFFC5CAE9),
      'background': Color(0xFFF5F5F7),
      'darkBg': Color(0xFF1A1A2E),
      'darkSurface': Color(0xFF262E4E),
    },
  };

  ThemeProvider() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTheme();
    _loadLanguage();
    _loadColorScheme();
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey) ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void _loadLanguage() {
    _language = _prefs.getString(_languageKey) ?? 'en';
  }

  void _loadColorScheme() {
    final saved = _prefs.getString(_colorSchemeKey) ?? 'purple';
    _colorScheme = AppColorScheme.values.firstWhere(
      (e) => e.toString().split('.').last == saved,
      orElse: () => AppColorScheme.purple,
    );
  }

  Future<void> setTheme(ThemeMode theme) async {
    _themeMode = theme;
    await _prefs.setString(
      _themeKey,
      theme == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setTheme(newTheme);
  }

  Future<void> setLanguage(String lang) async {
    if (lang != 'en' && lang != 'hi') return;
    _language = lang;
    await _prefs.setString(_languageKey, lang);
    notifyListeners();
  }

  Future<void> setColorScheme(AppColorScheme scheme) async {
    _colorScheme = scheme;
    await _prefs.setString(_colorSchemeKey, scheme.toString().split('.').last);
    notifyListeners();
  }

  Color _getColor(String colorKey) {
    return _colorSchemes[_colorScheme]?[colorKey] ?? Colors.purple;
  }

  ThemeData getLightTheme() {
    final primary = _getColor('primary');
    final dark = _getColor('dark');
    final light = _getColor('light');
    final background = _getColor('background');

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: dark,
        surface: Colors.white,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData getDarkTheme() {
    final primary = _getColor('primary');
    final dark = _getColor('dark');
    final darkBg = _getColor('darkBg');
    final darkSurface = _getColor('darkSurface');

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: dark,
        surface: darkSurface,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dark, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
