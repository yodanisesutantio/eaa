import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._preferences);

  static const supportedLanguages = {
    'en': 'English',
    'fr': 'French',
    'es': 'Spanish',
  };

  static const supportedCurrencies = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'CAD': 'Canadian Dollar',
    'JPY': 'Japanese Yen',
  };

  static const supportedAppearances = {'light': 'Light', 'dark': 'Dark'};

  final SharedPreferences _preferences;

  String get languageCode => _preferences.getString('language_code') ?? 'en';
  String get currencyCode => _preferences.getString('currency_code') ?? 'USD';
  String get appearance => _preferences.getString('appearance') ?? 'light';

  static Future<AppSettings> load() async {
    return AppSettings._(await SharedPreferences.getInstance());
  }

  Future<void> setLanguage(String code) async {
    await _preferences.setString('language_code', code);
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    await _preferences.setString('currency_code', code);
    notifyListeners();
  }

  Future<void> setAppearance(String value) async {
    await _preferences.setString('appearance', value);
    notifyListeners();
  }
}
