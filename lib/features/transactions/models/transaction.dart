class TransactionInput {
  const TransactionInput({
    required this.type,
    required this.amount,
    required this.currency,
    required this.category,
    required this.note,
    required this.occurredAt,
  });

  final String type;
  final double amount;
  final String currency;
  final String? category;
  final String? note;
  final DateTime occurredAt;

  Map<String, dynamic> toInsertMap(String userId) {
    final date = occurredAt.toLocal();

    return {
      'user_id': userId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'category': category,
      'note': note,
      'occurred_at':
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
    };
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.category,
    required this.note,
    required this.occurredAt,
  });

  final String id;
  final String type;
  final double amount;
  final String currency;
  final String? category;
  final String? note;
  final DateTime occurredAt;

  bool get isExpense => type == 'expense';

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['occurred_at'] as String);

    return TransactionRecord(
      id: map['id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      category: map['category'] as String?,
      note: map['note'] as String?,
      occurredAt: DateTime(
        date.year,
        date.month,
        date.day,
      ),
    );
  }
}
