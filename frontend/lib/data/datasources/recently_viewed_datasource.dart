import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/product.dart';

class RecentlyViewedDataSource {
  RecentlyViewedDataSource();

  static const String _boxName = 'feva_recents';
  Box<Product>? _cachedBox;

  Box<Product> _getBox() {
    _cachedBox ??= Hive.box<Product>(_boxName);
    return _cachedBox!;
  }

  List<Product> getItems() {
    return _getBox().values.toList();
  }

  Future<void> saveItems(List<Product> items) async {
    final box = _getBox();
    await box.clear();
    await box.addAll(items);
  }

  Future<void> clear() async {
    await _getBox().clear();
  }
}
