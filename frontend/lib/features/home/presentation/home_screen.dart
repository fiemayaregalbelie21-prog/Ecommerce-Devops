import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_mapping.dart';
import '../../../core/theme/feva_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/feva_empty_state.dart';
import '../../../core/widgets/feva_refresh_indicator.dart';
import '../../../core/widgets/feva_shimmer.dart';
import '../../../domain/entities/product.dart';
import '../../products/presentation/providers/product_providers.dart';
import '../../products/presentation/providers/recently_viewed_provider.dart';
import '../../products/presentation/widgets/feva_product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const _HomeSkeleton(),
      error: (e, _) => FevaErrorState(
        message: 'We couldn\'t load the collection.',
        onRetry: () => ref.invalidate(productsProvider),
      ),
      data: (products) => _HomeContent(products: products),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newArrivals = products.reversed.take(6).toList();
    final topPicks = [...products]
      ..sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
    final recommended = topPicks.take(6).toList();
    final topSix = topPicks.take(4).toList();
    final trending = products.take(6).toList();
    final recents = ref.watch(recentlyViewedProvider);

    return FevaGoldRefreshIndicator(
      onRefresh: () async => ref.invalidate(productsProvider),
      child: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(AppConstants.appName),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: () => context.push('/wishlist'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.fevaColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.fevaColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: context.fevaColors.secondaryText,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Search exclusive styles',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: context.fevaColors.secondaryText,
                              ),
                        ),
                      ),
                      Text(
                        'Search',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.fevaColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: _WelcomeHeader()),

          // Hero carousel
          const SliverToBoxAdapter(child: _HeroCarousel()),

          // Recommended for you
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Recommended for you',
              subtitle: 'Handpicked pieces from our latest edit',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recommended.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final product = recommended[index];
                  return SizedBox(
                    width: 186,
                    child: FevaProductCard(
                      product: product,
                      heroTag: 'recommended-${product.id}',
                    ),
                  );
                },
              ),
            ),
          ),

          // New Arrivals horizontal scroll
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'New in Store',
              subtitle: 'Fresh arrivals selected for you',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: newArrivals.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final product = newArrivals[index];
                  return SizedBox(
                    width: 186,
                    child: FevaProductCard(
                      product: product,
                      heroTag: 'arrivals-${product.id}',
                    ),
                  );
                },
              ),
            ),
          ),

          // Trending categories
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Trending Categories',
              subtitle: 'Explore our most sought-after collections',
              actionLabel: 'View All',
              onAction: () => context.go('/categories'),
            ),
          ),
          const SliverToBoxAdapter(child: _CategoryGrid()),

          // Nova brand strip
          const SliverToBoxAdapter(child: _NovaBrandStrip()),

          // Editorial edit
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Editor\'s Edit',
              subtitle: 'A refined selection of the season\'s favourites',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: topSix.length,
              separatorBuilder: (_, _) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                return FevaProductCard(
                  product: topSix[index],
                  layout: FevaProductCardLayout.editorial,
                );
              },
            ),
          ),

          // Popular products
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Popular Now',
              subtitle: 'In-demand pieces from our curated collection',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCrossAxisCount(context),
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => FevaProductCard(product: trending[index]),
                childCount: trending.length,
              ),
            ),
          ),

          // Recently viewed
          if (recents.isNotEmpty) ...[
            SliverToBoxAdapter(child: _SectionHeader(title: 'Recently Viewed')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recents.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 160,
                      child: FevaProductCard(product: recents[index]),
                    );
                  },
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Hero Carousel ──────────────────────────────────────────────────────────

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  static const _banners = [
    _BannerData(
      imageUrl:
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=1200',
      title: 'Wear Your Story',
      subtitle: 'Discover our curated fashion collection',
      cta: 'Shop Now',
    ),
    _BannerData(
      imageUrl:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200',
      title: 'New Season Edit',
      subtitle: 'Premium styles for the modern wardrobe',
      cta: 'Explore',
    ),
    _BannerData(
      imageUrl:
          'https://images.unsplash.com/photo-1445205170230-053b83016050?w=1200',
      title: 'Fine Jewellery',
      subtitle: 'Statement pieces crafted to perfection',
      cta: 'Discover',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_controller.hasClients) {
        final next = (_currentPage + 1) % _banners.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 240,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: _banners.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return _BannerSlide(
                    data: _banners[index],
                    onTap: () => context.go('/categories'),
                  );
                },
              ),
              // Page indicators
              Positioned(
                bottom: 16,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_banners.length, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? FevaColors.champagneGold
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Nova Store',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: context.fevaColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A carefully curated edit of premium fashion, lifestyle, and everyday essentials.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.fevaColors.secondaryText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _FeatureChip(label: 'New arrivals'),
              SizedBox(width: 10),
              _FeatureChip(label: 'Best sellers'),
              SizedBox(width: 10),
              _FeatureChip(label: 'Luxury edit'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.fevaColors.cardBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.fevaColors.divider),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.fevaColors.secondaryText,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String cta;
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.data, required this.onTap});

  final _BannerData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            data.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                ColoredBox(color: context.fevaColors.inputFill),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.transparent,
                  FevaColors.espressoBrown.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: FevaColors.ivoryWhite,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FevaColors.ivoryWhite.withValues(alpha: 0.80),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      data.cta,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: FevaColors.champagneGold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward,
                      color: FevaColors.champagneGold,
                      size: 14,
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

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

// ── Category Grid ──────────────────────────────────────────────────────────

class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: FevaSkeletonBox(width: double.infinity, height: 200),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (categories) {
        // Filter to show only clothing categories
        final clothingCategories = categories.where((cat) =>
          cat.toLowerCase().contains('clothing')).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveLayout.isMobile(context) ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: clothingCategories.length,
            itemBuilder: (context, index) {
              final category = clothingCategories[index];
              return _CategoryTile(category: category);
            },
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({required this.category});

  final String category;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;

  static const _images = {
    "electronics":
        'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=600',
    "jewelery":
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600',
    "men's clothing":
        'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=600',
    "women's clothing":
        'https://images.unsplash.com/photo-1581338834647-b0fb40704e21?w=600',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push('/category/${Uri.encodeComponent(widget.category)}');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _images[widget.category] ?? _images.values.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: context.fevaColors.inputFill),
              ),
              // Gold-to-dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      FevaColors.espressoBrown.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              // Text content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      CategoryMapping.displayName(widget.category),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: FevaColors.ivoryWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CategoryMapping.description(widget.category),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FevaColors.ivoryWhite.withValues(alpha: 0.75),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nova Brand Strip ───────────────────────────────────────────────────────

class _NovaBrandStrip extends StatelessWidget {
  const _NovaBrandStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FevaColors.espressoBrown.withValues(alpha: 0.95),
            FevaColors.espressoBrown.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signature Selection',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FevaColors.champagneGold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A premium edit of modern essentials.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: FevaColors.pureWhite,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: FevaColors.champagneGold, width: 1.2),
            ),
            child: const Center(
              child: Icon(
                Icons.star_rounded,
                color: FevaColors.champagneGold,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        FevaSkeletonBox(width: double.infinity, height: 240, radius: 16),
        SizedBox(height: 32),
        FevaSkeletonBox(width: 160, height: 24),
        SizedBox(height: 16),
        FevaSkeletonBox(width: double.infinity, height: 290, radius: 12),
        SizedBox(height: 32),
        FevaSkeletonBox(width: 200, height: 24),
        SizedBox(height: 16),
        FevaSkeletonBox(width: double.infinity, height: 200, radius: 12),
      ],
    );
  }
}
