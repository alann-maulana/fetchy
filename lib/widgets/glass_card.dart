import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final radius = borderRadius ?? Spacing.cardRadius;
    final borderStyle = border ?? Border.all(
      color: isDark 
        ? const Color(0xFF7C3AED).withValues(alpha: 0.15) 
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      width: 1.0,
    );

    final cardBg = isDark
        ? const Color(0xFF13132B).withValues(alpha: 0.75)
        : theme.colorScheme.surface.withValues(alpha: 0.9);

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: borderStyle,
      ),
      padding: padding ?? const EdgeInsets.all(Spacing.lg),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: cardContent,
      );
    }

    if (isDark) {
      return Card(
        margin: margin ?? EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
        elevation: 0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: cardContent,
          ),
        ),
      );
    } else {
      return Card(
        margin: margin ?? EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: cardContent,
      );
    }
  }
}
