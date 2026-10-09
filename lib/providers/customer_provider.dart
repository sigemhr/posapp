import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../models/credit_payment.dart';
import '../services/storage_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  List<CreditPayment> _payments = [];
  String _searchQuery = '';
  bool _isLoading = true;

  CustomerProvider() {
    _init();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Customer> get customers {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_customers);
    }
    final q = _searchQuery.toLowerCase().trim();
    return _customers.where((c) {
      final nameMatches = c.name.toLowerCase().contains(q);
      final nickMatches = c.nickname?.toLowerCase().contains(q) ?? false;
      final phoneMatches = c.phone?.contains(q) ?? false;
      return nameMatches || nickMatches || phoneMatches;
    }).toList();
  }

  List<CreditPayment> get payments => List.unmodifiable(_payments);

  double get totalOutstandingDebt {
    return _customers.fold(0.0, (sum, c) => sum + c.currentDebt);
  }

  int get debtorCount {
    return _customers.where((c) => c.currentDebt > 0).length;
  }

  Future<void> _init() async {
    _customers = await StorageService.loadCustomers();
    _payments = await StorageService.loadPayments();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Customer? findById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCustomer(Customer customer) async {
    HapticFeedback.mediumImpact();
    _customers.add(customer);
    notifyListeners();
    await StorageService.saveCustomers(_customers);
  }

  Future<void> updateCustomer(Customer updated) async {
    final index = _customers.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _customers[index] = updated;
      notifyListeners();
      await StorageService.saveCustomers(_customers);
    }
  }

  // Cargar una venta fiada a la cuenta del vecino
  Future<void> addCreditSale({
    required String customerId,
    required double amount,
  }) async {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final current = _customers[index];
      _customers[index] = current.copyWith(
        currentDebt: current.currentDebt + amount,
        lastActivity: DateTime.now(),
      );
      notifyListeners();
      await StorageService.saveCustomers(_customers);
    }
  }

  // Registrar un abono o liquidación
  Future<void> registerPayment({
    required String customerId,
    required double amount,
    String notes = 'Abono en efectivo',
  }) async {
    HapticFeedback.heavyImpact();
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final current = _customers[index];
      final newDebt = (current.currentDebt - amount).clamp(0.0, 999999.0);
      _customers[index] = current.copyWith(
        currentDebt: newDebt,
        lastActivity: DateTime.now(),
      );

      final payment = CreditPayment(
        id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        amount: amount,
        date: DateTime.now(),
        notes: notes,
      );
      _payments.insert(0, payment);

      notifyListeners();
      await StorageService.saveCustomers(_customers);
      await StorageService.savePayments(_payments);
    }
  }

  // Historial de abonos de un cliente específico
  List<CreditPayment> getPaymentsForCustomer(String customerId) {
    return _payments.where((p) => p.customerId == customerId).toList();
  }

  // Generar URL para WhatsApp con saludo amable y saldo exacto
  String buildWhatsAppUrl(Customer customer) {
    final phone = (customer.phone ?? '').replaceAll(RegExp(r'\D'), '');
    final fullPhone = phone.length == 10 ? '52$phone' : phone;

    final name = customer.nickname != null && customer.nickname!.isNotEmpty
        ? customer.name
        : customer.name;

    final message = 'Hola $name, buen día 👋 le saludamos con mucho gusto de su Tiendita de confianza 🛒. '
        'Le compartimos que su saldo actual en la libreta de fiado es de \$${customer.currentDebt.toStringAsFixed(2)} MXN. '
        '¡Cualquier duda quedamos a sus órdenes y que tenga excelente día!';

    return 'https://wa.me/$fullPhone?text=${Uri.encodeComponent(message)}';
  }
}
