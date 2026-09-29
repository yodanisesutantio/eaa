import 'package:intl/intl.dart';

String currencySymbol(String code) {
  return switch (code) {
    'EUR' => '€',
    'GBP' => '£',
    'JPY' => '¥',
    'CAD' => 'CA\$',
    'AUD' => 'A\$',
    'CHF' => 'CHF',
    'CNY' => '¥',
    'HKD' => 'HK\$',
    'NZD' => 'NZ\$',
    'SGD' => 'S\$',
    'INR' => '₹',
    'KRW' => '₩',
    'IDR' => 'Rp',
    'BRL' => 'R\$',
    'MXN' => 'MX\$',
    'ZAR' => 'R',
    'SEK' || 'NOK' || 'DKK' => 'kr',
    'PLN' => 'zł',
    'CZK' => 'Kč',
    'HUF' => 'Ft',
    'TRY' => '₺',
    'AED' => 'د.إ',
    'SAR' => '﷼',
    'THB' => '฿',
    'MYR' => 'RM',
    'PHP' => '₱',
    'VND' => '₫',
    _ => '\$',
  };
}

String formatCurrency(double amount, String code) {
  return NumberFormat.currency(
    name: code,
    symbol: currencySymbol(code),
    decimalDigits: code == 'JPY' || code == 'KRW' ? 0 : 2,
  ).format(amount);
}
