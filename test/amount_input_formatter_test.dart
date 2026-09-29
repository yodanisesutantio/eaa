import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:test_app/core/amount_input_formatter.dart';

void main() {
  const formatter = AmountInputFormatter();

  TextEditingValue format(String value) => formatter.formatEditUpdate(
    const TextEditingValue(),
    TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    ),
  );

  test('adds thousand separators while preserving decimals', () {
    expect(format('1234').text, '1,234');
    expect(format('1234567.89').text, '1,234,567.89');
    expect(format('1234.').text, '1,234.');
  });

  test('parses formatted amounts', () {
    expect(parseAmount('1,234.50'), 1234.5);
    expect(parseAmount(''), isNull);
  });
}
