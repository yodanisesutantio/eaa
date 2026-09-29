import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase_client.dart';
import '../models/transaction.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(),
);

final transactionsProvider =
    FutureProvider.autoDispose<List<TransactionRecord>>(
      (ref) => ref.read(transactionsRepositoryProvider).fetchTransactions(),
    );

class TransactionsRepository {
  Future<void> addTransaction(TransactionInput input) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    await supabase.from('transactions').insert(input.toInsertMap(user.id));
    await recordActivity(
      eventType: 'transaction_created',
      entityType: 'transaction',
      metadata: {'currency': input.currency, 'type': input.type},
    );
  }

  Future<void> recordActivity({
    required String eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('activity_logs').insert({
        'user_id': user.id,
        'event_type': eventType,
        'entity_type': entityType,
        'entity_id': entityId,
        'metadata': metadata,
      });
    } catch (_) {
      // Diagnostics must never make a successful transaction look like a failure.
    }
  }

  Future<String?> recordError({
    required String message,
    String? code,
    Map<String, dynamic> details = const {},
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final row = await supabase
          .from('app_errors')
          .insert({
            'user_id': user.id,
            'error_code': code,
            'message': message,
            'details': details,
          })
          .select('id')
          .single();
      return row['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<List<TransactionRecord>> fetchTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final rows = await supabase
        .from('transactions')
        .select('id, type, amount, currency, category, note, occurred_at')
        .eq('user_id', user.id)
        .order('occurred_at', ascending: false)
        .order('created_at', ascending: false);

    return rows
        .map((row) => TransactionRecord.fromMap(row))
        .toList(growable: false);
  }
}

enum TransactionPeriod { day, week, month, yearToDate, allTime }

extension TransactionPeriodLabels on TransactionPeriod {
  String get label => switch (this) {
    TransactionPeriod.day => 'Today',
    TransactionPeriod.week => 'This week',
    TransactionPeriod.month => 'This month',
    TransactionPeriod.yearToDate => 'YTD',
    TransactionPeriod.allTime => 'All time',
  };
}

class TransactionPeriodRange {
  const TransactionPeriodRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    final calendarDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return !calendarDate.isBefore(start) &&
        calendarDate.isBefore(end);
  }

  factory TransactionPeriodRange.forPeriod(
    TransactionPeriod period, {
    DateTime? now,
  }) {
    final localNow = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    );

    final start = switch (period) {
      TransactionPeriod.day => today,

      TransactionPeriod.week => today.subtract(
        Duration(days: today.weekday - 1),
      ),

      TransactionPeriod.month => DateTime(
        today.year,
        today.month,
        1,
      ),

      TransactionPeriod.yearToDate => DateTime(
        today.year,
        1,
        1,
      ),

      TransactionPeriod.allTime => DateTime(1900, 1, 1),
    };

    if (period == TransactionPeriod.allTime) {
      return TransactionPeriodRange(
        start,
        DateTime(9999, 12, 31),
      );
    }

    final end = switch (period) {
      TransactionPeriod.day => start.add(const Duration(days: 1)),

      TransactionPeriod.week => start.add(const Duration(days: 7)),

      TransactionPeriod.month => DateTime(
        start.year,
        start.month + 1,
        1,
      ),

      TransactionPeriod.yearToDate => DateTime(
        start.year + 1,
        1,
        1,
      ),

      TransactionPeriod.allTime => DateTime(9999, 12, 31),
    };

    return TransactionPeriodRange(start, end);
  }

  static Duration _durationUntilNext(TransactionPeriod period, DateTime start) {
    return switch (period) {
      TransactionPeriod.day => const Duration(days: 1),
      TransactionPeriod.week => const Duration(days: 7),
      TransactionPeriod.month => DateTime(
        start.year,
        start.month + 1,
        1,
      ).difference(start),
      TransactionPeriod.yearToDate => DateTime(
        start.year + 1,
      ).difference(start),
      TransactionPeriod.allTime => Duration.zero,
    };
  }
}

class TransactionSummary {
  const TransactionSummary({required this.income, required this.expenses});

  final double income;
  final double expenses;

  double get net => income - expenses;
}

TransactionSummary summarizeTransactions(
  Iterable<TransactionRecord> transactions,
  TransactionPeriodRange range,
) {
  var income = 0.0;
  var expenses = 0.0;
  for (final transaction in transactions) {
    if (!range.contains(transaction.occurredAt)) continue;
    if (transaction.isExpense) {
      expenses += transaction.amount;
    } else {
      income += transaction.amount;
    }
  }
  return TransactionSummary(income: income, expenses: expenses);
}
