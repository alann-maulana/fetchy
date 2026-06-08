import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundBlobs extends StatelessWidget {
  final Widget child;

  const BackgroundBlobs({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isDark) {
      return child;
    }

    return Stack(
      children: [
        // Blob 1: Violet top-left
        Positioned(
          top: -100,
          left: -100,
          width: 300,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            ),
          ),
        ),
        // Blob 2: Cyan bottom-right
        Positioned(
          bottom: -80,
          right: -80,
          width: 280,
          height: 280,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF06B6D4).withValues(alpha: 0.06),
            ),
          ),
        ),
        // Blur filter to make them smooth background gradients
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: const SizedBox.shrink(),
          ),
        ),
        child,
      ],
    );
  }
}
