// File: lib/features/auth/domain/repositories/auth_repository.dart

import '../entities/user_entity.dart';  // Import entity

// Abstract class - định nghĩa contract cho auth repository
abstract class AuthRepository {
  // Đăng nhập với email và password, trả về UserEntity hoặc null
  Future<UserEntity?> signIn(String email, String password);

  // Đăng ký user mới, trả về UserEntity hoặc null
  Future<UserEntity?> signUp(String email, String password);

  // Đăng xuất user
  Future<void> signOut();

  // Stream theo dõi trạng thái user (để biết user login/logout)
  Stream<UserEntity?> get user;
}