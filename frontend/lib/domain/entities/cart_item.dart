import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category,
        'image': product.image,
        'ratingRate': product.rating.rate,
        'ratingCount': product.rating.count,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<dynamic, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['productId'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        category: json['category'] as String,
        image: json['image'] as String,
        rating: ProductRating(
          rate: (json['ratingRate'] as num).toDouble(),
          count: json['ratingCount'] as int,
        ),
      ),
      quantity: json['quantity'] as int,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity];
}
