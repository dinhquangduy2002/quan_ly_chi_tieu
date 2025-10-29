// wallet_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/wallet_entity.dart';

class WalletModel {
  final String id;
  final String userId;
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double availableBalance;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.availableBalance,
    required this.updatedAt,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] ?? 'main',
      userId: map['userId'],
      totalBalance: (map['totalBalance'] ?? 0).toDouble(),
      monthlyIncome: (map['monthlyIncome'] ?? 0).toDouble(),
      monthlyExpense: (map['monthlyExpense'] ?? 0).toDouble(),
      availableBalance: (map['availableBalance'] ?? 0).toDouble(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalBalance': totalBalance,
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'availableBalance': availableBalance,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      userId: entity.userId,
      totalBalance: entity.totalBalance,
      monthlyIncome: entity.monthlyIncome,
      monthlyExpense: entity.monthlyExpense,
      availableBalance: entity.availableBalance,
      updatedAt: entity.updatedAt,
    );
  }

  WalletEntity toEntity() {
    return WalletEntity(
      id: id,
      userId: userId,
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      availableBalance: availableBalance,
      updatedAt: updatedAt,
    );
  }
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      id: data['id'] ?? 'main',
      userId: data['userId'],
      totalBalance: (data['totalBalance'] ?? 0).toDouble(),
      monthlyIncome: (data['monthlyIncome'] ?? 0).toDouble(),
      monthlyExpense: (data['monthlyExpense'] ?? 0).toDouble(),
      availableBalance: (data['availableBalance'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalBalance': totalBalance,
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'availableBalance': availableBalance,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}