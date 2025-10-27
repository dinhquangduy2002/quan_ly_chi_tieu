// File: lib/features/transactions/domain/usecases/update_transaction.dart

import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<TransactionEntity> call(TransactionEntity transaction) => repository.updateTransaction(transaction);
}