import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';
import '../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _periodIndex = 1;
  static const _periods = ['Today', 'This week', 'This month', 'YTD'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) context.go('/auth');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add transaction'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(
              'Good to see you.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Your cash flow',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _PeriodSelector(
              periods: _periods,
              selectedIndex: _periodIndex,
              onChanged: (index) => setState(() => _periodIndex = index),
            ),
            const SizedBox(height: 16),
            const _BalanceCard(),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Income',
                    amount: '\$2,480',
                    icon: Icons.arrow_downward_rounded,
                    accent: Color(0xFF16794A),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Expenses',
                    amount: '\$1,925',
                    icon: Icons.arrow_upward_rounded,
                    accent: Color(0xFFB42318),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionHeader(
              title: 'Recent transactions',
              action: TextButton(
                onPressed: () {},
                child: const Text('View all'),
              ),
            ),
            const _TransactionPreview(
              title: 'Groceries',
              category: 'Food',
              amount: '-\$48.40',
              icon: Icons.shopping_basket_outlined,
              isExpense: true,
            ),
            const _TransactionPreview(
              title: 'Salary',
              category: 'Income',
              amount: '+\$2,480.00',
              icon: Icons.payments_outlined,
              isExpense: false,
            ),
            const _TransactionPreview(
              title: 'Transport',
              category: 'Travel',
              amount: '-\$46.20',
              icon: Icons.directions_car_outlined,
              isExpense: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periods,
    required this.selectedIndex,
    required this.onChanged,
  });
  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          for (var index = 0; index < periods.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: selectedIndex == index
                        ? const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    periods[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selectedIndex == index
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

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
            '\$555.00',
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
                Icons.trending_up_rounded,
                color: Color(0xFF86EFAC),
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                '12.5% from last period',
                style: TextStyle(color: Color(0xFF86EFAC), fontSize: 12),
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
    required this.title,
    required this.category,
    required this.amount,
    required this.icon,
    required this.isExpense,
  });
  final String title;
  final String category;
  final String amount;
  final IconData icon;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final accent = isExpense
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
            child: Icon(icon, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(category, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(color: accent, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
