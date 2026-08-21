import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/cart_item.dart';
import '../../../../domain/entities/product.dart';
import '../../../../data/datasources/cart_local_datasource.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final dataSource = CartLocalDataSource();
  return CartNotifier(dataSource);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier(this._dataSource) : super([]) {
    _loadCart();
  }

  final CartLocalDataSource _dataSource;

  Future<void> _loadCart() async {
    final items = _dataSource.getItems();
    state = items;
  }

  double get subtotal {
    return state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      final existing = state[existingIndex];
      state = state.toList()
        ..[existingIndex] = CartItem(
          product: existing.product,
          quantity: existing.quantity + quantity,
        );
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
    _saveCart();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      state = state.toList()
        ..[index] = CartItem(
          product: state[index].product,
          quantity: quantity,
        );
      _saveCart();
    }
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _saveCart();
  }

  void clear() {
    state = [];
    _saveCart();
  }

  Future<void> _saveCart() async {
    await _dataSource.saveItems(state);
  }
}
