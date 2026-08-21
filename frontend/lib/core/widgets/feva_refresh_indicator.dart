import 'package:flutter/material.dart';
import '../theme/feva_colors.dart';

class FevaGoldRefreshIndicator extends StatelessWidget {
  const FevaGoldRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: FevaColors.champagneGold,
      backgroundColor: context.fevaColors.surface,
      strokeWidth: 2,
      child: child,
    );
  }
}