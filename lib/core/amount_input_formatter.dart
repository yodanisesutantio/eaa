import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final beforeCursor = newValue.text.substring(
      0,
      newValue.selection.baseOffset.clamp(0, newValue.text.length),
    );
    final significantCharactersBeforeCursor = _significantCharacters(
      beforeCursor,
    ).length;
    final normalized = newValue.text
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    final decimalIndex = normalized.indexOf('.');
    final hasDecimal = decimalIndex >= 0;
    final integerPart = hasDecimal
        ? normalized.substring(0, decimalIndex)
        : normalized;
    final fractionalPart = hasDecimal
        ? normalized.substring(decimalIndex + 1).replaceAll('.', '')
        : '';
    final digits = integerPart.isEmpty ? '0' : integerPart;
    final groupedInteger = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    final formatted =
        '$groupedInteger'
        '${hasDecimal ? '.$fractionalPart' : ''}';
    final cursor = _cursorForSignificantCharacters(
      formatted,
      significantCharactersBeforeCursor,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  String _significantCharacters(String value) =>
      value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');

  int _cursorForSignificantCharacters(String value, int count) {
    if (count == 0) return 0;
    var seen = 0;
    for (var index = 0; index < value.length; index++) {
      if (value[index] != ',') seen++;
      if (seen == count) return index + 1;
    }
    return value.length;
  }
}

double? parseAmount(String? value) {
  final normalized = value?.replaceAll(',', '').trim() ?? '';
  return double.tryParse(normalized);
}
