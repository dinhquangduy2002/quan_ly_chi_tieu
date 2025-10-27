// File: lib/features/transactions/domain/usecases/create_transaction.dart

import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<TransactionEntity> call(TransactionEntity transaction) => repository.createTransaction(transaction);
}