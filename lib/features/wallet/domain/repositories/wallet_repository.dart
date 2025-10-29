import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getCurrentUserWallet();
  Future<void> updateWallet(WalletEntity wallet);
  Future<void> createDefaultWallet(String userId);
}