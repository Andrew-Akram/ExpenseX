import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/expense_filter.dart';

final expenseFilterProvider =
    NotifierProvider<ExpenseFilterNotifier, ExpenseFilter>(
  () => ExpenseFilterNotifier(),
);

class ExpenseFilterNotifier extends Notifier<ExpenseFilter> {
  @override
  ExpenseFilter build() => const ExpenseFilter();

  void setSearch(String query) =>
      state = state.copyWith(searchQuery: query.isEmpty ? null : query);

  void setCategory(String? id) =>
      state = state.copyWith(categoryId: id);

  void setWallet(String? id) =>
      state = state.copyWith(walletId: id);

  void setType(TransactionType? type) =>
      state = state.copyWith(type: type);

  void setDateRange(DateTime? from, DateTime? to) =>
      state = state.copyWith(dateFrom: from, dateTo: to);

  void setSortOrder(SortOrder order) =>
      state = state.copyWith(sortOrder: order);

  void setAmountRange(double? min, double? max) =>
      state = state.copyWith(amountMin: min, amountMax: max);

  void setHasReceipt(bool? hasReceipt) =>
      state = state.copyWith(hasReceipt: hasReceipt);

  void clearFilters() => state = const ExpenseFilter();
}
