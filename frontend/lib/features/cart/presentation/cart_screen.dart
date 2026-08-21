import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/feva_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/feva_empty_state.dart';
import '../../../core/widgets/feva_primary_button.dart';
import './providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).subtotal;
    final colors = context.fevaColors;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Bag')),
        body: FevaEmptyState(
          title: 'Your bag is empty',
          subtitle: 'Add pieces you love and find them here.',
          actionLabel: 'Browse Collections',
          onAction: () => context.go('/categories'),
          icon: Icons.shopping_bag_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Bag')),
      bottomNavigationBar: _CheckoutBar(
        subtotal: subtotal,
        onCheckout: () => context.push('/checkout'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(color: colors.divider, height: 32),
        itemBuilder: (context, index) {
          final item = items[index];
          return Dismissible(
            key: ValueKey(item.product.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: FevaColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: FevaColors.error),
            ),
            onDismissed: (_) {
              ref.read(cartProvider.notifier).removeProduct(item.product.id);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colors.cardBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.product.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PriceFormatter.format(item.product.price),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QtyBtn(
                            icon: Icons.remove_rounded,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(
                                    item.product.id, item.quantity - 1),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${item.quantity}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          _QtyBtn(
                            icon: Icons.add_rounded,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(
                                    item.product.id, item.quantity + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.subtotal, required this.onCheckout});

  final double subtotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final colors = context.fevaColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Subtotal',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    PriceFormatter.format(subtotal),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FevaPrimaryButton(
              label: 'Checkout',
              onPressed: onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: context.fevaColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.fevaColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FevaColors.success.withValues(alpha: 0.1),
                border: Border.all(
                  color: FevaColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.check_rounded,
                  color: FevaColors.success, size: 44),
            ),
            const SizedBox(height: 28),
            Text(
              'Thank you for your order',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your order will be dispatched with care.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FevaPrimaryButton(
              label: 'Continue Shopping',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
