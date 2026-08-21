import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProductDetailUseCase {
  GetProductDetailUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call(int id) {
    return _repository.getProduct(id);
  }
}
