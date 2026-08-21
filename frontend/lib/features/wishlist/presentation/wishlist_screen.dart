import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/feva_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/feva_empty_state.dart';
import '../../products/presentation/providers/product_providers.dart';
import '../../products/presentation/widgets/feva_product_card.dart';
import 'providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          if (wishlistIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: FevaColors.champagneGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FevaColors.champagneGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${wishlistIds.length} saved',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: FevaColors.champagneGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wishlist',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A refined selection of the pieces you love.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.fevaColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (wishlistIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FevaColors.champagneGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${wishlistIds.length} items',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: FevaColors.champagneGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveLayout.gridCrossAxisCount(context),
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.58,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const _WishlistSkeletonCard(),
              ),
              error: (error, stack) => FevaErrorState(
                message: 'Could not load wishlist',
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (products) {
                if (wishlistIds.isEmpty) {
                  return FevaEmptyState(
                    title: 'No favourites yet',
                    subtitle: 'Save items you love and find them here anytime.',
                    actionLabel: 'Browse Collection',
                    onAction: () => context.go('/categories'),
                    icon: Icons.favorite_border_rounded,
                  );
                }

                final wishlistProducts = products
                    .where((product) => wishlistIds.contains(product.id))
                    .toList();

                if (wishlistProducts.isEmpty) {
                  return FevaEmptyState(
                    title: 'Wishlist is empty',
                    subtitle: 'The items you saved are no longer available.',
                    actionLabel: 'Browse categories',
                    onAction: () => context.go('/categories'),
                    icon: Icons.remove_shopping_cart_outlined,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                      context,
                    ),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: wishlistProducts.length,
                  itemBuilder: (context, index) {
                    return FevaProductCard(product: wishlistProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistSkeletonCard extends StatelessWidget {
  const _WishlistSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.fevaColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: context.fevaColors.divider,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: 70,
          decoration: BoxDecoration(
            color: context.fevaColors.divider,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
