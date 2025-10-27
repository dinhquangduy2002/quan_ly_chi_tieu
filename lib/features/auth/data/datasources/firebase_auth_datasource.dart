// File: lib/features/auth/data/datasources/firebase_auth_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';  // Firebase Auth package
import '../../domain/entities/user_entity.dart';    // Import domain entity

// Data source - lớp kết nối trực tiếp với Firebase Auth
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;  // Instance của Firebase Auth

  // Constructor nhận FirebaseAuth (có thể inject cho testing)
  FirebaseAuthDataSource(this._firebaseAuth);

  // Đăng nhập với email và password
  Future<UserEntity?> signIn(String email, String password) async {
    // Gọi Firebase Auth để đăng nhập
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Convert Firebase User sang UserEntity của domain
    return _userFromFirebase(cred.user);
  }

  // Đăng ký user mới
  Future<UserEntity?> signUp(String email, String password) async {
    // Gọi Firebase Auth để tạo user mới
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Convert Firebase User sang UserEntity
    return _userFromFirebase(cred.user);
  }

  // Đăng xuất user
  Future<void> signOut() async => _firebaseAuth.signOut();

  // Stream theo dõi trạng thái authentication
  Stream<UserEntity?> get user =>
      _firebaseAuth.authStateChanges().map(_userFromFirebase);

  // Helper method: convert Firebase User sang UserEntity
  UserEntity? _userFromFirebase(User? user) {
    if (user == null) return null;  // Trả về null nếu không có user
    return UserEntity(uid: user.uid, email: user.email);
  }
}