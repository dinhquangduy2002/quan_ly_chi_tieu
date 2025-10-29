// update_wallet.dart
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class UpdateWallet {
  final WalletRepository repository;

  UpdateWallet(this.repository);

  Future<void> call(WalletEntity wallet) async {
    await repository.updateWallet(wallet);
  }
}