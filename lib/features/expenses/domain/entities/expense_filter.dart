import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/app_enums.dart';

part 'expense_filter.freezed.dart';

enum SortOrder { dateDesc, dateAsc, amountDesc, amountAsc, category }

@freezed
sealed class ExpenseFilter with _$ExpenseFilter {
  const factory ExpenseFilter({
    // ── Text search (title, note, tags, merchant) ──────────────────────────
    String? searchQuery,
    // ── Category & wallet ─────────────────────────────────────────────────
    String? categoryId,
    String? walletId,
    // ── Transaction type ──────────────────────────────────────────────────
    TransactionType? type,
    // ── Date range ────────────────────────────────────────────────────────
    DateTime? dateFrom,
    DateTime? dateTo,
    // ── Amount range ──────────────────────────────────────────────────────
    double? amountMin,
    double? amountMax,
    // ── Receipt filter ────────────────────────────────────────────────────
    bool? hasReceipt,
    // ── Sort order ────────────────────────────────────────────────────────
    @Default(SortOrder.dateDesc) SortOrder sortOrder,
  }) = _ExpenseFilter;
}
