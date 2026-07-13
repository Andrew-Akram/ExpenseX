import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletsAsync = ref.watch(walletListProvider);
    final balancesAsync = ref.watch(walletBalancesProvider);
    final totalAssetsAsync = ref.watch(totalAssetsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: Text(ref.tr('myWallets'), style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Total Assets Card ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.cardPadding),
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.dashboardDarkGradient : AppColors.dashboardLightGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('totalBalance').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Gap(6),
                    totalAssetsAsync.when(
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

            // ── Wallet List ─────────────────────────────────────────────
            Expanded(
              child: walletsAsync.when(
                loading: () => const ShimmerLoading(),
                error: (err, _) => Center(child: Text('${ref.tr('errorLoadingWallets')}: $err')),
                data: (wallets) {
                  if (wallets.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.account_balance_wallet_rounded,
                      title: ref.tr('noWalletsYet'),
                      subtitle: ref.tr('noWalletsYet'),
                      actionLabel: ref.tr('addWallet'),
                      onAction: () => context.push('/expenses/wallets/add'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                    itemCount: wallets.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final wallet = wallets[index];
                      final balance = balancesAsync.value?[wallet.id] ?? wallet.initialBalance;

                      return _WalletItemCard(
                        wallet: wallet,
                        balance: balance,
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.pagePadding,
          AppSizes.pagePadding,
          AppSizes.pagePadding + 92 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push('/expenses/wallets/transfer'),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(ref.tr('transferMoney')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const Gap(12),
            FloatingActionButton(
              onPressed: () => context.push('/expenses/wallets/add'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletItemCard extends ConsumerWidget {
  final Wallet wallet;
  final double balance;
  final bool isDark;
  final int index;

  const _WalletItemCard({
    required this.wallet,
    required this.balance,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletColor = Color(wallet.colorValue);
    final iconData = _getIconData(wallet.iconName);

    return Dismissible(
      key: Key(wallet.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(walletListProvider.notifier).deleteWallet(wallet.id);
      },
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => context.push('/expenses/wallets/${wallet.id}/edit', extra: wallet),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: walletColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: walletColor, size: 24),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF14102B),
                        ),
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          ref.tr(wallet.type.name),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  balance.asCurrency,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: balance >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 200.ms).slideY(begin: 0.08);
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'account_balance_wallet': return Icons.account_balance_wallet_rounded;
      case 'credit_card':            return Icons.credit_card_rounded;
      case 'savings':                return Icons.savings_rounded;
      case 'attach_money':           return Icons.attach_money_rounded;
      case 'phone_android':          return Icons.phone_android_rounded;
      case 'local_atm':              return Icons.local_atm_rounded;
      default:                       return Icons.account_balance_wallet_rounded;
    }
  }
}
