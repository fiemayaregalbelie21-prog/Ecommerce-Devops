import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this.dataSource);

  final CartLocalDataSource dataSource;

  @override
  List<CartItem> getItems() {
    return dataSource.getItems();
  }

  @override
  Future<void> saveItems(List<CartItem> items) async {
    await dataSource.saveItems(items);
  }
}
