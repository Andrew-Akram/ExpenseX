import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../../core/localization/app_lang.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _page = 0;
  int get _currentIndex => _page.round();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      ref.read(authStateProvider.notifier).completeOnboarding();
    }
  }

  void _onSkip() {
    ref.read(authStateProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;
    final t = (String key) => ref.tr(key);
    final isLast = _currentIndex == 2;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: Stack(
        children: [
          // ── Soft top gradient backdrop ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                    const Color(0xFF1E1646).withOpacity(0.45),
                    AppColors.surfaceDark,
                  ]
                      : [
                    const Color(0xFFE5E2FF),
                    AppColors.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Skip button (direction-aware) ─────────────────────
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 20, top: 8),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLast ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: isLast,
                        child: TextButton(
                          onPressed: _onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor:
                            isDark ? Colors.white60 : Colors.black45,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            t('onboardSkip'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _AnimatedPage(
                        index: 0,
                        page: _page,
                        child: _buildPage1(context, isDark, t),
                      ),
                      _AnimatedPage(
                        index: 1,
                        page: _page,
                        child: _buildPage2(context, isDark),
                      ),
                      _AnimatedPage(
                        index: 2,
                        page: _page,
                        child: _buildPage3(context, isDark, t),
                      ),
                    ],
                  ),
                ),

                // ── Titles & navigation ────────────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _getTitle(_currentIndex, t),
                          key: ValueKey('title_$_currentIndex'),
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F0C20),
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Gap(10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _getDescription(_currentIndex, t),
                          key: ValueKey('desc_$_currentIndex'),
                          style: text.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Gap(28),

                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = index == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isActive ? 22 : 6,
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  Color.lerp(AppColors.primary,
                                      Colors.black, .15)!,
                                ],
                              )
                                  : null,
                              color: isActive
                                  ? null
                                  : (isDark ? Colors.white24 : Colors.black12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          );
                        }),
                      ),
                      const Gap(28),

                      // Primary button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ).copyWith(
                            overlayColor: WidgetStateProperty.all(
                                Colors.white.withOpacity(0.08)),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              isLast ? t('onboardGetStarted') : t('onboardNext'),
                              key: ValueKey(isLast),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(int index, String Function(String) t) {
    switch (index) {
      case 0:
        return t('onboardTitle1');
      case 1:
        return t('onboardTitle2');
      case 2:
      default:
        return t('onboardTitle3');
    }
  }

  String _getDescription(int index, String Function(String) t) {
    switch (index) {
      case 0:
        return t('onboardDesc1');
      case 1:
        return t('onboardDesc2');
      case 2:
      default:
        return t('onboardDesc3');
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // Page 1: Ring chart card
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildPage1(BuildContext context, bool isDark, String Function(String) t) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 26,
              spreadRadius: -6,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.78),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      backgroundColor: const Color(0xFF86E3CE)
                          .withOpacity(isDark ? 0.25 : 0.6),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t('onboardExpenseLabel'),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(4),
                    Text(
                      r'$313.31',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(26),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: isDark ? Colors.white70 : AppColors.primary,
                      size: 20),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('onboardSpendingLabel'),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        t('onboardBillsUtilities'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  r'+$120',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Page 2: Orbiting category badges around a center pie icon
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildPage2(BuildContext context, bool isDark) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 18,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
            _buildOrbitBadge(
              alignment: const Alignment(0, -0.75),
              icon: Icons.local_grocery_store_rounded,
              color: Colors.green,
              isDark: isDark,
            ),
            _buildOrbitBadge(
              alignment: const Alignment(0.65, -0.4),
              icon: Icons.home_filled,
              color: Colors.pink,
              isDark: isDark,
            ),
            _buildOrbitBadge(
              alignment: const Alignment(0.7, 0.3),
              icon: Icons.campaign_rounded,
              color: Colors.orange,
              isDark: isDark,
            ),
            _buildOrbitBadge(
              alignment: const Alignment(0, 0.75),
              icon: Icons.flight_takeoff_rounded,
              color: Colors.cyan,
              isDark: isDark,
            ),
            _buildOrbitBadge(
              alignment: const Alignment(-0.7, 0.3),
              icon: Icons.directions_car_filled_rounded,
              color: Colors.blue,
              isDark: isDark,
            ),
            _buildOrbitBadge(
              alignment: const Alignment(-0.65, -0.4),
              icon: Icons.menu_book_rounded,
              color: Colors.deepPurple,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitBadge({
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Page 3: Staggered feature cards
  // ───────────────────────────────────────────────────────────────────────
  Widget _buildPage3(BuildContext context, bool isDark, String Function(String) t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-20, 0),
            child: _buildReferralCard(
              icon: Icons.card_giftcard_rounded,
              iconBgColor: const Color(0xFFFFB03A),
              title: t('onboardEarnRewardsTitle'),
              subtitle: t('onboardEarnRewardsSubtitle'),
              isDark: isDark,
            ),
          ),
          const Gap(14),
          Transform.translate(
            offset: const Offset(20, 0),
            child: _buildReferralCard(
              icon: Icons.ios_share_rounded,
              iconBgColor: AppColors.primary,
              title: t('onboardEasySharingTitle'),
              subtitle: t('onboardEasySharingSubtitle'),
              isDark: isDark,
            ),
          ),
          const Gap(14),
          Transform.translate(
            offset: const Offset(-10, 0),
            child: _buildReferralCard(
              icon: Icons.bar_chart_rounded,
              iconBgColor: const Color(0xFF10B981),
              title: t('onboardTrackReferralsTitle'),
              subtitle: t('onboardTrackReferralsSubtitle'),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconBgColor, size: 18),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
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

/// Wraps a PageView child with a subtle scale + fade tied to scroll offset,
/// giving each page a soft parallax "settle in" feel as it becomes active.
class _AnimatedPage extends StatelessWidget {
  final int index;
  final double page;
  final Widget child;

  const _AnimatedPage({
    required this.index,
    required this.page,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delta = (page - index).clamp(-1.0, 1.0);
    final scale = 1 - (delta.abs() * 0.08);
    final opacity = 1 - (delta.abs() * 0.35);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}