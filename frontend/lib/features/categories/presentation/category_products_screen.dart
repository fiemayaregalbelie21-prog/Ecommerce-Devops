import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/category_mapping.dart';
import '../../../core/theme/feva_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/feva_empty_state.dart';
import '../../../core/widgets/feva_refresh_indicator.dart';
import '../../products/presentation/providers/product_providers.dart';
import '../../products/presentation/widgets/feva_product_card.dart';

class CategoryProductsScreen extends ConsumerWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(categoryProductsProvider(category));
    final sortOption = ref.watch(productSortProvider);
    final displayName = CategoryMapping.displayName(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          PopupMenuButton<ProductSortOption>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) =>
                ref.read(productSortProvider.notifier).state = value,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ProductSortOption.featured,
                child: Text('Featured'),
              ),
              const PopupMenuItem(
                value: ProductSortOption.priceLow,
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: ProductSortOption.priceHigh,
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: ProductSortOption.rating,
                child: Text('Rating'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                sortOption.name.replaceAll(RegExp(r'([A-Z])'), r' \1').trim(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.fevaColors.divider),
        ),
      ),
      body: FevaGoldRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoryProductsProvider(category));
        },
        child: productsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.fevaColors.secondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load ${displayName.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(categoryProductsProvider(category)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return FevaEmptyState(
                title: 'No pieces in $displayName',
                subtitle: 'Check back soon for new arrivals.',
                icon: Icons.inventory_2_outlined,
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCrossAxisCount(context),
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return FevaProductCard(
                  product: products[index],
                  heroTag: 'category-${products[index].id}',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
