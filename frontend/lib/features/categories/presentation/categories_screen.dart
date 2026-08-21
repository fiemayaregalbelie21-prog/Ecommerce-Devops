import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/category_mapping.dart';
import '../../../core/theme/feva_colors.dart';
import '../../../core/widgets/feva_empty_state.dart';
import '../../../core/widgets/feva_shimmer.dart';
import '../../products/presentation/providers/product_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            FevaSkeletonBox(width: double.infinity, height: 160),
            SizedBox(height: 12),
            FevaSkeletonBox(width: double.infinity, height: 160),
          ],
        ),
        error: (e, _) => FevaErrorState(
          message: 'Unable to load collections.',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const FevaEmptyState(
              title: 'No collections yet',
              subtitle: 'Our showroom is being curated.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CollectionRow(category: category);
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/category/${Uri.encodeComponent(category)}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: context.fevaColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CategoryMapping.displayName(category),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CategoryMapping.description(category),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: context.fevaColors.accent),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String _selectedSort = 'featured';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.fevaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sort by',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _SortOption(
                label: 'Featured',
                value: 'featured',
                selectedValue: _selectedSort,
                onTap: (value) => setState(() => _selectedSort = value),
              ),
              _SortOption(
                label: 'Price: Low to High',
                value: 'price_low',
                selectedValue: _selectedSort,
                onTap: (value) => setState(() => _selectedSort = value),
              ),
              _SortOption(
                label: 'Price: High to Low',
                value: 'price_high',
                selectedValue: _selectedSort,
                onTap: (value) => setState(() => _selectedSort = value),
              ),
              _SortOption(
                label: 'Newest',
                value: 'newest',
                selectedValue: _selectedSort,
                onTap: (value) => setState(() => _selectedSort = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selectedValue;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.fevaColors.divider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.fevaColors.accent
                      : context.fevaColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.fevaColors.accent,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? context.fevaColors.primaryText
                    : context.fevaColors.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
