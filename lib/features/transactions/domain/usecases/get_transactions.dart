// File: lib/features/transactions/domain/usecases/get_transactions.dart

import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<List<TransactionEntity>> call() => repository.getTransactions();
}