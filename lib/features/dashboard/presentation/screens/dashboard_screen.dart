import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../wallets/presentation/providers/wallet_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String t(String key) => ref.tr(key);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expenseListProvider);
          ref.invalidate(categoryTotalsProvider);
          ref.invalidate(dailyTotals7Provider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Gradient header (top lavender-to-white section) ───────────
            SliverToBoxAdapter(
              child: _DashboardHeader(t: t),
            ),

            // ── Body (white/black section below header) ───────────────────
            SliverToBoxAdapter(
              child: _DashboardBody(t: t),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header: soft lavender→surface gradient bg, dark text, solid white pills
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardHeader extends ConsumerWidget {
  final String Function(String) t;
  const _DashboardHeader({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyTotal = ref.watch(monthlyTotalProvider);
    final prevMonthTotal = ref.watch(_prevMonthTotalProvider);
    final text = Theme.of(context).textTheme;

    final headerTextColor = isDark ? Colors.white : const Color(0xFF14102B);
    final headerSubColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF1E1646).withOpacity(0.55),
            AppColors.surfaceDark,
          ]
              : [
            const Color(0xFFC9C2FF),
            const Color(0xFFEDEBFF),
            AppColors.surface,
          ],
          stops: isDark ? null : const [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top row: settings | date | bell ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.settings_outlined,
                    isDark: isDark,
                    onTap: () => context.push('/profile/settings'),
                  ),
                  _DatePill(isDark: isDark),
                  _NotificationBell(isDark: isDark),
                ],
              ),
            ),
            const Gap(28),

            // ── Spend info ─────────────────────────────────────────────────
            Text(
              t('thisMonthSpend'),
              style: text.bodyMedium?.copyWith(
                color: headerSubColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            monthlyTotal.when(
              loading: () => _AmountSkeleton(isDark: isDark),
              error: (_, __) => Text(
                r'$0.00',
                style: TextStyle(
                  color: headerTextColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              data: (amount) => Text(
                amount.asCurrency,
                style: text.displaySmall?.copyWith(
                  color: headerTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Gap(8),
            // % change vs last month
            _MonthDeltaBadge(
              currentMonthFuture: monthlyTotal,
              prevMonthFuture: prevMonthTotal,
              isDark: isDark,
              t: t,
            ),
            const Gap(28),

            // ── Spending wallet card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _SpendingWalletCard(t: t),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date pill — solid white pill, purple calendar icon, dark text
// ─────────────────────────────────────────────────────────────────────────────
class _DatePill extends StatelessWidget {
  final bool isDark;
  const _DatePill({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEE').format(now); // e.g. "Fri"
    final dayMonth = DateFormat('d MMM').format(now); // e.g. "21 Jul"
    final label = '$dayName, $dayMonth';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.10) : Colors.white,
        borderRadius: BorderRadius.circular(100),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: isDark ? Colors.white : AppColors.primary,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF14102B),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular icon button (settings / bell) — solid white circle, dark icon
// ─────────────────────────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.10) : Colors.white,
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
          color: isDark ? Colors.white : const Color(0xFF14102B),
          size: 22,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month delta badge — "↘ 67% below last month" in dark/light-adaptive text
// ─────────────────────────────────────────────────────────────────────────────
class _MonthDeltaBadge extends ConsumerWidget {
  final AsyncValue<double> currentMonthFuture;
  final AsyncValue<double> prevMonthFuture;
  final bool isDark;
  final String Function(String) t;

  const _MonthDeltaBadge({
    required this.currentMonthFuture,
    required this.prevMonthFuture,
    required this.isDark,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return currentMonthFuture.when(
      loading: () => const SizedBox(height: 22),
      error: (_, __) => const SizedBox(height: 22),
      data: (current) {
        return prevMonthFuture.when(
          loading: () => const SizedBox(height: 22),
          error: (_, __) => const SizedBox(height: 22),
          data: (prev) {
            if (prev == 0) {
              return const SizedBox(height: 22);
            }
            final diff = ((current - prev) / prev * 100).abs();
            final isBelow = current <= prev;
            final icon = isBelow
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded;
            final label =
                '${diff.toStringAsFixed(0)}% ${isBelow ? t('belowLastMonth') : t('aboveLastMonth')}';

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isBelow
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFE74C3C),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending wallet card — white card on gradient bg
// ─────────────────────────────────────────────────────────────────────────────
class _SpendingWalletCard extends ConsumerWidget {
  final String Function(String) t;
  const _SpendingWalletCard({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;
    final totalAssets = ref.watch(totalAssetsProvider);

    return GestureDetector(
      onTap: () => context.go('/expenses/wallets'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.12))
              : null,
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Wallet icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('spendingWallet'),
                    style: text.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(2),
                  totalAssets.when(
                    loading: () => const SizedBox(height: 20, width: 80),
                    error: (_, __) => Text(
                      r'$0.00',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                      ),
                    ),
                    data: (total) => Text(
                      total.asCurrency,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification bell with unread badge
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationBell extends ConsumerWidget {
  final bool isDark;
  const _NotificationBell({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    final count = unreadCount.value ?? 0;

    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.white,
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
              Icons.notifications_outlined,
              color: isDark ? Colors.white : const Color(0xFF14102B),
              size: 22,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body: white/black area with recent transactions list
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardBody extends ConsumerWidget {
  final String Function(String) t;
  const _DashboardBody({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Recent Transactions header ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('recentTransactions'),
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF14102B),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/expenses'),
                child: Text(
                  t('seeAll'),
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),

          // ── Transactions list ──────────────────────────────────────────
          const RecentTransactionsList(),

          // ── Quick Access Tools ─────────────────────────────────────
          const Gap(24),
          Text(
            t('quickAccess'),
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF14102B),
            ),
          ),
          const Gap(14),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.category_rounded,
                      iconColor: const Color(0xFF6C5CE7),
                      title: t('categories'),
                      subtitle: t('manageLimit'),
                      isDark: isDark,
                      onTap: () => context.go('/dashboard/categories'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.savings_rounded,
                      iconColor: const Color(0xFF00B894),
                      title: t('savings'),
                      subtitle: t('trackGoals'),
                      isDark: isDark,
                      onTap: () => context.go('/dashboard/savings'),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFFE17055),
                      title: t('bills'),
                      subtitle: t('upcomingBills'),
                      isDark: isDark,
                      onTap: () => context.go('/dashboard/bills'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.repeat_rounded,
                      iconColor: const Color(0xFF0984E3),
                      title: t('subscriptions'),
                      subtitle: t('recurringPayments'),
                      isDark: isDark,
                      onTap: () => context.go('/dashboard/bills?tab=2'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(100), // FAB / bottom-nav clearance
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Previous month total provider
// ─────────────────────────────────────────────────────────────────────────────
final _prevMonthTotalProvider = FutureProvider<double>((ref) async {
  final list = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  return list
      .where((e) =>
          !e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.year == prevYear &&
          e.date.month == prevMonth)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton for loading
// ─────────────────────────────────────────────────────────────────────────────
class _AmountSkeleton extends StatelessWidget {
  final bool isDark;
  const _AmountSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Access Card — used in the 2x2 Dashboard grid
// ─────────────────────────────────────────────────────────────────────────────
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF141414) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            boxShadow: isDark
                ? null
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF14102B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}