import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_mapping.dart';
import '../../../../core/theme/feva_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/feva_shimmer.dart';
import '../../../../domain/entities/product.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';

class FevaProductCard extends ConsumerStatefulWidget {
  const FevaProductCard({
    super.key,
    required this.product,
    this.heroTag,
    this.layout = FevaProductCardLayout.grid,
  });

  final Product product;
  final String? heroTag;
  final FevaProductCardLayout layout;

  @override
  ConsumerState<FevaProductCard> createState() => _FevaProductCardState();
}

class _FevaProductCardState extends ConsumerState<FevaProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(widget.product.id);

    if (widget.layout == FevaProductCardLayout.editorial) {
      return _EditorialCard(
        product: widget.product,
        heroTag: widget.heroTag,
        isWishlisted: isWishlisted,
        onWishlist: () =>
            ref.read(wishlistProvider.notifier).toggle(widget.product.id),
        onTap: () => context.push(
          '/product/${widget.product.id}',
          extra: widget.heroTag,
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push('/product/${widget.product.id}', extra: widget.heroTag);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with shadow
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: context.fevaColors.inputFill,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: widget.heroTag ?? 'product-${widget.product.id}',
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _ProductImage(imageUrl: widget.product.image),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _WishlistButton(
                          isActive: isWishlisted,
                          onTap: () => ref
                              .read(wishlistProvider.notifier)
                              .toggle(widget.product.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Category label
              Text(
                CategoryMapping.displayName(
                  widget.product.category,
                ).toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1,
                  color: context.fevaColors.secondaryText,
                ),
              ),
              const SizedBox(height: 3),
              // Product title
              Text(
                widget.product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              // Price + rating row
              Row(
                children: [
                  Text(
                    PriceFormatter.format(widget.product.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.fevaColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Star rating mini
                  Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: context.fevaColors.accent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.product.rating.rate.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.fevaColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FevaProductCardLayout { grid, editorial }

class _EditorialCard extends StatelessWidget {
  const _EditorialCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlist,
    required this.onTap,
    this.heroTag,
  });

  final Product product;
  final bool isWishlisted;
  final VoidCallback onWishlist;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.fevaColors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: heroTag ?? 'product-${product.id}',
                    child: _ProductImage(imageUrl: product.image),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CategoryMapping.displayName(product.category).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  PriceFormatter.format(product.price),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.fevaColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // Star row
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      return Icon(
                        i < product.rating.rate.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 15,
                        color: context.fevaColors.accent,
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '(${product.rating.count})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain, // contain so white-bg product images look clean
      placeholder: (_, _) =>
          const FevaShimmer(child: ColoredBox(color: FevaColors.softBeige)),
      errorWidget: (_, _, _) => ColoredBox(
        color: context.fevaColors.inputFill,
        child: Icon(
          Icons.image_outlined,
          color: context.fevaColors.secondaryText,
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isActive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isActive),
              color: isActive ? FevaColors.champagneGold : FevaColors.warmGray,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
