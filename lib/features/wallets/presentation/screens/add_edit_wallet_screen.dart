import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';

class AddEditWalletScreen extends ConsumerStatefulWidget {
  final Wallet? wallet;
  const AddEditWalletScreen({super.key, this.wallet});

  @override
  ConsumerState<AddEditWalletScreen> createState() => _AddEditWalletScreenState();
}

class _AddEditWalletScreenState extends ConsumerState<AddEditWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _balanceCtrl;
  late WalletType _type;
  late String _currency;
  late int _selectedColor;
  late String _selectedIcon;

  final List<String> _currencies = ['USD', 'EGP', 'EUR', 'GBP', 'SAR'];
  final List<String> _icons = [
    'account_balance_wallet',
    'credit_card',
    'savings',
    'attach_money',
    'phone_android',
    'local_atm',
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    _nameCtrl = TextEditingController(text: w?.name ?? '');
    _balanceCtrl = TextEditingController(text: w != null ? w.initialBalance.toString() : '0');
    _type = w?.type ?? WalletType.cash;
    _currency = w?.currency ?? 'USD';
    _selectedColor = w?.colorValue ?? CategoryConstants.availableColors.first;
    _selectedIcon = w?.iconName ?? 'account_balance_wallet';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.wallet != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? ref.tr('editWallet') : ref.tr('addWallet'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding, 4, AppSizes.pagePadding, 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Preview card ───────────────────────────────────
                      _WalletPreviewCard(
                        color: Color(_selectedColor),
                        icon: _getIconData(_selectedIcon),
                        name: _nameCtrl.text.isEmpty ? ref.tr('walletName') : _nameCtrl.text,
                        typeLabel: ref.tr(_type.name),
                        currency: _currency,
                        balance: double.tryParse(_balanceCtrl.text) ?? 0.0,
                      ).animate().fadeIn(duration: 300.ms).slideY(
                          begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                      const Gap(28),

                      // ── Wallet name ─────────────────────────────────────
                      _FieldLabel(text: ref.tr('walletName'), isDark: isDark),
                      const Gap(8),
                      TextFormField(
                        controller: _nameCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration(isDark, ref.tr('walletName'), Icons.edit_rounded),
                        validator: (v) => v == null || v.isEmpty ? ref.tr('required') : null,
                      ).animate().fadeIn(delay: 60.ms),
                      const Gap(18),

                      // ── Initial balance ─────────────────────────────────
                      _FieldLabel(text: ref.tr('initialBalance'), isDark: isDark),
                      const Gap(8),
                      TextFormField(
                        controller: _balanceCtrl,
                        onChanged: (_) => setState(() {}),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(
                            isDark, ref.tr('initialBalance'), Icons.attach_money_rounded),
                        validator: (v) => double.tryParse(v ?? '') == null ? ref.tr('invalidBalance') : null,
                      ).animate().fadeIn(delay: 90.ms),
                      const Gap(22),

                      // ── Wallet type (chip selector) ─────────────────────
                      _FieldLabel(text: ref.tr('walletType'), isDark: isDark),
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: WalletType.values.map((t) {
                          final isSel = t == _type;
                          return _SelectChip(
                            label: ref.tr(t.name),
                            icon: _typeIcon(t),
                            selected: isSel,
                            isDark: isDark,
                            onTap: () => setState(() => _type = t),
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 120.ms),
                      const Gap(22),

                      // ── Currency (chip selector) ────────────────────────
                      _FieldLabel(text: ref.tr('currency'), isDark: isDark),
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currencies.map((c) {
                          final isSel = c == _currency;
                          return _SelectChip(
                            label: c,
                            selected: isSel,
                            isDark: isDark,
                            onTap: () => setState(() => _currency = c),
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 150.ms),
                      const Gap(26),

                      // ── Color picker ─────────────────────────────────────
                      _FieldLabel(text: ref.tr('selectWalletColor'), isDark: isDark),
                      const Gap(10),
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: CategoryConstants.availableColors.length,
                          itemBuilder: (context, index) {
                            final c = CategoryConstants.availableColors[index];
                            final isSel = c == _selectedColor;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = c),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                curve: Curves.easeOut,
                                width: isSel ? 44 : 40,
                                height: isSel ? 44 : 40,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Color(c),
                                  shape: BoxShape.circle,
                                  border: isSel
                                      ? Border.all(
                                      color: isDark ? Colors.white : Colors.white,
                                      width: 3)
                                      : Border.all(color: Colors.transparent, width: 3),
                                  boxShadow: isSel
                                      ? [
                                    BoxShadow(
                                      color: Color(c).withOpacity(0.45),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                      : null,
                                ),
                                child: isSel
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 180.ms),
                      const Gap(26),

                      // ── Icon picker ───────────────────────────────────────
                      _FieldLabel(text: ref.tr('selectWalletIcon'), isDark: isDark),
                      const Gap(10),
                      SizedBox(
                        height: 52,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _icons.length,
                          itemBuilder: (context, index) {
                            final iconKey = _icons[index];
                            final isSel = iconKey == _selectedIcon;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = iconKey),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                width: 48,
                                height: 48,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.primary.withOpacity(0.12)
                                      : (isDark ? const Color(0xFF141414) : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.primary
                                        : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Icon(
                                  _getIconData(iconKey),
                                  color: isSel
                                      ? AppColors.primary
                                      : (isDark ? Colors.white54 : Colors.black45),
                                  size: 21,
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 210.ms),
                    ],
                  ),
                ),
              ),

              // ── Sticky save bar ─────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.pagePadding, 12, AppSizes.pagePadding,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isEdit ? ref.tr('saveChanges') : ref.tr('createWallet'),
                        style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: isDark ? const Color(0xFF141414) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  IconData _typeIcon(WalletType t) {
    switch (t) {
      case WalletType.cash:
        return Icons.payments_rounded;
      case WalletType.bank:
        return Icons.account_balance_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text;
    final initialBalance = double.parse(_balanceCtrl.text);

    final wallet = Wallet(
      id: widget.wallet?.id ?? const Uuid().v4(),
      name: name,
      type: _type,
      initialBalance: initialBalance,
      currency: _currency,
      colorValue: _selectedColor,
      iconName: _selectedIcon,
      createdAt: widget.wallet?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.wallet != null) {
      ref.read(walletListProvider.notifier).updateWallet(wallet);
    } else {
      ref.read(walletListProvider.notifier).addWallet(wallet);
    }

    context.pop();
  }
}

// ── Preview card ─────────────────────────────────────────────────────────────
class _WalletPreviewCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String name;
  final String typeLabel;
  final String currency;
  final double balance;

  const _WalletPreviewCard({
    required this.color,
    required this.icon,
    required this.name,
    required this.typeLabel,
    required this.currency,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.65,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.28)!],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // decorative watermark ring
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 20),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(14),
                    Text(
                      balance.asCurrency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field label ────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }
}

// ── Select chip (type / currency) ────────────────────────────────────────────
class _SelectChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : (isDark ? const Color(0xFF141414) : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : (isDark ? Colors.white54 : Colors.black45),
              ),
              const Gap(6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}