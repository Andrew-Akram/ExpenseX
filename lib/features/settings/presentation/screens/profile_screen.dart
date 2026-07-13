import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../wallets/presentation/providers/wallet_provider.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editingName = false;
  bool _savingName = false;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(authStateProvider.notifier);
    _nameCtrl.text = notifier.currentDisplayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Photo helpers ───────────────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null || !mounted) return;

    final oldPath = ref.read(profilePhotoPathProvider);
    if (oldPath != null) {
      try {
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          oldFile.deleteSync();
        }
      } catch (_) {}
    }

    final appDir = await getApplicationDocumentsDirectory();
    final dest = '${appDir.path}/profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(xFile.path).copy(dest);

    await ref.read(profilePhotoPathProvider.notifier).setPath(dest);
  }

  Future<void> _removePhoto() async {
    final oldPath = ref.read(profilePhotoPathProvider);
    if (oldPath != null) {
      try {
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          oldFile.deleteSync();
        }
      } catch (_) {}
    }
    await ref.read(profilePhotoPathProvider.notifier).setPath(null);
  }

  // ── Name helpers ────────────────────────────────────────────────────────────
  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingName = true);
    try {
      await ref.read(authStateProvider.notifier).updateDisplayName(name);
      setState(() => _editingName = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${ref.tr('errorPrefix')}: $e')));
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  // ── Password helpers ────────────────────────────────────────────────────────
  void _showChangePasswordDialog() {
    final newCtrl = TextEditingController();
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Theme.of(ctx).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          title: Text(
            ref.tr('changePassword'),
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newCtrl,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: ref.tr('newPasswordLabel'),
                  filled: true,
                  fillColor: Theme.of(ctx).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setS(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ref.tr('cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                final np = newCtrl.text.trim();
                if (np.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ref.tr('passwordLength'))),
                  );
                  return;
                }
                try {
                  await ref.read(authStateProvider.notifier).updatePassword(np);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ref.tr('passwordUpdatedSuccess'))),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('${ref.tr('errorPrefix')}: $e')));
                  }
                }
              },
              child: Text(ref.tr('update')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;
    final photoPath = ref.watch(profilePhotoPathProvider);
    final notifier = ref.read(authStateProvider.notifier);
    final email = notifier.currentEmail ?? '';
    final displayName = notifier.currentDisplayName ?? 'User';
    final createdAt = notifier.creationTime;

    final totalAssets = ref.watch(totalAssetsProvider);
    final monthlySpend = ref.watch(monthlyTotalProvider);
    final todaySpend = ref.watch(todayTotalProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final walletsAsync = ref.watch(walletListProvider);

    String t(String key) => ref.tr(key);

    final headerTextColor = isDark ? Colors.white : const Color(0xFF14102B);

    // Build avatar widget
    Widget avatar;
    if (photoPath != null && File(photoPath).existsSync()) {
      avatar = Container(
        width: 108,
        height: 108,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isDark ? 0.18 : 0.22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(File(photoPath)),
        ),
      );
    } else {
      final initials = displayName.isNotEmpty
          ? displayName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
          : 'U';
      avatar = Container(
        width: 108,
        height: 108,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.22),
              AppColors.primary.withOpacity(0.10),
            ],
          ),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isDark ? 0.18 : 0.22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF241A57).withOpacity(0.55), AppColors.surfaceDark]
                      : [const Color(0xFFC3B9FF), const Color(0xFFEDEBFF), AppColors.surface],
                  stops: isDark ? const [0.0, 1.0] : const [0.0, 0.55, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // AppBar row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
                      child: Row(
                        children: [
                          const SizedBox(width: 40),
                          const Spacer(),
                          Text(
                            t('profile'),
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: headerTextColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.settings_rounded, color: headerTextColor, size: 22),
                              onPressed: () => context.push('/profile/settings'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),

                    // Avatar with edit overlay
                    Stack(
                      children: [
                        avatar.animate().fadeIn(duration: 450.ms).scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOutBack),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _showPhotoOptions(),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),

                    // Display name (editable)
                    _editingName
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameCtrl,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: headerTextColor,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_savingName)
                            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            IconButton(
                              icon: const Icon(Icons.check_rounded, color: AppColors.success),
                              onPressed: _saveName,
                            ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _editingName = false;
                              _nameCtrl.text = notifier.currentDisplayName ?? '';
                            }),
                          ),
                        ],
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: headerTextColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _editingName = true),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 17,
                            color: isDark ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),

                    // Email
                    Text(
                      email,
                      style: text.bodyMedium?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                        letterSpacing: -0.1,
                      ),
                    ),

                    // Member since
                    if (createdAt != null) ...[
                      const Gap(6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.035),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${t("memberSince")} ${DateFormat('MMM yyyy', ref.watch(localeProvider).languageCode).format(createdAt)}',
                          style: text.bodySmall?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Gap(30),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats row ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: t('totalBalance'),
                          valueAsync: totalAssets,
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: AppColors.primary,
                          isDark: isDark,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _StatCard(
                          label: t('spentThisMonth'),
                          valueAsync: monthlySpend,
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFFE17055),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: t('spentToday'),
                          valueAsync: todaySpend,
                          icon: Icons.today_rounded,
                          iconColor: const Color(0xFF00B894),
                          isDark: isDark,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _CountCard(
                          label: t('transactionCount'),
                          count: expensesAsync.value?.where((e) => !e.isDeleted).length ?? 0,
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFF6C5CE7),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.ms, duration: 350.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                  const Gap(28),

                  // ── Wallet summary ────────────────────────────────────────
                  Text(
                    t('wallets'),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF14102B),
                    ),
                  ),
                  const Gap(14),
                  walletsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (wallets) => wallets.isEmpty
                        ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        t('noWalletsYet'),
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    )
                        : Column(
                      children: wallets.map((w) {
                        return _WalletRow(wallet: w, isDark: isDark);
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                  const Gap(28),

                  // ── Account actions ──────────────────────────────────────
                  Text(
                    t('security'),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF14102B),
                    ),
                  ),
                  const Gap(14),
                  _ActionTile(
                    icon: Icons.lock_reset_rounded,
                    iconColor: const Color(0xFF6C5CE7),
                    title: t('changePassword'),
                    isDark: isDark,
                    onTap: _showChangePasswordDialog,
                  ).animate().fadeIn(delay: 250.ms, duration: 300.ms).slideX(begin: 0.03, end: 0),
                  const Gap(10),
                  _ActionTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFFE17055),
                    title: t('lockApp'),
                    isDark: isDark,
                    onTap: () {
                      ref.read(authStateProvider.notifier).lock();
                    },
                  ).animate().fadeIn(delay: 280.ms, duration: 300.ms).slideX(begin: 0.03, end: 0),
                  const Gap(10),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    iconColor: Colors.red,
                    title: t('signOut'),
                    isDark: isDark,
                    textColor: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          title: Text(
                            t('signOut'),
                            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
                          ),
                          content: Text(t('signOutConfirm')),
                          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(t('cancel')),
                            ),
                            FilledButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await ref.read(authStateProvider.notifier).signOut();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: Text(t('signOut')),
                            ),
                          ],
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 310.ms, duration: 300.ms).slideX(begin: 0.03, end: 0),
                  SizedBox(height: 119 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photoPath = ref.read(profilePhotoPathProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const Gap(22),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              ),
              title: Text(
                ref.tr('chooseFromGallery'),
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto();
              },
            ),
            if (photoPath != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.red),
                ),
                title: Text(
                  ref.tr('removePhoto'),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red, letterSpacing: -0.2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends ConsumerWidget {
  final String label;
  final AsyncValue<double> valueAsync;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.valueAsync,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [iconColor.withOpacity(0.20), iconColor.withOpacity(0.10)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 3),
                valueAsync.when(
                  loading: () => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const SizedBox(height: 14, width: 50, child: LinearProgressIndicator(minHeight: 2)),
                  ),
                  error: (_, __) => const Text('--', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  data: (v) => Text(
                    v.asCurrency,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : const Color(0xFF14102B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// ── Count Card ────────────────────────────────────────────────────────────────
class _CountCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _CountCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [iconColor.withOpacity(0.20), iconColor.withOpacity(0.10)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF14102B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wallet row ────────────────────────────────────────────────────────────────
class _WalletRow extends ConsumerWidget {
  final dynamic wallet; // Wallet entity
  final bool isDark;

  const _WalletRow({required this.wallet, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(walletBalancesProvider);
    final balance = balancesAsync.value?[wallet.id] ?? wallet.initialBalance as double;
    final wColor = Color(wallet.colorValue as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 34,
            margin: const EdgeInsetsDirectional.only(end: 12),
            decoration: BoxDecoration(
              color: wColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: wColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: wColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              (wallet.name as String) == 'Main Wallet' ? ref.tr('mainWallet') : (wallet.name as String),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : const Color(0xFF14102B),
              ),
            ),
          ),
          Text(
            balance.asCurrency,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: -0.2,
              color: balance >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Tile ────────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDark;
  final Color? textColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF161616) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        highlightColor: iconColor.withOpacity(0.06),
        splashColor: iconColor.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [iconColor.withOpacity(0.20), iconColor.withOpacity(0.10)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.2,
                    color: textColor ?? (isDark ? Colors.white : const Color(0xFF14102B)),
                  ),
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}