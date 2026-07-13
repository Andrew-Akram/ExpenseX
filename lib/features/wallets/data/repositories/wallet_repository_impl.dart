import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_firestore_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletFirestoreDataSource _ds;
  WalletRepositoryImpl(this._ds);

  @override
  Future<List<Wallet>> getWallets() => _ds.getAll();

  @override
  Future<Wallet?> getById(String id) => _ds.getById(id);

  @override
  Future<void> saveWallet(Wallet wallet) => _ds.save(wallet);

  @override
  Future<void> deleteWallet(String id) => _ds.delete(id);
}
