import 'package:flutter/material.dart';
import '../theme/feva_colors.dart';

class FevaEmptyState extends StatelessWidget {
  const FevaEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.shopping_bag_outlined,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FevaColorScheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FevaColors.champagneGold.withValues(alpha: 0.08),
                border: Border.all(
                  color: FevaColors.champagneGold.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 38,
                color: FevaColors.champagneGold,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: FevaColors.champagneGold,
                  side: BorderSide(
                    color: FevaColors.champagneGold.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FevaErrorState extends StatelessWidget {
  const FevaErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FevaEmptyState(
      title: 'Something went wrong',
      subtitle: message,
      actionLabel: 'Try Again',
      onAction: onRetry,
      icon: Icons.refresh_rounded,
    );
  }
}