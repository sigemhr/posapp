import 'product.dart';

class CartItem {
  final Product product;
  double quantity;
  double customPrice; // Permite sobrescribir precio si es venta común
  String? note;

  CartItem({
    required this.product,
    this.quantity = 1.0,
    double? customPrice,
    this.note,
  }) : customPrice = customPrice ?? product.price;

  double get subtotal => customPrice * quantity;

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? customPrice,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'customPrice': customPrice,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      customPrice: (json['customPrice'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}
