import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_mapping.dart';
import '../../../../core/theme/feva_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/feva_empty_state.dart';
import '../../../../core/widgets/feva_primary_button.dart';
import '../../../../core/widgets/feva_shimmer.dart';
import '../../../../domain/entities/product.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../providers/product_providers.dart';
import '../providers/recently_viewed_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId, this.heroTag});

  final int productId;
  final String? heroTag;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final colors = context.fevaColors;

    return productAsync.when(
      loading: () => const _ProductDetailSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: FevaErrorState(
          message: 'Unable to load this product.',
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
      data: (product) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(recentlyViewedProvider.notifier).add(product);
        });
        final wishlist = ref.watch(wishlistProvider);
        final isWishlisted = wishlist.contains(product.id);
        final relatedAsync = ref.watch(
          categoryProductsProvider(product.category),
        );

        return Scaffold(
          body: ResponsiveLayout(
            mobile: _buildMobile(product, colors, isWishlisted, relatedAsync),
            tablet: _buildTablet(product, colors, isWishlisted, relatedAsync),
          ),
          bottomNavigationBar: _StickyCartBar(
            price: product.price,
            quantity: _quantity,
            onAdd: () {
              ref
                  .read(cartProvider.notifier)
                  .addProduct(product, quantity: _quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added to bag'),
                  backgroundColor: colors.surfaceElevated,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'View Bag',
                    textColor: colors.accent,
                    onPressed: () => context.go('/cart'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMobile(
    Product product,
    FevaColorScheme colors,
    bool isWishlisted,
    AsyncValue relatedAsync,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 440,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              color: colors.cardBackground.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.pop(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.arrow_back, size: 20),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: colors.cardBackground.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () =>
                      ref.read(wishlistProvider.notifier).toggle(product.id),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(isWishlisted),
                        color: isWishlisted
                            ? colors.accent
                            : colors.primaryText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _Gallery(
              imageUrl: product.image,
              heroTag: widget.heroTag ?? 'product-${product.id}',
              index: _imageIndex,
              onPageChanged: (i) => setState(() => _imageIndex = i),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _ProductInfo(
            product: product,
            quantity: _quantity,
            onQuantityChanged: (q) => setState(() => _quantity = q),
          ),
        ),
        SliverToBoxAdapter(
          child: _RelatedSection(
            relatedAsync: relatedAsync,
            productId: product.id,
          ),
        ),
      ],
    );
  }

  Widget _buildTablet(
    Product product,
    FevaColorScheme colors,
    bool isWishlisted,
    AsyncValue relatedAsync,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? colors.accent : null,
              ),
              onPressed: () =>
                  ref.read(wishlistProvider.notifier).toggle(product.id),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 520,
                    child: _Gallery(
                      imageUrl: product.image,
                      heroTag: widget.heroTag ?? 'product-${product.id}',
                      index: _imageIndex,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 4,
                  child: _ProductInfo(
                    product: product,
                    quantity: _quantity,
                    onQuantityChanged: (q) => setState(() => _quantity = q),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _RelatedSection(
            relatedAsync: relatedAsync,
            productId: product.id,
          ),
        ),
      ],
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.imageUrl,
    required this.heroTag,
    required this.index,
    required this.onPageChanged,
  });

  final String imageUrl;
  final String heroTag;
  final int index;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final images = [imageUrl, imageUrl, imageUrl];
    final colors = context.fevaColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: colors.inputFill),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, i) {
                  final child = Container(
                    color: colors.inputFill,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const FevaShimmer(
                          child: ColoredBox(color: FevaColors.softBeige),
                        ),
                      ),
                    ),
                  );
                  if (i == 0) {
                    return Hero(tag: heroTag, child: child);
                  }
                  return child;
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: 26,
          left: 28,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library_rounded,
                  size: 16,
                  color: colors.secondaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gallery ${index + 1}/3',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i == index
                      ? FevaColors.champagneGold
                      : colors.secondaryText.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.fevaColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              CategoryMapping.displayName(product.category).toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 14),
          Text(product.title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 14),
          // Rating row
          Row(
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < product.rating.rate.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 18,
                  color: colors.accent,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${product.rating.rate.toStringAsFixed(1)}  ·  ${product.rating.count} reviews',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price
          Text(
            PriceFormatter.format(product.price),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          Divider(color: colors.divider),
          const SizedBox(height: 20),
          // Description
          Text(
            'Product Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.secondaryText),
          ),
          const SizedBox(height: 24),
          Divider(color: colors.divider),
          const SizedBox(height: 20),
          // Specifications
          Text(
            'Product Specifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _SpecRow(label: 'Material', value: 'Premium quality materials'),
          _SpecRow(label: 'Style', value: 'Contemporary design'),
          _SpecRow(
            label: 'Category',
            value: CategoryMapping.displayName(product.category),
          ),
          const SizedBox(height: 24),
          Divider(color: colors.divider),
          const SizedBox(height: 20),
          // Quantity selector
          Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              _QtyBtn(
                icon: Icons.remove_rounded,
                onTap: quantity > 1
                    ? () => onQuantityChanged(quantity - 1)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$quantity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _QtyBtn(
                icon: Icons.add_rounded,
                onTap: () => onQuantityChanged(quantity + 1),
              ),
            ],
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fevaColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap == null ? colors.divider : colors.accent,
            width: onTap == null ? 1 : 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: onTap == null
              ? Colors.transparent
              : colors.accent.withValues(alpha: 0.06),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? colors.secondaryText : colors.primaryText,
        ),
      ),
    );
  }
}

class _StickyCartBar extends StatelessWidget {
  const _StickyCartBar({
    required this.price,
    required this.quantity,
    required this.onAdd,
  });

  final double price;
  final int quantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.fevaColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  PriceFormatter.format(price * quantity),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FevaPrimaryButton(label: 'Add to Bag', onPressed: onAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedSection extends StatelessWidget {
  const _RelatedSection({required this.relatedAsync, required this.productId});

  final AsyncValue relatedAsync;
  final int productId;

  @override
  Widget build(BuildContext context) {
    return relatedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (products) {
        final related = products
            .where((p) => p.id != productId)
            .take(6)
            .toList();
        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'You May Also Like',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: related.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final p = related[index];
                  return SizedBox(
                    width: 160,
                    child: GestureDetector(
                      onTap: () => context.pushReplacement('/product/${p.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: context.fevaColors.cardBackground,
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
                                  imageUrl: p.image,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            PriceFormatter.format(p.price),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: context.fevaColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ProductDetailSkeleton extends StatelessWidget {
  const _ProductDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: FevaSkeletonBox(
            width: double.infinity,
            height: 440,
            radius: 0,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FevaSkeletonBox(width: 80, height: 26, radius: 20),
                SizedBox(height: 14),
                FevaSkeletonBox(width: double.infinity, height: 34),
                SizedBox(height: 8),
                FevaSkeletonBox(width: 200, height: 34),
                SizedBox(height: 16),
                FevaSkeletonBox(width: 120, height: 16),
                SizedBox(height: 16),
                FevaSkeletonBox(width: 100, height: 28),
                SizedBox(height: 28),
                FevaSkeletonBox(width: double.infinity, height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
