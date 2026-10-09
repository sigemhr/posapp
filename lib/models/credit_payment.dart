class CreditPayment {
  final String id;
  final String customerId;
  final double amount;
  final DateTime date;
  final String notes;

  const CreditPayment({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.date,
    this.notes = 'Abono en efectivo',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory CreditPayment.fromJson(Map<String, dynamic> json) {
    return CreditPayment(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? 'Abono en efectivo',
    );
  }
}
