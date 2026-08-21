import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(int id);
  Future<List<String>> getCategories();
  Future<List<Product>> getProductsByCategory(String category);
  Future<void> clearCache();
}
