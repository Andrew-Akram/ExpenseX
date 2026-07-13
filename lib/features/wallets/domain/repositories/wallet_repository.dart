import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getWallets();
  Future<Wallet?> getById(String id);
  Future<void> saveWallet(Wallet wallet);
  Future<void> deleteWallet(String id);
}
