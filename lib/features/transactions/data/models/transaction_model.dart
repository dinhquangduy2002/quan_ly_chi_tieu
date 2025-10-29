// File: lib/features/transactions/data/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.category,
    required super.amount,
    required super.type,
    required super.date,
    required super.icon,
    required super.color,
    super.note,
    required super.userId,
    required super.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: _parseTimestamp(data['date']), // SỬA 'data' THÀNH 'date'
      icon: IconData(data['icon_code'] ?? Icons.receipt.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(data['color_value'] ?? Colors.purple.value),
      note: data['note'],
      userId: data['user_id'] ?? '', // ĐẢM BẢO CÓ USER_ID
      createdAt: _parseTimestamp(data['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'amount': amount,
    'type': type == TransactionType.income ? 'income' : 'expense',
    'date': Timestamp.fromDate(date), // SỬA 'data' THÀNH 'date'
    'icon_code': icon.codePoint,
    'color_value': color.value,
    'note': note ?? '',
    'user_id': userId, // ĐẢM BẢO LƯU USER_ID
    'created_at': Timestamp.fromDate(createdAt),
  };

  factory TransactionModel.fromEntity(TransactionEntity entity) => TransactionModel(
    id: entity.id,
    title: entity.title,
    category: entity.category,
    amount: entity.amount,
    type: entity.type,
    date: entity.date,
    icon: entity.icon,
    color: entity.color,
    note: entity.note,
    userId: entity.userId,
    createdAt: entity.createdAt,
  );

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      title: title,
      category: category,
      amount: amount,
      type: type,
      date: date,
      icon: icon,
      color: color,
      note: note,
      userId: userId,
      createdAt: createdAt,
    );
  }
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    return DateTime.now();
  }
}