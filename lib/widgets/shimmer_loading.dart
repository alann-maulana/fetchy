import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/spacing.dart';

class RequestShimmer extends StatelessWidget {
  const RequestShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = colors.surfaceContainerHighest.withValues(alpha: 0.6);
    final highlight = colors.surfaceContainerHigh;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: Spacing.sm),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
            ),
            padding: EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(Spacing.chipRadius),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 14,
                        width: 180,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Container(
                        height: 11,
                        width: 240,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
