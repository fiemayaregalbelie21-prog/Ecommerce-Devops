import '../../repositories/product_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<String>> call() {
    return _repository.getCategories();
  }
}
