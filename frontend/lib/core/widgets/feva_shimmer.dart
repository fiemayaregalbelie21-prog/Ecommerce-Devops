import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/feva_colors.dart';

class FevaShimmer extends StatelessWidget {
  const FevaShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? FevaColors.darkElevated : FevaColors.softBeige,
      highlightColor: isDark ? FevaColors.darkSurface : FevaColors.ivoryWhite,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

class FevaSkeletonBox extends StatelessWidget {
  const FevaSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return FevaShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: FevaColors.softBeige,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}