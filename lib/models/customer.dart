class Customer {
  final String id;
  final String name;
  final String? nickname;
  final String? phone;
  final double creditLimit;
  final double currentDebt;
  final DateTime lastActivity;
  final String? notes;

  const Customer({
    required this.id,
    required this.name,
    this.nickname,
    this.phone,
    this.creditLimit = 1500.0,
    this.currentDebt = 0.0,
    required this.lastActivity,
    this.notes,
  });

  String get displayName {
    if (nickname != null && nickname!.trim().isNotEmpty) {
      return '$name "$nickname"';
    }
    return name;
  }

  Customer copyWith({
    String? id,
    String? name,
    String? nickname,
    String? phone,
    double? creditLimit,
    double? currentDebt,
    DateTime? lastActivity,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      phone: phone ?? this.phone,
      creditLimit: creditLimit ?? this.creditLimit,
      currentDebt: currentDebt ?? this.currentDebt,
      lastActivity: lastActivity ?? this.lastActivity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'phone': phone,
      'creditLimit': creditLimit,
      'currentDebt': currentDebt,
      'lastActivity': lastActivity.toIso8601String(),
      'notes': notes,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      phone: json['phone'] as String?,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 1500.0,
      currentDebt: (json['currentDebt'] as num?)?.toDouble() ?? 0.0,
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }
}
