import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../domain/entities/product.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  return useCase();
});

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) async {
  final useCase = ref.watch(getProductDetailUseCaseProvider);
  return useCase(id);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase();
});

final categoryProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, category) async {
  final useCase = ref.watch(getProductsByCategoryUseCaseProvider);
  return useCase(category);
});

enum ProductSortOption {
  featured,
  priceLow,
  priceHigh,
  rating,
}

final productSortProvider = StateProvider<ProductSortOption>((ref) {
  return ProductSortOption.featured;
});

List<Product> sortProducts(List<Product> products, ProductSortOption sort) {
  final sorted = List<Product>.of(products);
  switch (sort) {
    case ProductSortOption.featured:
      break;
    case ProductSortOption.priceLow:
      sorted.sort((a, b) => a.price.compareTo(b.price));
    case ProductSortOption.priceHigh:
      sorted.sort((a, b) => b.price.compareTo(a.price));
    case ProductSortOption.rating:
      sorted.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
  }
  return sorted;
}
