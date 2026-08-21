import '../../core/storage/hive_service.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartLocalDataSource implements CartRepository {
  static const _cartKey = 'items';

  @override
  List<CartItem> getItems() {
    final raw = HiveService.cartBox.get(_cartKey);
    if (raw == null) return [];

    final list = raw['entries'] as List?;
    if (list == null) return [];

    return list
        .cast<Map>()
        .map((e) => CartItem.fromJson(Map<dynamic, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveItems(List<CartItem> items) async {
    await HiveService.cartBox.put(_cartKey, {
      'entries': items.map((e) => e.toJson()).toList(),
    });
  }
}
