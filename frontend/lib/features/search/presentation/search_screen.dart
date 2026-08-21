import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/feva_colors.dart';
import '../../../core/widgets/feva_empty_state.dart';
import '../../../core/widgets/feva_shimmer.dart';
import '../../products/presentation/providers/product_providers.dart';
import 'providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
    _controller.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recents = ref.watch(recentSearchesProvider);
    final colors = context.fevaColors;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search collections, pieces...',
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) =>
              ref.read(recentSearchesProvider.notifier).add(value),
        ),
      ),
      body: query.isEmpty
          ? _SuggestionsView(
              recents: recents,
              onSelect: (value) {
                _controller.text = value;
                ref.read(searchQueryProvider.notifier).state = value;
                ref.read(recentSearchesProvider.notifier).add(value);
              },
              onClearRecents: () =>
                  ref.read(recentSearchesProvider.notifier).clear(),
            )
          : resultsAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: 6,
                itemBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      FevaSkeletonBox(width: 72, height: 72, radius: 8),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FevaSkeletonBox(width: double.infinity, height: 14),
                            SizedBox(height: 8),
                            FevaSkeletonBox(width: 80, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              error: (e, _) => FevaErrorState(
                message: 'Search unavailable.',
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (results) {
                if (results.isEmpty) {
                  return const FevaEmptyState(
                    title: 'No pieces found',
                    subtitle: 'Try searching with different keywords.',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: results.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: colors.divider, height: 24),
                  itemBuilder: (context, index) {
                    final product = results[index];
                    return InkWell(
                      onTap: () => context.push('/product/${product.id}'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    ColoredBox(color: colors.inputFill),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.category,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SuggestionsView extends StatelessWidget {
  const _SuggestionsView({
    required this.recents,
    required this.onSelect,
    required this.onClearRecents,
  });

  final List<String> recents;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearRecents;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (recents.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: onClearRecents, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 8),
          ...recents.map(
            (term) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, size: 20),
              title: Text(term),
              onTap: () => onSelect(term),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text('Trending', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchSuggestions
              .map(
                (s) => ActionChip(
                  label: Text(s),
                  onPressed: () => onSelect(s),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
