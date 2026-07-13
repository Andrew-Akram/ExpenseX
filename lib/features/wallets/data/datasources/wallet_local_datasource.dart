import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';
import '../../domain/entities/wallet.dart';
import '../models/wallet_model.dart';
import '../../../../core/enums/app_enums.dart';

class WalletLocalDataSource {
  static String get _boxName => 'wallets_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<WalletModel> get _box => Hive.box<WalletModel>(_boxName);

  List<Wallet> getAll() {
    if (_box.isEmpty) {
      _box.put('default_wallet', WalletModel(
        id: 'default_wallet',
        name: 'Main Wallet',
        typeString: WalletType.cash.name,
        initialBalance: 0.0,
        currency: 'USD',
        colorValue: 0xFF7B6CF6,
        iconName: 'account_balance_wallet',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
      ));
    }
    return _box.values
        .map((m) => m.toEntity())
        .where((w) => !w.isDeleted)
        .toList();
  }

  Wallet? getById(String id) {
    final m = _box.get(id);
    if (m == null || (m.isDeleted ?? false)) return null;
    return m.toEntity();
  }

  Future<void> save(Wallet wallet) async {
    await _box.put(wallet.id, WalletModel.fromEntity(wallet));
  }

  Future<void> delete(String id) async {
    final m = _box.get(id);
    if (m != null) {
      m.isDeleted = true;
      m.updatedAt = DateTime.now();
      await m.save();
    }
  }

  static Future<void> seedDefaultWalletForUser(String uid) async {
    final box = Hive.box<WalletModel>('wallets_$uid');
    if (box.isNotEmpty) return;
    await box.put('default_wallet', WalletModel(
      id: 'default_wallet',
      name: 'Main Wallet',
      typeString: WalletType.cash.name,
      initialBalance: 0.0,
      currency: 'USD',
      colorValue: 0xFF7B6CF6,
      iconName: 'account_balance_wallet',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
    ));
  }
}
