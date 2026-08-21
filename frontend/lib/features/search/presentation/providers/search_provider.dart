import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/datasources/search_local_datasource.dart';
import '../../../../domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchLocalDataSourceProvider = Provider<SearchLocalDataSource>(
  (ref) => SearchLocalDataSource(),
);

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
      final dataSource = ref.watch(searchLocalDataSourceProvider);
      return RecentSearchesNotifier(dataSource);
    });

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier(this._dataSource) : super(_dataSource.loadSearches());

  final SearchLocalDataSource _dataSource;

  void add(String term) {
    if (term.isEmpty) return;
    state = [term, ...state.where((s) => s != term)].take(10).toList();
    _saveRecentSearches();
  }

  void clear() {
    state = [];
    _saveRecentSearches();
  }

  void _saveRecentSearches() {
    _dataSource.saveSearches(state);
  }
}

final searchResultsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  final allProducts = await ref.watch(productsProvider.future);
  return allProducts
      .where(
        (p) =>
            p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query),
      )
      .toList();
});

const searchSuggestions = ['Jacket', 'Dress', 'Necklace', 'Earrings', 'Shirt', 'Ring'];
