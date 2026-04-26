import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  String _currentLanguage = "fr";

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String langCode) {
    _currentLanguage = langCode;
    notifyListeners();
  }

  Locale get locale => Locale(_currentLanguage);
}