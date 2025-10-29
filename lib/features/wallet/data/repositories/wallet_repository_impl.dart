import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../data/wallet_remote_data_source.dart';
import '../models/wallet_model.dart';
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final FirebaseAuth auth;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.auth,
  });

  @override
  Future<WalletEntity> getCurrentUserWallet() async {
    final userId = _getCurrentUserId();
    final walletModel = await remoteDataSource.getWallet(userId);

    // Nếu chưa có ví → tạo ví mặc định
    if (walletModel == null) {
      final defaultWallet = WalletEntity.defaultWallet(userId);
      await createDefaultWallet(userId);
      return defaultWallet;
    }

    return walletModel.toEntity();
  }

  @override
  Future<void> updateWallet(WalletEntity wallet) async {
    final walletModel = WalletModel.fromEntity(wallet);
    await remoteDataSource.createOrUpdateWallet(walletModel);
  }

  @override
  Future<void> createDefaultWallet(String userId) async {
    final defaultWallet = WalletEntity.defaultWallet(userId);
    final walletModel = WalletModel.fromEntity(defaultWallet);
    await remoteDataSource.createOrUpdateWallet(walletModel);
  }

  String _getCurrentUserId() {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }
}