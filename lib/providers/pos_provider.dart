import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/sale_ticket.dart';
import '../services/storage_service.dart';

class PosProvider extends ChangeNotifier {
  // Soporte para 2 tickets en simultáneo (Venta en espera como Eleventa)
  int _activeTicketIndex = 0;
  final List<List<CartItem>> _tickets = [[], []];

  // Buffer del teclado numérico para importes manuales
  String _keypadBuffer = '';

  // Historial de ventas (Persistente)
  final List<SaleTicket> _salesHistory = [];
  int _nextFolio = 1;
  bool _isLoading = true;

  PosProvider() {
    _init();
  }

  bool get isLoading => _isLoading;

  Future<void> _init() async {
    final loaded = await StorageService.loadSales();
    _salesHistory.clear();
    _salesHistory.addAll(loaded);
    if (_salesHistory.isNotEmpty) {
      final maxFolio = _salesHistory.map((s) => s.folio).reduce((a, b) => a > b ? a : b);
      _nextFolio = maxFolio + 1;
    }
    _isLoading = false;
    notifyListeners();
  }

  int get activeTicketIndex => _activeTicketIndex;
  List<CartItem> get currentCart => _tickets[_activeTicketIndex];
  String get keypadBuffer => _keypadBuffer;
  List<SaleTicket> get salesHistory => List.unmodifiable(_salesHistory);

  double get currentTotal {
    return currentCart.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get currentPiecesCount {
    return currentCart.fold(0, (sum, item) => sum + item.quantity.toInt());
  }

  double get todayTotalSales {
    return _salesHistory.fold(0.0, (sum, ticket) => sum + ticket.total);
  }

  int get todayTicketsCount => _salesHistory.length;

  // --- NAVEGACIÓN ENTRE TICKETS (EN ESPERA) ---
  void switchTicket(int index) {
    if (index >= 0 && index < _tickets.length) {
      _activeTicketIndex = index;
      _keypadBuffer = '';
      HapticFeedback.selectionClick();
      notifyListeners();
    }
  }

  // --- TECLADO NUMÉRICO ---
  void keypadInput(String value) {
    HapticFeedback.lightImpact();
    if (value == 'C') {
      _keypadBuffer = '';
    } else if (value == '⌫') {
      if (_keypadBuffer.isNotEmpty) {
        _keypadBuffer = _keypadBuffer.substring(0, _keypadBuffer.length - 1);
      }
    } else if (value == '.') {
      if (!_keypadBuffer.contains('.')) {
        _keypadBuffer = _keypadBuffer.isEmpty ? '0.' : '$_keypadBuffer.';
      }
    } else {
      if (_keypadBuffer == '0') {
        _keypadBuffer = value;
      } else {
        _keypadBuffer += value;
      }
    }
    notifyListeners();
  }

  // Agregar venta rápida por importe directo (Venta común de mostrador / Granel)
  void addCustomAmount({
    String name = 'Venta Común',
    String iconEmoji = '🏷️',
    String category = 'Granel',
  }) {
    final amount = double.tryParse(_keypadBuffer);
    if (amount != null && amount > 0) {
      HapticFeedback.mediumImpact();
      final customProduct = Product(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        price: amount,
        category: category,
        iconEmoji: iconEmoji,
      );
      _tickets[_activeTicketIndex].add(CartItem(
        product: customProduct,
        quantity: 1.0,
      ));
      _keypadBuffer = '';
      notifyListeners();
    }
  }

  // --- GESTIÓN DEL CARRITO ---
  void addProduct(Product product, {double quantity = 1.0}) {
    HapticFeedback.lightImpact();
    final cart = _tickets[_activeTicketIndex];
    final existingIndex = cart.indexWhere((item) => item.product.id == product.id && item.customPrice == product.price);

    if (existingIndex != -1) {
      cart[existingIndex].quantity += quantity;
    } else {
      cart.add(CartItem(
        product: product,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  // Agregar venta a granel con importe exacto en dinero o nota de peso
  void addProductWithCustomPrice(Product product, double totalPrice, {String? note}) {
    HapticFeedback.mediumImpact();
    final cart = _tickets[_activeTicketIndex];
    cart.add(CartItem(
      product: product,
      quantity: 1.0,
      customPrice: totalPrice,
      note: note,
    ));
    notifyListeners();
  }

  void incrementQuantity(int index) {
    HapticFeedback.selectionClick();
    _tickets[_activeTicketIndex][index].quantity += 1.0;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    HapticFeedback.selectionClick();
    final cart = _tickets[_activeTicketIndex];
    if (cart[index].quantity > 1.0) {
      cart[index].quantity -= 1.0;
    } else {
      cart.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    HapticFeedback.mediumImpact();
    _tickets[_activeTicketIndex].removeAt(index);
    notifyListeners();
  }

  void clearCurrentCart() {
    _tickets[_activeTicketIndex].clear();
    _keypadBuffer = '';
    notifyListeners();
  }

  // --- FINALIZAR COBRO ---
  SaleTicket completeSale({
    required double paidAmount,
    required String paymentMethod,
    String? customerName,
    String? customerId,
  }) {
    HapticFeedback.heavyImpact();
    final total = currentTotal;
    final change = (paidAmount - total).clamp(0.0, 999999.0);

    final ticket = SaleTicket(
      id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
      folio: _nextFolio++,
      date: DateTime.now(),
      items: List.from(_tickets[_activeTicketIndex]),
      total: total,
      paidAmount: paidAmount,
      changeAmount: change,
      paymentMethod: paymentMethod,
      customerName: customerName,
      customerId: customerId,
    );

    _salesHistory.insert(0, ticket);
    _tickets[_activeTicketIndex].clear();
    _keypadBuffer = '';
    notifyListeners();

    // Guardado persistente
    StorageService.saveSales(_salesHistory);

    return ticket;
  }
}
