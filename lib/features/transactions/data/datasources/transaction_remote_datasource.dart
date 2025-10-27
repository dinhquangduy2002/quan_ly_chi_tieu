// File: lib/features/transactions/data/datasources/transaction_remote_datasource.dart

import 'package:quan_ly_chi_tieu/core/data/firebase_remote_data_source.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<List<TransactionModel>> getTransactionsByType(String type);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> watchTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseRemoteDS<TransactionModel> _remoteSource;

  TransactionRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<TransactionModel>(
    collectionName: 'transactions',
    fromFirestore: (doc) => TransactionModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      return await _remoteSource.getAll();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final allTransactions = await _remoteSource.getAll();
      return allTransactions.where((transaction) =>
      transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)))
      ).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions by date range: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final allTransactions = await _remoteSource.getAll();
      return allTransactions.where((transaction) =>
      transaction.type.toString() == 'TransactionType.$type'
      ).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions by type: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final id = await _remoteSource.add(transaction);
      return transaction;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      await _remoteSource.update(transaction.id, transaction);
      return transaction;
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _remoteSource.delete(id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    try {
      return _remoteSource.watchAll();
    } catch (e) {
      throw Exception('Failed to watch transactions: $e');
    }
  }
}