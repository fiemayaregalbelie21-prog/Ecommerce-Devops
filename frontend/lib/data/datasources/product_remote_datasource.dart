import 'package:dio/dio.dart';

import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get<List<dynamic>>('/products');
    return _parseList(response.data);
  }

  Future<Product> fetchProduct(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return ProductModel.fromJson(response.data!);
  }

  Future<List<String>> fetchCategories() async {
    final response = await _dio.get<List<dynamic>>('/products/categories');
    return response.data!.cast<String>();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await _dio.get<List<dynamic>>(
      '/products/category/${Uri.encodeComponent(category)}',
    );
    return _parseList(response.data);
  }

  List<Product> _parseList(List<dynamic>? data) {
    return data!
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }
}
