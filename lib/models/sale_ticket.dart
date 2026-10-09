import 'cart_item.dart';

class SaleTicket {
  final String id;
  final int folio;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod; // 'Efectivo', 'Tarjeta', 'Transferencia', 'Fiado'
  final String? customerName;
  final String? customerId;

  SaleTicket({
    required this.id,
    required this.folio,
    required this.date,
    required this.items,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    this.paymentMethod = 'Efectivo',
    this.customerName,
    this.customerId,
  });

  int get totalPieces {
    return items.fold(0, (sum, item) => sum + item.quantity.toInt());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folio': folio,
      'date': date.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'total': total,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'customerId': customerId,
    };
  }

  factory SaleTicket.fromJson(Map<String, dynamic> json) {
    return SaleTicket(
      id: json['id'] as String,
      folio: json['folio'] as int,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String? ?? 'Efectivo',
      customerName: json['customerName'] as String?,
      customerId: json['customerId'] as String?,
    );
  }
}
