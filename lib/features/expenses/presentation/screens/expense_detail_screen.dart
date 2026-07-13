import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final Expense? expense;
  const ExpenseDetailScreen({super.key, this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String t(String key) => ref.tr(key);

    if (expense == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        body: Center(child: Text(t('expenseNotFound'))),
      );
    }

    final e = expense!;
    final cats = ref.watch(categoryListProvider);
    final cat = cats.maybeWhen(
      data: (list) => list.where((c) => c.id == e.categoryId).firstOrNull,
      orElse: () => null,
    );
    final catColor = cat != null ? Color(cat.colorValue) : AppColors.catOther;
    final catIcon = cat != null
        ? CategoryConstants.iconFromKey(cat.iconName)
        : Icons.category_rounded;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    isDark: isDark,
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      t('expenseDetail'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                      ),
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.delete_outline_rounded,
                    isDark: isDark,
                    iconColor: AppColors.error,
                    onTap: () => _confirmDelete(context, ref, e),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Gap(8),

                  // ── Amount hero card ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [catColor, catColor.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: catColor.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(catIcon, color: Colors.white, size: 28),
                        ),
                        const Gap(18),
                        Text(
                          e.type == TransactionType.income
                              ? '+${e.amount.asCurrency}'
                              : e.type == TransactionType.transfer
                                  ? e.amount.asCurrency
                                  : '-${e.amount.asCurrency}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          e.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),

                  const Gap(28),

                  // ── Details card ────────────────────────────────────
                  _DetailsCard(
                    isDark: isDark,
                    children: [
                      _DetailRow(
                        icon: Icons.category_rounded,
                        label: t('category'),
                        value: cat?.name ?? e.categoryId,
                        iconColor: catColor,
                        isDark: isDark,
                      ),
                      _DetailDivider(isDark: isDark),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: t('date'),
                        value: AppDateUtils.formatFull(e.date),
                        iconColor: AppColors.primary,
                        isDark: isDark,
                      ),
                      if (e.note != null && e.note!.isNotEmpty) ...[
                        _DetailDivider(isDark: isDark),
                        _DetailRow(
                          icon: Icons.notes_rounded,
                          label: t('expenseNote'),
                          value: e.note!,
                          iconColor: AppColors.primary,
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),

                  const Gap(32),

                  // ── Edit button (gradient primary) ──────────────────
                  _PrimaryActionButton(
                    label: t('editExpense'),
                    icon: Icons.edit_rounded,
                    onTap: () =>
                        context.push('/expenses/${e.id}/edit', extra: e),
                  ),
                  const Gap(12),

                  // ── Delete button (outlined danger) ─────────────────
                  _OutlinedDangerButton(
                    label: t('deleteExpense'),
                    icon: Icons.delete_outline_rounded,
                    isDark: isDark,
                    onTap: () => _confirmDelete(context, ref, e),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Expense e) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          ref.tr('deleteConfirmTitle'),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF14102B)),
        ),
        content: Text(
          '${ref.tr('delete')} "${e.title}"? ${ref.tr('deleteConfirmMsg')}',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              ref.tr('cancel'),
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(ref.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(expenseListProvider.notifier).deleteExpense(e.id);
      if (context.mounted) context.pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Circular icon button — matches Add/Edit screen top bar buttons
// ─────────────────────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? (isDark ? Colors.white : const Color(0xFF14102B)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Details card — groups all detail rows into one card, like SpendingWalletCard
// ─────────────────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _DetailsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  final bool isDark;
  const _DetailDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Detail row — icon chip + label/value, inside the details card
// ─────────────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const Gap(3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF14102B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Primary gradient action button — matches SaveButton / login CTA style
// ─────────────────────────────────────────────────────────────────────────
class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.85),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Outlined danger button — for destructive delete action
// ─────────────────────────────────────────────────────────────────────────
class _OutlinedDangerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _OutlinedDangerButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}