import '../entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> getItems();
  Future<void> saveItems(List<CartItem> items);
}
