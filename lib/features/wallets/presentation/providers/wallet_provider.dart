import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../../core/enums/app_enums.dart';

final walletListProvider =
    AsyncNotifierProvider<WalletNotifier, List<Wallet>>(
  WalletNotifier.new,
);

class WalletNotifier extends AsyncNotifier<List<Wallet>> {
  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  @override
  Future<List<Wallet>> build() => _repo.getWallets();

  Future<void> addWallet(Wallet wallet) async {
    await _repo.saveWallet(wallet);
    ref.invalidateSelf();
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _repo.saveWallet(wallet);
    ref.invalidateSelf();
    ref.invalidate(walletBalancesProvider);
  }

  Future<void> deleteWallet(String id) async {
    await _repo.deleteWallet(id);
    ref.invalidateSelf();
    ref.invalidate(walletBalancesProvider);
  }
}

final walletBalancesProvider = FutureProvider<Map<String, double>>((ref) async {
  final wallets = await ref.watch(walletListProvider.future);
  final expenses = await ref.watch(expenseListProvider.future);

  final balances = <String, double>{};

  // Initialize with initial balance
  for (final w in wallets) {
    balances[w.id] = w.initialBalance;
  }

  // Calculate dynamic balances based on transactions
  for (final e in expenses) {
    if (e.isDeleted) continue;

    if (e.type == TransactionType.income) {
      if (balances.containsKey(e.walletId)) {
        balances[e.walletId] = balances[e.walletId]! + e.amount;
      }
    } else if (e.type == TransactionType.expense) {
      if (balances.containsKey(e.walletId)) {
        balances[e.walletId] = balances[e.walletId]! - e.amount;
      }
    } else if (e.type == TransactionType.transfer) {
      // Outgoing from source wallet
      if (balances.containsKey(e.walletId)) {
        balances[e.walletId] = balances[e.walletId]! - e.amount;
      }
      // Incoming to destination wallet
      if (e.toWalletId != null && balances.containsKey(e.toWalletId)) {
        balances[e.toWalletId!] = balances[e.toWalletId]! + e.amount;
      }
    }
  }

  return balances;
});

final totalAssetsProvider = FutureProvider<double>((ref) async {
  final balances = await ref.watch(walletBalancesProvider.future);
  return balances.values.fold<double>(0.0, (sum, bal) => sum + bal);
});
