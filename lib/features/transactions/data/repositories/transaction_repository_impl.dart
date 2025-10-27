// File: lib/features/transactions/data/repositories/transaction_repository_impl.dart

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl() : remoteDataSource = TransactionRemoteDataSourceImpl();

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    try {
      final transactions = await remoteDataSource.getTransactions();
      return transactions.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to fetch transactions - $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByDateRange(start, end);
      return transactions.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to fetch transactions by date range - $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByType(String type) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByType(type);
      return transactions.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to fetch transactions by type - $e');
    }
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final createdTransaction = await remoteDataSource.createTransaction(transactionModel);
      return createdTransaction.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to create transaction - $e');
    }
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final updatedTransaction = await remoteDataSource.updateTransaction(transactionModel);
      return updatedTransaction.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to update transaction - $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
    } catch (e) {
      throw Exception('Repository: Failed to delete transaction - $e');
    }
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    try {
      return remoteDataSource.watchTransactions().map(
              (models) => models.map((model) => model.toEntity()).toList()
      );
    } catch (e) {
      throw Exception('Repository: Failed to watch transactions - $e');
    }
  }
}