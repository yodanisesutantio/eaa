import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final exchangeRatesProvider = FutureProvider.autoDispose
    .family<ExchangeRateSnapshot, String>(
      (ref, base) => ExchangeRateService().loadRates(base),
    );

class ExchangeRateSnapshot {
  const ExchangeRateSnapshot({
    required this.base,
    required this.rates,
    required this.fetchedAt,
    required this.isStale,
  });

  final String base;
  final Map<String, double> rates;
  final DateTime fetchedAt;
  final bool isStale;

  double? convert(double amount, String from, String to) {
    if (from == to) return amount;
    final fromRate = rates[from];
    final toRate = rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return null;
    return amount / fromRate * toRate;
  }
}

class ExchangeRateService {
  static const _maxAge = Duration(hours: 24);

  Future<ExchangeRateSnapshot> loadRates(String base) async {
    final preferences = await SharedPreferences.getInstance();
    final cacheKey = 'exchange_rates_$base';
    final fetchedAtKey = 'exchange_rates_${base}_fetched_at';
    final cached = _readCache(preferences, base, cacheKey, fetchedAtKey);
    final isFresh =
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) <= _maxAge;
    if (isFresh) return cached;

    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/$base'),
      );
      if (response.statusCode != 200) throw StateError('Rate service failed.');
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final rawRates = payload['rates'] as Map<String, dynamic>?;
      if (rawRates == null) throw StateError('Rate service returned no rates.');
      final rates = <String, double>{
        for (final entry in rawRates.entries)
          if (entry.value is num) entry.key: (entry.value as num).toDouble(),
      };
      final fetchedAt = DateTime.now();
      await preferences.setString(cacheKey, jsonEncode(rates));
      await preferences.setInt(fetchedAtKey, fetchedAt.millisecondsSinceEpoch);
      return ExchangeRateSnapshot(
        base: base,
        rates: rates,
        fetchedAt: fetchedAt,
        isStale: false,
      );
    } catch (_) {
      if (cached != null) {
        return ExchangeRateSnapshot(
          base: base,
          rates: cached.rates,
          fetchedAt: cached.fetchedAt,
          isStale: true,
        );
      }
      return ExchangeRateSnapshot(
        base: base,
        rates: {base: 1},
        fetchedAt: DateTime.now(),
        isStale: true,
      );
    }
  }

  ExchangeRateSnapshot? _readCache(
    SharedPreferences preferences,
    String base,
    String cacheKey,
    String fetchedAtKey,
  ) {
    final encoded = preferences.getString(cacheKey);
    final timestamp = preferences.getInt(fetchedAtKey);
    if (encoded == null || timestamp == null) return null;
    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return ExchangeRateSnapshot(
        base: base,
        rates: {
          for (final entry in decoded.entries)
            if (entry.value is num) entry.key: (entry.value as num).toDouble(),
        },
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
        isStale: false,
      );
    } catch (_) {
      return null;
    }
  }
}
