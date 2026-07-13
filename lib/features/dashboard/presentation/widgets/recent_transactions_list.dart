import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../providers/dashboard_provider.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentRaw = ref.watch(recentExpensesProvider);
    final recent = recentRaw.cast<Expense>();
    final cats = ref.watch(categoryListProvider);

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
              const Gap(12),
              Text(
                ref.tr('noExpenses'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      );
    }

    final catMap = cats.maybeWhen(
      data: (list) => {for (final c in list) c.id: c},
      orElse: () => <String, dynamic>{},
    );

    return Column(
      children: recent.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final cat = catMap[e.categoryId];

        final (catColor, catIcon, useImage) = _resolveTransaction(e, cat);
        final catName = cat?.name ?? e.categoryId;

        return _TransactionCard(
          expense: e,
          catColor: catColor,
          catIcon: catIcon,
          catName: catName,
          index: i,
        );
      }).toList(),
    );
  }

  (Color, IconData, bool) _resolveTransaction(Expense e, dynamic cat) {
    final title = e.title.toLowerCase();

    if (title.contains('spotify')) {
      return (const Color(0xFF1DB954), Icons.music_note_rounded, false);
    }
    if (title.contains('copay') || title.contains('health')) {
      return (const Color(0xFF00A4CC), Icons.local_hospital_rounded, false);
    }
    if (title.contains('ui8') || title.contains('design')) {
      return (const Color(0xFF1A1A2E), Icons.design_services_rounded, false);
    }
    if (title.contains('freepik') || title.contains('stock')) {
      return (const Color(0xFF3BACB6), Icons.image_rounded, false);
    }
    if (title.contains('netflix')) {
      return (const Color(0xFFE50914), Icons.movie_rounded, false);
    }
    if (title.contains('uber') || title.contains('lyft')) {
      return (const Color(0xFF000000), Icons.local_taxi_rounded, false);
    }

    final catColor = cat != null ? Color(cat.colorValue) : AppColors.catOther;
    final catIcon = cat != null
        ? CategoryConstants.iconFromKey(cat.iconName)
        : Icons.category_rounded;
    return (catColor, catIcon, false);
  }
}

class _TransactionCard extends StatelessWidget {
  final Expense expense;
  final Color catColor;
  final IconData catIcon;
  final String catName;
  final int index;

  const _TransactionCard({
    required this.expense,
    required this.catColor,
    required this.catIcon,
    required this.catName,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    final dateLabel = DateFormat('d MMMM yyyy').format(expense.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        child: InkWell(
          onTap: () => context.push('/expenses/${expense.id}', extra: expense),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isDark
                  ? null
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Category circle icon ────────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 22),
                ),
                const Gap(14),

                // ── Title + date ────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF14102B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(3),
                      Text(
                        dateLabel,
                        style: text.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Amount + chevron ────────────────────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expense.type == TransactionType.income
                          ? '+${expense.amount.asCurrency}'
                          : expense.type == TransactionType.transfer
                              ? expense.amount.asCurrency
                              : '-${expense.amount.asCurrency}',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: expense.type == TransactionType.income
                            ? AppColors.success
                            : expense.type == TransactionType.transfer
                                ? AppColors.primary
                                : AppColors.error,
                      ),
                    ),
                    const Gap(6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: (index * 60).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.08, curve: Curves.easeOut),
    );
  }
}