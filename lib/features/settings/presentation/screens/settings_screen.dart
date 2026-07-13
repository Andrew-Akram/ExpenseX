import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    final themeMode = ref.watch(themeModeProvider);
    final isDarkModeOn = themeMode == ThemeMode.dark;
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authStateProvider);
    final currentPolicy = ref.read(authStateProvider.notifier).currentLockPolicy;

    String t(String key) => ref.tr(key);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            title: Text(
              t('settings'),
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF14102B),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              // Nav bar height (74) + bottom margin (18) + FAB overlap (27) + safe area bottom
              119 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance ────────────────────────────────────────────
                _SectionTitle(text: t('appearance'), isDark: isDark, textTheme: text),
                const Gap(12),
                _ToggleTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF6C5CE7),
                  title: t('darkMode'),
                  isDark: isDark,
                  value: isDarkModeOn,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ).animate().fadeIn(delay: 60.ms),
                const Gap(24),

                // ── Language ──────────────────────────────────────────────
                _SectionTitle(text: t('language'), isDark: isDark, textTheme: text),
                const Gap(12),
                _ActionTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF00B894),
                  title: t('language'),
                  valueText:
                  locale.languageCode == 'ar' ? t('arabic') : t('english'),
                  isDark: isDark,
                  onTap: () =>
                      _showLanguageSheet(context, ref, locale.languageCode, isDark),
                ).animate().fadeIn(delay: 100.ms),
                const Gap(24),

                // ── Export ────────────────────────────────────────────────
                _SectionTitle(text: t('export'), isDark: isDark, textTheme: text),
                const Gap(12),
                _ActionTile(
                  icon: Icons.file_download_rounded,
                  iconColor: const Color(0xFFE17055),
                  title: t('exportReport'),
                  subtitle: t('pdfOrCsv'),
                  isDark: isDark,
                  onTap: () => context.push('/profile/settings/export'),
                ).animate().fadeIn(delay: 140.ms),
                const Gap(24),

                // ── Security ──────────────────────────────────────────────
                _SectionTitle(text: t('security'), isDark: isDark, textTheme: text),
                const Gap(12),
                _ActionTile(
                  icon: Icons.lock_clock_rounded,
                  iconColor: AppColors.primary,
                  title: t('lockPolicy'),
                  valueText: _lockPolicyLabel(currentPolicy, t),
                  isDark: isDark,
                  onTap: () =>
                      _showLockPolicySheet(context, ref, currentPolicy, t, isDark),
                ).animate().fadeIn(delay: 180.ms),
                const Gap(8),
                _ActionTile(
                  icon: Icons.lock_rounded,
                  iconColor: AppColors.primary,
                  title: t('changePIN'),
                  isDark: isDark,
                  onTap: () => _changePinDialog(context, ref, isDark),
                ).animate().fadeIn(delay: 210.ms),
                if (authState.isBiometricAvailable) ...[
                  const Gap(8),
                  _ToggleTile(
                    icon: Icons.fingerprint_rounded,
                    iconColor: AppColors.primary,
                    title: t('enableBiometric'),
                    isDark: isDark,
                    value: authState.isBiometricEnabled,
                    onChanged: (v) =>
                        ref.read(authStateProvider.notifier).toggleBiometric(v),
                  ).animate().fadeIn(delay: 240.ms),
                ],
                const Gap(24),

                // ── About ─────────────────────────────────────────────────
                _SectionTitle(text: t('about'), isDark: isDark, textTheme: text),
                const Gap(12),
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: isDark ? Colors.white38 : Colors.black38,
                  title: 'Smart Expense Tracker',
                  subtitle: t('version'),
                  isDark: isDark,
                ).animate().fadeIn(delay: 280.ms),
                const Gap(24),

                // ── Sign out ──────────────────────────────────────────────
                _ActionTile(
                  icon: Icons.logout_rounded,
                  iconColor: Colors.red,
                  title: t('signOut'),
                  isDark: isDark,
                  textColor: Colors.red,
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).signOut();
                  },
                ).animate().fadeIn(delay: 320.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _lockPolicyLabel(String policy, String Function(String) t) {
    switch (policy) {
      case LockPolicy.inactivity5:
        return t('lockAfter5');
      case LockPolicy.inactivity10:
        return t('lockAfter10');
      case LockPolicy.inactivity15:
        return t('lockAfter15');
      case LockPolicy.never:
        return t('neverLock');
      default:
        return t('lockOnLaunch');
    }
  }

  void _showLockPolicySheet(BuildContext context, WidgetRef ref, String current,
      String Function(String) t, bool isDark) {
    final policies = [
      (LockPolicy.onLaunch, t('lockOnLaunch'), Icons.flash_on_rounded),
      (LockPolicy.inactivity5, t('lockAfter5'), Icons.timer_rounded),
      (LockPolicy.inactivity10, t('lockAfter10'), Icons.timer_rounded),
      (LockPolicy.inactivity15, t('lockAfter15'), Icons.timer_rounded),
      (LockPolicy.never, t('neverLock'), Icons.lock_open_rounded),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(
        title: t('lockPolicy'),
        isDark: isDark,
        children: policies
            .map((p) => _SheetOptionRow(
          icon: p.$3,
          label: p.$2,
          selected: p.$1 == current,
          isDark: isDark,
          onTap: () {
            ref.read(authStateProvider.notifier).updateLockPolicy(p.$1);
            Navigator.pop(context);
          },
        ))
            .toList(),
      ),
    );
  }

  void _showLanguageSheet(
      BuildContext context, WidgetRef ref, String currentCode, bool isDark) {
    String t(String key) {
      final code = ref.read(localeProvider).languageCode;
      return AppLang.translations[code]?[key] ??
          AppLang.translations['en']?[key] ??
          key;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(
        title: t('language'),
        isDark: isDark,
        children: [
          _SheetOptionRow(
            icon: Icons.language_rounded,
            label: 'English',
            selected: currentCode == 'en',
            isDark: isDark,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale('en');
              Navigator.pop(context);
            },
          ),
          _SheetOptionRow(
            icon: Icons.language_rounded,
            label: 'العربية',
            selected: currentCode == 'ar',
            isDark: isDark,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale('ar');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _changePinDialog(BuildContext context, WidgetRef ref, bool isDark) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ref.tr('changePIN'),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF14102B),
          ),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          autofocus: true,
          style: TextStyle(
            letterSpacing: 8,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF14102B),
          ),
          decoration: InputDecoration(
            counterText: '',
            labelText: ref.tr('newPinLabel'),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ref.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (ctrl.text.length == 4) {
                await ref.read(authStateProvider.notifier).changePin(ctrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(ref.tr('save')),
          ),
        ],
      ),
    );
  }
}

// ── Section title ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  final TextTheme textTheme;
  const _SectionTitle({required this.text, required this.isDark, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF14102B),
      ),
    );
  }
}

// ── Action tile (matches ProfileScreen's _ActionTile) ────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? valueText;
  final bool isDark;
  final Color? textColor;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    this.subtitle,
    this.valueText,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Material(
      color: isDark ? const Color(0xFF141414) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor ?? (isDark ? Colors.white : const Color(0xFF14102B)),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (valueText != null) ...[
                Text(
                  valueText!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const Gap(4),
              ],
              if (onTap != null)
                Icon(
                  isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Toggle tile (same shell as _ActionTile, with a Switch) ───────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDark;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Gap(14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF14102B),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Info tile (no chevron, no tap — for "About") ──────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Gap(14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF14102B),
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet shell (matches ProfileScreen's _showPhotoOptions) ───────────
class _OptionSheet extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _OptionSheet({required this.title, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        // Push content above the floating nav bar (74 bar + 18 margin = 92) + device safe area
        92 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const Gap(20),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF14102B),
            ),
          ),
          const Gap(8),
          ...children,
        ],
      ),
    );
  }
}

class _SheetOptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetOptionRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (selected ? AppColors.primary : (isDark ? Colors.white : Colors.black))
              .withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? AppColors.primary : (isDark ? Colors.white54 : Colors.black45),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected
              ? AppColors.primary
              : (isDark ? Colors.white : const Color(0xFF14102B)),
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}