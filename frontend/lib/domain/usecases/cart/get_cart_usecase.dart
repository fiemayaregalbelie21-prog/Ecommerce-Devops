import '../../entities/cart_item.dart';
import '../../repositories/cart_repository.dart';

class GetCartUseCase {
  GetCartUseCase(this._repository);

  final CartRepository _repository;

  List<CartItem> call() {
    return _repository.getItems();
  }
}
