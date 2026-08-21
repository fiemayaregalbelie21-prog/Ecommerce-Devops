import '../../entities/cart_item.dart';
import '../../entities/product.dart';
import '../../repositories/cart_repository.dart';

class AddToCartUseCase {
  AddToCartUseCase(this._repository);

  final CartRepository _repository;

  Future call(Product product, {int quantity = 1}) async {
    final items = _repository.getItems();
    final index = items.indexWhere((item) => item.product.id == product.id);
    
    List<CartItem> updated;
    if (index >= 0) {
      updated = [
        ...items.sublist(0, index),
        items[index].copyWith(quantity: items[index].quantity + quantity),
        ...items.sublist(index + 1),
      ];
    } else {
      updated = [...items, CartItem(product: product, quantity: quantity)];
    }
    
    await _repository.saveItems(updated);
  }
}
