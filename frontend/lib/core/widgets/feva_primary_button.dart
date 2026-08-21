import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/feva_colors.dart';

class FevaPrimaryButton extends StatefulWidget {
  const FevaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = FevaButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final FevaButtonVariant variant;

  @override
  State<FevaPrimaryButton> createState() => _FevaPrimaryButtonState();
}

enum FevaButtonVariant { primary, gold, outline }

class _FevaPrimaryButtonState extends State<FevaPrimaryButton> {
  bool _success = false;

  Future<void> _handlePress() async {
    if (widget.onPressed == null || widget.isLoading) return;
    widget.onPressed!();
    if (widget.label.toLowerCase().contains('add to cart')) {
      setState(() => _success = true);
      await Future<void>.delayed(AppConstants.animationMedium);
      if (mounted) setState(() => _success = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = switch (widget.variant) {
      FevaButtonVariant.primary =>
        isDark ? FevaColors.champagneGold : FevaColors.espressoBrown,
      FevaButtonVariant.gold => FevaColors.champagneGold,
      FevaButtonVariant.outline => Colors.transparent,
    };
    final fg = switch (widget.variant) {
      FevaButtonVariant.primary =>
        isDark ? FevaColors.espressoBrown : FevaColors.ivoryWhite,
      FevaButtonVariant.gold => FevaColors.espressoBrown,
      FevaButtonVariant.outline => FevaColors.champagneGold,
    };

    return AnimatedContainer(
      duration: AppConstants.animationFast,
      child: Material(
        color: _success ? FevaColors.success : bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.isLoading ? null : _handlePress,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: widget.variant == FevaButtonVariant.outline
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: FevaColors.champagneGold),
                  )
                : null,
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                : AnimatedSwitcher(
                    duration: AppConstants.animationFast,
                    child: _success
                        ? Icon(Icons.check_rounded, key: const ValueKey('ok'), color: fg)
                        : Text(
                            widget.label,
                            key: const ValueKey('label'),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: widget.variant == FevaButtonVariant.outline
                                      ? FevaColors.champagneGold
                                      : fg,
                                  letterSpacing: 0.5,
                                ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}