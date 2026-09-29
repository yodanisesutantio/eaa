import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/app_settings.dart';
import '../../core/currency_format.dart';
import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../transactions/models/transaction.dart';
import '../transactions/providers/exchange_rates_provider.dart';
import '../transactions/providers/transactions_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _periodIndex = 1;
  late String _displayCurrency;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _displayCurrency = widget.settings.displayCurrencyCode;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final rates = ref.watch(exchangeRatesProvider('USD'));
    final period = TransactionPeriod.values[_periodIndex];
    final range = _customRange == null
        ? TransactionPeriodRange.forPeriod(period)
        : TransactionPeriodRange(
            _customRange!.start,
            _customRange!.end.add(const Duration(days: 1)),
          );

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        title: const Text('Overview'),
      ),
      drawer: const _AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add transaction'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTransactions,
          child: transactions.when(
            loading: () => const _DashboardLoading(),
            error: (error, _) => _DashboardMessage(
              message: 'Could not load transactions.\n$error',
              onRetry: () => ref.invalidate(transactionsProvider),
            ),
            data: (items) => _DashboardContent(
              items: items,
              range: range,
              rates: rates.asData?.value,
              displayCurrency: _displayCurrency,
              selectedIndex: _periodIndex,
              onPeriodChanged: (index) => setState(() {
                _periodIndex = index;
                _customRange = null;
              }),
              customRange: _customRange,
              onCustomRangeChanged: (range) => setState(() {
                _customRange = range;
              }),
              onDisplayCurrencyChanged: (code) {
                setState(() => _displayCurrency = code);
                widget.settings.setDisplayCurrency(code);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshTransactions() async {
    ref.invalidate(transactionsProvider);
    await ref.read(transactionsProvider.future);
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: const [
      SizedBox(height: 320, child: Center(child: CircularProgressIndicator())),
    ],
  );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.items,
    required this.range,
    required this.rates,
    required this.displayCurrency,
    required this.selectedIndex,
    required this.onPeriodChanged,
    required this.onDisplayCurrencyChanged,
    required this.customRange,
    required this.onCustomRangeChanged,
  });

  final List<TransactionRecord> items;
  final TransactionPeriodRange range;
  final ExchangeRateSnapshot? rates;
  final String displayCurrency;
  final int selectedIndex;
  final ValueChanged<int> onPeriodChanged;
  final ValueChanged<String> onDisplayCurrencyChanged;
  final DateTimeRange? customRange;
  final ValueChanged<DateTimeRange> onCustomRangeChanged;

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) => range.contains(item.occurredAt));
    final visible = filtered.toList(growable: false);
    final summary = displayCurrency == originalCurrency
        ? null
        : _convertedSummary(visible);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text('Good to see you.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          'Your cash flow',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PeriodDropdown(
                selectedIndex: selectedIndex,
                hasCustomRange: customRange != null,
                onPresetChanged: onPeriodChanged,
                onCustomRangeChanged: onCustomRangeChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 86,
              child: _DisplayCurrencyDropdown(
                value: displayCurrency,
                onChanged: onDisplayCurrencyChanged,
              ),
            ),
          ],
        ),
        if (customRange != null) ...[
          const SizedBox(height: 8),
          _CustomRangeButton(
            range: customRange,
            onChanged: onCustomRangeChanged,
          ),
        ],
        const SizedBox(height: 20),
        _BalanceCard(
          amount: summary == null
              ? displayCurrency == originalCurrency
                    ? 'Original'
                    : '—'
              : formatCurrency(summary.net, displayCurrency),
          currency: displayCurrency,
          isPositive: summary == null ? null : summary.net >= 0,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Income',
                amount: summary == null
                    ? displayCurrency == originalCurrency
                          ? 'Original'
                          : '—'
                    : formatCurrency(summary.income, displayCurrency),
                icon: Icons.arrow_downward_rounded,
                accent: const Color(0xFF16794A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Expenses',
                amount: summary == null
                    ? displayCurrency == originalCurrency
                          ? 'Original'
                          : '—'
                    : formatCurrency(summary.expenses, displayCurrency),
                icon: Icons.arrow_upward_rounded,
                accent: const Color(0xFFB42318),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionHeader(
          title: 'Transactions',
          action: Text(
            '${visible.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No transactions in this period.')),
          )
        else
          for (var index = 0; index < visible.length; index++) ...[
            if (index == 0 ||
                !_sameDate(
                  visible[index - 1].occurredAt,
                  visible[index].occurredAt,
                ))
              _DateHeader(date: visible[index].occurredAt),
            _TransactionPreview(
              transaction: visible[index],
              convertedAmount: rates?.convert(
                visible[index].amount,
                visible[index].currency,
                displayCurrency,
              ),
              displayCurrency: displayCurrency,
            ),
          ],
      ],
    );
  }

  TransactionSummary? _convertedSummary(List<TransactionRecord> visible) {
    if (rates == null) return null;
    var income = 0.0;
    var expenses = 0.0;
    for (final transaction in visible) {
      final amount = rates!.convert(
        transaction.amount,
        transaction.currency,
        displayCurrency,
      );
      if (amount == null) return null;
      if (transaction.isExpense) {
        expenses += amount;
      } else {
        income += amount;
      }
    }
    return TransactionSummary(income: income, expenses: expenses);
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(
        height: 320,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final email = user?.email ?? 'Account';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'A';

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) => _handleProfileAction(context, value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'profile', child: Text('Profile')),
                  PopupMenuItem(value: 'settings', child: Text('Settings')),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'signout', child: Text('Sign out')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Text(
                          initial,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _DrawerLabel(label: 'Menu'),
              _DrawerItem(
                icon: Icons.dashboard_outlined,
                label: 'Overview',
                selected: true,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 24),
              _DrawerLabel(label: 'More'),
              _DrawerItem(
                icon: Icons.info_outline_rounded,
                label: 'About',
                onTap: () => _showComingSoon(context, 'About'),
              ),
              _DrawerItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Feedback',
                onTap: () => _showComingSoon(context, 'Help & Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleProfileAction(BuildContext context, String value) {
    switch (value) {
      case 'settings':
        Navigator.of(context).pop();
        context.push('/settings');
      case 'profile':
        _showComingSoon(context, 'Profile');
      case 'signout':
        _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    Navigator.of(context).pop();
    await supabase.auth.signOut();
    if (context.mounted) context.go('/auth');
  }

  void _showComingSoon(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label is coming soon.')));
  }
}

class _DrawerLabel extends StatelessWidget {
  const _DrawerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      selected: selected,
      selectedTileColor: colors.surfaceContainerHighest,
      leading: Icon(icon, size: 19),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selectedIndex,
    required this.hasCustomRange,
    required this.onPresetChanged,
    required this.onCustomRangeChanged,
  });

  final int selectedIndex;
  final bool hasCustomRange;
  final ValueChanged<int> onPresetChanged;
  final ValueChanged<DateTimeRange> onCustomRangeChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: hasCustomRange
        ? 'Custom'
        : TransactionPeriod.values[selectedIndex].label,
    decoration: const InputDecoration(labelText: 'Period'),
    items: [
      ...TransactionPeriod.values.map(
        (period) =>
            DropdownMenuItem(value: period.label, child: Text(period.label)),
      ),
      const DropdownMenuItem(value: 'Custom', child: Text('Custom')),
    ],
    onChanged: (value) async {
      if (value == null) return;
      if (value == 'Custom') {
        final selected = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selected != null) onCustomRangeChanged(selected);
        return;
      }
      final index = TransactionPeriod.values
          .map((period) => period.label)
          .toList()
          .indexOf(value);
      if (index >= 0) onPresetChanged(index);
    },
  );
}

class _CustomRangeButton extends StatelessWidget {
  const _CustomRangeButton({required this.range, required this.onChanged});

  final DateTimeRange? range;
  final ValueChanged<DateTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = range == null
        ? 'Choose dates'
        : '${DateFormat('dd/MM/yyyy').format(range!.start)} > '
              '${DateFormat('dd/MM/yyyy').format(range!.end)}';
    return Align(
      alignment: Alignment.center,
      child: OutlinedButton.icon(
        onPressed: () async {
          final selected = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            initialDateRange: range,
          );
          if (selected != null) onChanged(selected);
        },
        icon: const Icon(Icons.date_range_outlined, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.amount,
    required this.currency,
    required this.isPositive,
  });

  final String amount;
  final String currency;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net balance',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isPositive == null
                    ? Icons.remove_rounded
                    : isPositive!
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isPositive == null
                    ? Theme.of(context).colorScheme.onInverseSurface
                    : isPositive!
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                isPositive == null ? 'Original currencies' : currency,
                style: TextStyle(
                  color: isPositive == null
                      ? Theme.of(context).colorScheme.onInverseSurface
                      : isPositive!
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFCA5A5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accent,
  });
  final String label;
  final String amount;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      action,
    ],
  );
}

class _TransactionPreview extends StatelessWidget {
  const _TransactionPreview({
    required this.transaction,
    required this.convertedAmount,
    required this.displayCurrency,
  });
  final TransactionRecord transaction;
  final double? convertedAmount;
  final String displayCurrency;

  @override
  Widget build(BuildContext context) {
    final accent = transaction.isExpense
        ? const Color(0xFFB42318)
        : const Color(0xFF16794A);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: Icon(
              transaction.isExpense
                  ? Icons.receipt_long_outlined
                  : Icons.payments_outlined,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note?.isNotEmpty == true
                      ? transaction.note!
                      : transaction.category ?? 'Transaction',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.category ?? 'Uncategorized'} · ${transaction.occurredAt.month}/${transaction.occurredAt.day}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isExpense ? '-' : '+'}${formatCurrency(transaction.amount, transaction.currency)}',
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
              if (convertedAmount != null &&
                  displayCurrency != originalCurrency &&
                  transaction.currency != displayCurrency)
                Text(
                  '${transaction.isExpense ? '-' : '+'}${formatCurrency(convertedAmount!, displayCurrency)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

const originalCurrency = 'ORIGINAL';

class _DisplayCurrencyDropdown extends StatelessWidget {
  const _DisplayCurrencyDropdown({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
    value: value,
    underline: const SizedBox.shrink(),
    isDense: true,
    items: [
      const DropdownMenuItem(value: originalCurrency, child: Text('Original')),
      ...AppSettings.supportedCurrencies.keys.map(
        (code) => DropdownMenuItem(value: code, child: Text(code)),
      ),
    ],
    onChanged: (code) {
      if (code != null) onChanged(code);
    },
  );
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(
      DateFormat('EEEE, MMM d').format(date),
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

bool _sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
