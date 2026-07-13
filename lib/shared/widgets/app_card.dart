import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// A styled container card with optional header, gradient, and tap handler.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? borderRadius;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = borderRadius ?? AppSizes.radiusLg;

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Theme.of(context).cardTheme.color ?? cs.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: gradient == null
            ? [
                BoxShadow(
                  color: cs.brightness == Brightness.light
                      ? Colors.black.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
        border: border != null
            ? Border.fromBorderSide(border!)
            : Border.all(
                color: cs.brightness == Brightness.light
                    ? Colors.black.withValues(alpha: 0.03)
                    : cs.outlineVariant.withValues(alpha: 0.15),
                width: 1,
              ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }

    return content;
  }
}

/// A gradient card commonly used on the dashboard.
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: gradient,
      padding: padding,
      onTap: onTap,
      border: BorderSide.none,
      child: child,
    );
  }
}
