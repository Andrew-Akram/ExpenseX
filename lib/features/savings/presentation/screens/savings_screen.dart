import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_provider.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsAsync = ref.watch(savingsGoalListProvider);
    final totalSavedAsync = ref.watch(totalSavedAmountProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Total Saved Card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.cardPadding),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL SAVED',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Gap(6),
                    totalSavedAsync.when(
                      data: (total) => Text(
                        total.asCurrency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      loading: () => const Text('\$--', style: TextStyle(color: Colors.white, fontSize: 32)),
                      error: (_, __) => const Text('\$--', style: TextStyle(color: Colors.white, fontSize: 32)),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(20),

            // ── Goals List ──────────────────────────────────────────────
            Expanded(
              child: goalsAsync.when(
                loading: () => const ShimmerLoading(),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (goals) {
                  if (goals.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.savings_rounded,
                      title: 'No Goals Yet',
                      subtitle: 'Set up target savings goals to fund your dreams.',
                      actionLabel: 'Add Goal',
                      onAction: () => context.push('/dashboard/savings/add'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                    itemCount: goals.length,
                    separatorBuilder: (_, __) => const Gap(16),
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return _SavingsGoalCard(
                        goal: goal,
                        isDark: isDark,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/savings/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _SavingsGoalCard extends ConsumerWidget {
  final SavingsGoal goal;
  final bool isDark;
  final int index;

  const _SavingsGoalCard({
    required this.goal,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalColor = Color(goal.colorValue);
    final isCompleted = goal.isCompleted || goal.currentAmount >= goal.targetAmount;
    final percent = (goal.targetAmount > 0) ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final daysRemaining = goal.deadline.difference(DateTime.now()).inDays;

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: goalColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIconData(goal.iconName), color: goalColor, size: 22),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF14102B),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        daysRemaining >= 0 ? '$daysRemaining days left' : 'Overdue',
                        style: TextStyle(fontSize: 12, color: daysRemaining >= 0 ? Colors.grey : AppColors.error),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: isCompleted ? null : () => _showContributeDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: isCompleted ? Colors.grey : AppColors.success,
                    backgroundColor: isCompleted ? Colors.grey.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentAmount.asCurrency} / ${goal.targetAmount.asCurrency}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}% Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                color: isCompleted ? AppColors.success : goalColor,
              ),
            ),

            if (isCompleted) ...[
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.stars_rounded, color: AppColors.success, size: 18),
                  Gap(6),
                  Text(
                    'Goal Completed! 🎉',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ).animate().scale(delay: 150.ms).fadeIn(),
            ],
          ],
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 220.ms).slideY(begin: 0.06);
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'savings':        return Icons.savings_rounded;
      case 'star':           return Icons.star_rounded;
      case 'home':           return Icons.home_rounded;
      case 'flight':         return Icons.flight_rounded;
      case 'school':         return Icons.school_rounded;
      case 'gift':           return Icons.card_giftcard_rounded;
      case 'car':            return Icons.directions_car_rounded;
      case 'coffee':         return Icons.local_cafe_rounded;
      default:               return Icons.savings_rounded;
    }
  }

  void _showContributeDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the amount you want to contribute towards this savings goal:'),
            const Gap(14),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Amount',
                prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.success),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amt = double.tryParse(ctrl.text);
              if (amt != null && amt > 0) {
                ref.read(savingsGoalListProvider.notifier).contribute(goal.id, amt);
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Contribute'),
          ),
        ],
      ),
    );
  }
}
