import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/product.dart';
import '../../../../data/datasources/recently_viewed_datasource.dart';

final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<Product>>((ref) {
  final dataSource = RecentlyViewedDataSource();
  return RecentlyViewedNotifier(dataSource);
});

class RecentlyViewedNotifier extends StateNotifier<List<Product>> {
  RecentlyViewedNotifier(this._dataSource) : super([]) {
    _loadRecentlyViewed();
  }

  final RecentlyViewedDataSource _dataSource;

  Future<void> _loadRecentlyViewed() async {
    final items = _dataSource.getItems();
    Future.microtask(() => state = items);
  }

  void add(Product product) {
    state = state.where((p) => p.id != product.id).toList();
    state = [product, ...state].take(20).toList();
    _saveRecentlyViewed();
  }

  Future<void> _saveRecentlyViewed() async {
    await _dataSource.saveItems(state);
  }
}
