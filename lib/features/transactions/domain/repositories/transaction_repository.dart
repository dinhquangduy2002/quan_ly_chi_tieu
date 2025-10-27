// File: lib/features/transactions/domain/repositories/transaction_repository.dart

import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<List<TransactionEntity>> getTransactionsByType(String type);
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionEntity>> watchTransactions();
}