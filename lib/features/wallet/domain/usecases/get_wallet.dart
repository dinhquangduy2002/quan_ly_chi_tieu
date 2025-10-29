// get_wallet.dart
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWallet {
  final WalletRepository repository;

  GetWallet(this.repository);

  Future<WalletEntity> call() async {
    return await repository.getCurrentUserWallet();
  }
}
