import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  // Design-reference values. These are BASE sizes at a standard viewport;
  // actual runtime values are derived/clamped from MediaQuery + LayoutBuilder
  // so the bar keeps its proportions on compact and large displays alike.
  static const double _baseBarHeight = 74;
  static const double _baseFabSize = 54;
  static const double _baseBottomMargin = 18;
  static const double _baseHorizontalMargin = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barColor = isDark ? const Color(0xff181818) : Colors.white;

    final shadowColor =
    isDark ? Colors.black.withOpacity(.55) : Colors.black.withOpacity(.10);

    // System-provided insets. This is the ONLY source of truth for
    // safe-area handling — we do not additionally nest SafeArea widgets,
    // which is what caused uneven compression between notched devices
    // and older flat-bezel screens.
    final viewPadding = MediaQuery.paddingOf(context);
    final bottomSystemInset = viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? const Color(0xff0B0B0B) : AppColors.surface,
      body: navigationShell,

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          // --- Responsive scale factor -------------------------------
          // Anchored to a 390-logical-pixel reference width (iPhone-class
          // screen). Clamped so very small or very large screens don't
          // distort proportions beyond a sane range.
          final scale = (availableWidth / 390.0).clamp(0.85, 1.25);

          final barHeight = _baseBarHeight * scale;
          final fabSize = _baseFabSize * scale;

          // Horizontal margin as a relative slice of the available width,
          // clamped so it never collapses on tiny screens or balloons on
          // tablets/foldables.
          final horizontalMargin =
          (availableWidth * 0.046).clamp(12.0, 28.0);

          // Bottom margin: base floating gap PLUS whatever the system
          // reserves for a home-indicator / gesture region. On devices
          // with on-screen buttons (bottomSystemInset == 0) this reduces
          // gracefully to just the base gap.
          final bottomMargin = _baseBottomMargin * scale + bottomSystemInset;

          final totalHeight = barHeight + bottomMargin + (fabSize / 2);

          return SizedBox(
            height: totalHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: horizontalMargin,
                  right: horizontalMargin,
                  bottom: bottomMargin,
                  height: barHeight,
                  child: CustomPaint(
                    painter: _NotchedBarPainter(
                      color: barColor,
                      shadowColor: shadowColor,
                      fabSize: fabSize,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavItem(
                            selected: navigationShell.currentIndex == 0,
                            icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                            activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                            isDark: isDark,
                            scale: scale,
                            onTap: () => _changeIndex(context, 0),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            selected: navigationShell.currentIndex == 1,
                            icon: PhosphorIcons.creditCard(PhosphorIconsStyle.regular),
                            activeIcon: PhosphorIcons.creditCard(PhosphorIconsStyle.fill),
                            isDark: isDark,
                            scale: scale,
                            onTap: () => _changeIndex(context, 1),
                          ),
                        ),

                        // Notch gap sized relative to the FAB itself (plus
                        // a little breathing room) instead of a fixed 72px,
                        // so it never visually collides with — or drifts
                        // away from — the floating button above it.
                        SizedBox(width: fabSize * 1.33),

                        Expanded(
                          child: _NavItem(
                            selected: navigationShell.currentIndex == 2,
                            icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.regular),
                            activeIcon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill),
                            isDark: isDark,
                            scale: scale,
                            onTap: () => _changeIndex(context, 2),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            selected: navigationShell.currentIndex == 3,
                            icon: PhosphorIcons.userCircle(PhosphorIconsStyle.regular),
                            activeIcon: PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
                            isDark: isDark,
                            scale: scale,
                            onTap: () => _changeIndex(context, 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 6 * scale,
                  child: _AddButton(
                    size: fabSize,
                    onTap: () => context.push('/expenses/add'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _changeIndex(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: navigationShell.currentIndex == index,
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final double fabSize;

  const _NotchedBarPainter({
    required this.color,
    required this.shadowColor,
    required this.fabSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createPath(size);

    canvas.drawShadow(path, shadowColor, 18, false);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  Path _createPath(Size size) {
    final width = size.width;
    final height = size.height;
    final center = width / 2;

    // Corner radius derived from the bar's own height rather than a fixed
    // 30px, so it stays visually consistent whether the bar is tall (large
    // display) or compact (small display).
    final radius = height * 0.405;

    // Notch geometry derived from the FAB size and the bar's height, not
    // fixed offsets. This keeps the cutout perfectly matched to the FAB
    // that sits above it, regardless of screen size or scale factor.
    final notchHalfWidth = fabSize * 1.26;
    final cp1x = notchHalfWidth * 0.765;
    final cp2x = notchHalfWidth * 0.677;
    final cp3x = notchHalfWidth * 0.382;

    final deepDip = height * 0.54;
    final midDip = height * 0.459;
    final shallowDip = height * 0.351;

    final path = Path();

    path.moveTo(0, radius);

    path.quadraticBezierTo(0, 0, radius, 0);

    path.lineTo(center - notchHalfWidth, 0);

    path.cubicTo(
      center - cp1x,
      0,
      center - cp2x,
      shallowDip,
      center - cp3x,
      midDip,
    );

    path.cubicTo(
      center - (cp3x * 0.54),
      deepDip,
      center - (cp3x * 0.31),
      deepDip,
      center,
      deepDip,
    );

    path.cubicTo(
      center + (cp3x * 0.31),
      deepDip,
      center + (cp3x * 0.54),
      deepDip,
      center + cp3x,
      midDip,
    );

    path.cubicTo(
      center + cp2x,
      shallowDip,
      center + cp1x,
      0,
      center + notchHalfWidth,
      0,
    );

    path.lineTo(width - radius, 0);

    path.quadraticBezierTo(width, 0, width, radius);

    path.lineTo(width, height - radius);

    path.quadraticBezierTo(width, height, width - radius, height);

    path.lineTo(radius, height);

    path.quadraticBezierTo(0, height, 0, height - radius);

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.fabSize != fabSize;
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final bool isDark;
  final double scale;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.isDark,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;

    final inactiveColor =
    isDark ? Colors.white.withOpacity(.88) : Colors.black.withOpacity(.85);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween(begin: .85, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                size: (selected ? 28 : 26) * scale,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
            SizedBox(height: 8 * scale),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: selected ? 18 * scale : 0,
              height: 4,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const _AddButton({
    super.key,
    required this.size,
    required this.onTap,
  });

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        scale: _pressed ? .92 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                Color.lerp(AppColors.primary, Colors.black, .15)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.35),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(.10),
                blurRadius: 4,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              PhosphorIcons.plus(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: widget.size * 0.555,
            ),
          ),
        ),
      ),
    );
  }
}