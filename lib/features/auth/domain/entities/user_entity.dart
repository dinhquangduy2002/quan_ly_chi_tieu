// File: lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';  // Package để so sánh object dễ dàng

// Entity đại diện cho User trong domain layer (business logic)
class UserEntity extends Equatable {
  final String uid;     // User ID từ Firebase
  final String? email;  // Email user (có thể null)

  const UserEntity({required this.uid, this.email});

  // Override props để Equatable so sánh 2 UserEntity
  @override
  List<Object?> get props => [uid, email];
}