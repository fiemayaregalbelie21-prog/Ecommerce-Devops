import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;
  List<Product>? _cache;

  @override
  Future<List<Product>> getProducts() async {
    _cache ??= await _remote.fetchProducts();
    return _cache!;
  }

  @override
  Future<Product> getProduct(int id) => _remote.fetchProduct(id);

  @override
  Future<List<String>> getCategories() => _remote.fetchCategories();

  @override
  Future<List<Product>> getProductsByCategory(String category) =>
      _remote.fetchProductsByCategory(category);

  @override
  Future<void> clearCache() async {
    _cache = null;
  }
}
