import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/feva_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../products/presentation/providers/product_providers.dart';
import '../../products/presentation/providers/recently_viewed_provider.dart';
import '../../products/presentation/widgets/feva_product_card.dart';
import '../../settings/presentation/providers/theme_provider.dart';
import '../../wishlist/presentation/providers/wishlist_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final user = auth.valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final recents = ref.watch(recentlyViewedProvider);
    final wishlistIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productsProvider);
    final colors = context.fevaColors;
    final initials = (user?.name.isNotEmpty == true ? user!.name[0] : 'G')
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.divider, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FevaColors.champagneGold.withValues(alpha: 0.12),
                    border: Border.all(
                      color: FevaColors.champagneGold.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: FevaColors.champagneGold,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Not signed in',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: FevaColors.champagneGold.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${AppConstants.appName} Member · 2026',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: FevaColors.champagneGold,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Saved Items',
                  value: '${wishlistIds.length}',
                  icon: Icons.favorite_border_rounded,
                  onTap: () => context.push('/wishlist'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Recently Viewed',
                  value: '${recents.length}',
                  icon: Icons.history_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences section
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider, width: 0.5),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Elegant dark theme'),
              value: themeMode == ThemeMode.dark,
              activeThumbColor: FevaColors.champagneGold,
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Wishlist preview
          if (wishlistIds.isNotEmpty)
            productsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (products) {
                final wishlistProducts = products
                    .where((p) => wishlistIds.contains(p.id))
                    .toList();
                if (wishlistProducts.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved Items',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () => context.push('/wishlist'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: wishlistProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 160,
                            child: FevaProductCard(
                              product: wishlistProducts[index],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

          // Sign out button
          OutlinedButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: FevaColors.error,
              side: const BorderSide(color: FevaColors.error),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign Out'),
          ),

          const SizedBox(height: 24),

          // Brand footer
          Center(
            child: Column(
              children: [
                Text(
                  AppConstants.appName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 4,
                    color: FevaColors.champagneGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.tagline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fevaColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.accent, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
