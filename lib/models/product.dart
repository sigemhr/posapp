class Product {
  final String id;
  final String name;
  final double price;
  final double cost;
  final String? barcode;
  final String category;
  final bool isByWeight; // Para venta a granel (ej. jamón, huevo, fruta)
  final double stock;
  final String iconEmoji;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.cost = 0.0,
    this.barcode,
    required this.category,
    this.isByWeight = false,
    this.stock = 100,
    this.iconEmoji = '📦',
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? cost,
    String? barcode,
    String? category,
    bool? isByWeight,
    double? stock,
    String? iconEmoji,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      isByWeight: isByWeight ?? this.isByWeight,
      stock: stock ?? this.stock,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cost': cost,
      'barcode': barcode,
      'category': category,
      'isByWeight': isByWeight,
      'stock': stock,
      'iconEmoji': iconEmoji,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      barcode: json['barcode'] as String?,
      category: json['category'] as String,
      isByWeight: json['isByWeight'] as bool? ?? false,
      stock: (json['stock'] as num?)?.toDouble() ?? 100.0,
      iconEmoji: json['iconEmoji'] as String? ?? '📦',
    );
  }
}
