import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme.dart';
import '../../../core/app_settings.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _currency;
  String? _category;
  DateTime _occurredAt = DateTime.now();
  bool _isSaving = false;
  String? _error;

  static const _categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref
          .read(transactionsRepositoryProvider)
          .addTransaction(
            TransactionInput(
              type: _type,
              amount: double.parse(_amountController.text.trim()),
              currency: _currency!,
              category: _category,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
              occurredAt: _occurredAt,
            ),
          );
      if (mounted) context.pop();
    } on PostgrestException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _currency ??= widget.settings.currencyCode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add transaction'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                'Capture a movement',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Keep your cash flow up to date.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              _TypeToggle(
                type: _type,
                onChanged: (type) => setState(() => _type = type),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 132,
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Currency'),
                      items: AppSettings.supportedCurrencies.keys
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _currency = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '${_currencySymbol(_currency!)} ',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter an amount greater than 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(DateFormat('MMMM d, yyyy').format(_occurredAt)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _occurredAt,
    );
    if (picked != null) {
      setState(() => _occurredAt = picked);
    }
  }
}

String _currencySymbol(String code) {
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
    'SEK' => 'kr',
    'NOK' => 'kr',
    'DKK' => 'kr',
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

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});
  final String type;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          _option(context, 'expense', 'Expense', const Color(0xFFB42318)),
          _option(context, 'income', 'Income', const Color(0xFF16794A)),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final selected = value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.surface : null,
            borderRadius: BorderRadius.circular(5),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x12000000), blurRadius: 3)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : AppTheme.mutedForeground,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
