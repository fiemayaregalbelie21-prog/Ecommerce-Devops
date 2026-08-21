import '../../repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  Future call(int productId) async {
    final items = _repository.getItems();
    final updated = items.where((item) => item.product.id != productId).toList();
    await _repository.saveItems(updated);
  }
}
