// File: lib/features/transactions/domain/entities/transaction_entity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String? note;
  final String userId;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    required this.icon,
    required this.color,
    this.note,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, title, category, amount, type, date,
    icon, color, note, userId, createdAt
  ];
}

enum TransactionType { income, expense }