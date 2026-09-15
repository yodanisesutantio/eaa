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
    return {
      'user_id': userId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'category': category,
      'note': note,
      'occurred_at': occurredAt.toIso8601String().split('T').first,
    };
  }
}
