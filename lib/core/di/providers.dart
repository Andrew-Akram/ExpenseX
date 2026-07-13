import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// ── Firestore Datasources ────────────────────────────────────────────────────
import '../../features/categories/data/datasources/category_firestore_datasource.dart';
import '../../features/expenses/data/datasources/expense_firestore_datasource.dart';
import '../../features/wallets/data/datasources/wallet_firestore_datasource.dart';
import '../../features/budget/data/datasources/budget_firestore_datasource.dart';
import '../../features/savings/data/datasources/savings_firestore_datasource.dart';
import '../../features/bills/data/datasources/bill_firestore_datasource.dart';
import '../../features/notifications/data/datasources/notification_firestore_datasource.dart';

// ── Repository Implementations ───────────────────────────────────────────────
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../../features/wallets/domain/repositories/wallet_repository.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/savings/data/repositories/savings_repository_impl.dart';
import '../../features/savings/domain/repositories/savings_repository.dart';
import '../../features/bills/data/repositories/bill_repository_impl.dart';
import '../../features/bills/domain/repositories/bill_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

// ── Auth (still uses local datasource for PIN/biometric) ─────────────────────

final authLocalDsProvider =
    Provider<AuthLocalDataSource>((_) => AuthLocalDataSource());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authLocalDsProvider));
});

// ── Firestore Datasource Providers ───────────────────────────────────────────

final categoryFsDsProvider =
    Provider<CategoryFirestoreDataSource>((_) => CategoryFirestoreDataSource());

final expenseFsDsProvider =
    Provider<ExpenseFirestoreDataSource>((_) => ExpenseFirestoreDataSource());

final walletFsDsProvider =
    Provider<WalletFirestoreDataSource>((_) => WalletFirestoreDataSource());

final budgetFsDsProvider =
    Provider<BudgetFirestoreDataSource>((_) => BudgetFirestoreDataSource());

final savingsFsDsProvider =
    Provider<SavingsFirestoreDataSource>((_) => SavingsFirestoreDataSource());

final billFsDsProvider =
    Provider<BillFirestoreDataSource>((_) => BillFirestoreDataSource());

final notificationFsDsProvider =
    Provider<NotificationFirestoreDataSource>(
        (_) => NotificationFirestoreDataSource());

// ── Repository Providers ─────────────────────────────────────────────────────

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.read(categoryFsDsProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.read(expenseFsDsProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.read(walletFsDsProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.read(budgetFsDsProvider));
});

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepositoryImpl(ref.read(savingsFsDsProvider));
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepositoryImpl(ref.read(billFsDsProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.read(notificationFsDsProvider));
});
