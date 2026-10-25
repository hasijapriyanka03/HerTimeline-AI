import 'package:flutter/material.dart';
import '../localization/app_strings.dart';

class LocalizationProvider extends ChangeNotifier {
  String _language = 'en';

  String get language => _language;

  LocalizationProvider(String initialLanguage) {
    _language = initialLanguage;
  }

  void setLanguage(String lang) {
    if (lang != _language) {
      _language = lang;
      notifyListeners();
    }
  }

  String getString(String key) {
    return AppStrings.get(key, _language);
  }

  // Helper method for easy access
  String t(String key) => getString(key);
}
