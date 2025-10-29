import 'package:quan_ly_chi_tieu/core/data/firebase_remote_data_source.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel?> getWallet(String userId);
  Future<void> createOrUpdateWallet(WalletModel wallet);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseRemoteDS<WalletModel> _remoteSource;

  WalletRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<WalletModel>(
    collectionName: 'wallets',
    fromFirestore: (doc) => WalletModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<WalletModel?> getWallet(String userId) async {
    try {
      return await _remoteSource.getById(userId);
    } catch (e) {
      throw Exception('Failed to fetch wallet: $e');
    }
  }

  @override
  Future<void> createOrUpdateWallet(WalletModel wallet) async {
    try {
      await _remoteSource.update(wallet.userId, wallet);
    } catch (e) {
      throw Exception('Failed to create/update wallet: $e');
    }
  }
}