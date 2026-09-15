import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase_client.dart';
import '../models/transaction.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(),
);

class TransactionsRepository {
  Future<void> addTransaction(TransactionInput input) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    await supabase.from('transactions').insert(input.toInsertMap(user.id));
  }
}
