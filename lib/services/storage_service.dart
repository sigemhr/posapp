import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/sale_ticket.dart';
import '../models/customer.dart';
import '../models/credit_payment.dart';

class StorageService {
  static const String _keyProducts = 'puntozen_products_v1';
  static const String _keySales = 'puntozen_sales_v1';
  static const String _keyCustomers = 'puntozen_customers_v1';
  static const String _keyPayments = 'puntozen_payments_v1';

  // --- PRODUCTOS ---
  static Future<List<Product>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyProducts);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Si falla la lectura, devuelve los productos por defecto
    }
    return defaultProducts;
  }

  static Future<void> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = products.map((p) => p.toJson()).toList();
      await prefs.setString(_keyProducts, jsonEncode(list));
    } catch (_) {}
  }

  // --- VENTAS Y TICKETS ---
  static Future<List<SaleTicket>> loadSales() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keySales);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => SaleTicket.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveSales(List<SaleTicket> sales) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = sales.map((s) => s.toJson()).toList();
      await prefs.setString(_keySales, jsonEncode(list));
    } catch (_) {}
  }

  // --- CLIENTES (LIBRETA DE FIADO) ---
  static Future<List<Customer>> loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyCustomers);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return defaultCustomers;
  }

  static Future<void> saveCustomers(List<Customer> customers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = customers.map((c) => c.toJson()).toList();
      await prefs.setString(_keyCustomers, jsonEncode(list));
    } catch (_) {}
  }

  // --- ABONOS DE CRÉDITO ---
  static Future<List<CreditPayment>> loadPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyPayments);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => CreditPayment.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> savePayments(List<CreditPayment> payments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = payments.map((p) => p.toJson()).toList();
      await prefs.setString(_keyPayments, jsonEncode(list));
    } catch (_) {}
  }

  // --- CATÁLOGO DE PRODUCTOS SEMILLA (16 MÁS VENDIDOS EN MÉXICO) ---
  static final List<Product> defaultProducts = [
    const Product(
      id: 'p1',
      name: 'Coca-Cola 600ml No Retornable',
      price: 19.0,
      cost: 14.5,
      barcode: '7501055300075',
      category: 'Refrescos',
      iconEmoji: '🥤',
      stock: 48,
    ),
    const Product(
      id: 'p2',
      name: 'Coca-Cola 2.5L Retornable',
      price: 36.0,
      cost: 28.0,
      barcode: '7501055301234',
      category: 'Refrescos',
      iconEmoji: '🥤',
      stock: 18,
    ),
    const Product(
      id: 'p3',
      name: 'Agua Bonafont 1 Litro',
      price: 15.0,
      cost: 9.5,
      barcode: '7501055300999',
      category: 'Bebidas',
      iconEmoji: '💧',
      stock: 35,
    ),
    const Product(
      id: 'p4',
      name: 'Jugo Del Valle Mango 413ml',
      price: 18.0,
      cost: 13.0,
      barcode: '7501055304444',
      category: 'Bebidas',
      iconEmoji: '🧃',
      stock: 22,
    ),
    const Product(
      id: 'p5',
      name: 'Sabritas Sal Original 42g',
      price: 22.0,
      cost: 16.5,
      barcode: '7501011123456',
      category: 'Botanas',
      iconEmoji: '🥔',
      stock: 30,
    ),
    const Product(
      id: 'p6',
      name: 'Doritos Nacho 58g',
      price: 22.0,
      cost: 16.5,
      barcode: '7501011165432',
      category: 'Botanas',
      iconEmoji: '🧀',
      stock: 26,
    ),
    const Product(
      id: 'p7',
      name: 'Ruffles Queso 48g',
      price: 22.0,
      cost: 16.5,
      barcode: '7501011199887',
      category: 'Botanas',
      iconEmoji: '🍟',
      stock: 20,
    ),
    const Product(
      id: 'p8',
      name: 'Gansito Marinela 50g',
      price: 19.0,
      cost: 14.0,
      barcode: '7501000123456',
      category: 'Dulces & Galletas',
      iconEmoji: '🍰',
      stock: 18,
    ),
    const Product(
      id: 'p9',
      name: 'Galletas Emperador Chocolate',
      price: 23.0,
      cost: 17.5,
      barcode: '7501000188990',
      category: 'Dulces & Galletas',
      iconEmoji: '🍪',
      stock: 24,
    ),
    const Product(
      id: 'p10',
      name: 'Pan Blanco Bimbo Grande',
      price: 49.0,
      cost: 41.0,
      barcode: '7501000100011',
      category: 'Abarrotes',
      iconEmoji: '🍞',
      stock: 12,
    ),
    const Product(
      id: 'p11',
      name: 'Leche Lala Entera 1 Litro',
      price: 29.0,
      cost: 23.5,
      barcode: '7501020511122',
      category: 'Lácteos',
      iconEmoji: '🥛',
      stock: 28,
    ),
    const Product(
      id: 'p12',
      name: 'Sopa Maruchan Vaso Pollo 64g',
      price: 17.0,
      cost: 12.0,
      barcode: '7501055307777',
      category: 'Abarrotes',
      iconEmoji: '🍜',
      stock: 45,
    ),
    const Product(
      id: 'p13',
      name: 'Bolillo / Telera (Pieza)',
      price: 3.5,
      cost: 2.2,
      category: 'Granel & Rápido',
      iconEmoji: '🥖',
      stock: 60,
    ),
    const Product(
      id: 'p14',
      name: 'Tortillas de Maíz (1 Kg)',
      price: 24.0,
      cost: 18.0,
      category: 'Granel & Rápido',
      isByWeight: true,
      iconEmoji: '🫓',
      stock: 50,
    ),
    const Product(
      id: 'p15',
      name: 'Huevo Blanco (1 Kg)',
      price: 48.0,
      cost: 39.0,
      category: 'Granel & Rápido',
      isByWeight: true,
      iconEmoji: '🥚',
      stock: 35,
    ),
    const Product(
      id: 'p16',
      name: 'Hielo en Bolsa 5 Kg',
      price: 32.0,
      cost: 20.0,
      category: 'Granel & Rápido',
      iconEmoji: '🧊',
      stock: 15,
    ),
    const Product(
      id: 'p17',
      name: 'Jamón Virginia Fud (100g)',
      price: 17.50,
      cost: 12.0,
      category: 'Granel & Rápido',
      iconEmoji: '🥓',
      isByWeight: true,
      stock: 80,
    ),
    const Product(
      id: 'p18',
      name: 'Queso Panela Cremería (100g)',
      price: 16.0,
      cost: 11.5,
      category: 'Granel & Rápido',
      iconEmoji: '🧀',
      isByWeight: true,
      stock: 60,
    ),
  ];

  // --- CLIENTES SEMILLA PARA LA LIBRETA DE FIADO ---
  static final List<Customer> defaultCustomers = [
    Customer(
      id: 'c1',
      name: 'Doña Carmen',
      nickname: 'Vecina de enfrente',
      phone: '5512345678',
      creditLimit: 1200.0,
      currentDebt: 185.50,
      lastActivity: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'Paga cada viernes que le pagan a su esposo.',
    ),
    Customer(
      id: 'c2',
      name: 'Don Pepe',
      nickname: 'Mecánico de la esquina',
      phone: '5598765432',
      creditLimit: 2000.0,
      currentDebt: 340.0,
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Acostumbra llevar refrescos y cigarros entre semana.',
    ),
    Customer(
      id: 'c3',
      name: 'Sra. Lupita',
      nickname: 'Papelería La Escuelita',
      phone: '5543218765',
      creditLimit: 800.0,
      currentDebt: 65.0,
      lastActivity: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Cliente muy puntual.',
    ),
  ];
}
