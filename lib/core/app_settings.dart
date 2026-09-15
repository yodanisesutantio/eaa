import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._preferences);

  static const supportedLanguages = {
    'en': 'English',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'Deutsch',
    'ko': 'Korean',
    'id': 'Indonesian',
  };

  static const supportedCurrencies = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'CAD': 'Canadian Dollar',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'HKD': 'Hong Kong Dollar',
    'NZD': 'New Zealand Dollar',
    'SGD': 'Singapore Dollar',
    'INR': 'Indian Rupee',
    'KRW': 'South Korean Won',
    'IDR': 'Indonesian Rupiah',
    'BRL': 'Brazilian Real',
    'MXN': 'Mexican Peso',
    'ZAR': 'South African Rand',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'DKK': 'Danish Krone',
    'PLN': 'Polish Zloty',
    'CZK': 'Czech Koruna',
    'HUF': 'Hungarian Forint',
    'TRY': 'Turkish Lira',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'THB': 'Thai Baht',
    'MYR': 'Malaysian Ringgit',
    'PHP': 'Philippine Peso',
    'VND': 'Vietnamese Dong',
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
