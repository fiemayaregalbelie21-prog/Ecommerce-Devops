import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/hive_service.dart';

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, Set<int>>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<Set<int>> {
  WishlistNotifier() : super({}) {
    _load();
  }

  static const _key = 'wishlist';

  void _load() {
    final data = HiveService.wishlistBox.get(_key) as List?;
    if (data != null) {
      state = Set<int>.from(data.cast<int>());
    }
  }

  Future<void> _save() async {
    await HiveService.wishlistBox.put(_key, state.toList());
  }

  Future<void> toggle(int productId) async {
    if (state.contains(productId)) {
      state = Set.from(state)..remove(productId);
    } else {
      state = Set.from(state)..add(productId);
    }
    await _save();
  }

  Future<void> add(int productId) async {
    if (!state.contains(productId)) {
      state = Set.from(state)..add(productId);
      await _save();
    }
  }

  Future<void> remove(int productId) async {
    if (state.contains(productId)) {
      state = Set.from(state)..remove(productId);
      await _save();
    }
  }
}
