import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/sale_ticket.dart';
import '../models/customer.dart';
import '../models/credit_payment.dart';
import '../data/tiendita_dataset.dart';

class StorageService {
  static const String _keyProducts = 'puntozen_products_v3';
  static const String _keyLegacyProductsV2 = 'puntozen_products_v2';
  static const String _keyLegacyProductsV1 = 'puntozen_products_v1';
  static const String _keySales = 'puntozen_sales_v1';
  static const String _keyCustomers = 'puntozen_customers_v1';
  static const String _keyPayments = 'puntozen_payments_v1';

  // --- PRODUCTOS ---
  static Future<List<Product>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Intentar cargar v3
      String? jsonStr = prefs.getString(_keyProducts);

      // Si no existe v3, revisar si existía v2 o v1 para migrar
      if (jsonStr == null || jsonStr.isEmpty) {
        final legacyStr = prefs.getString(_keyLegacyProductsV2) ?? prefs.getString(_keyLegacyProductsV1);
        if (legacyStr != null && legacyStr.isNotEmpty) {
          final List<dynamic> legacyList = jsonDecode(legacyStr) as List<dynamic>;
          final legacyProducts = legacyList.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
          
          if (legacyProducts.length <= 20) {
            await saveProducts(defaultProducts);
            return defaultProducts;
          } else {
            // Fusionar productos del usuario con los nuevos artículos del catálogo maestro
            final existingBarcodes = legacyProducts.where((p) => p.barcode != null).map((p) => p.barcode!).toSet();
            final existingNames = legacyProducts.map((p) => p.name.toLowerCase().trim()).toSet();
            final merged = List<Product>.from(legacyProducts);

            for (final item in tienditaMasterCatalog) {
              final hasBarcode = item.barcode != null && existingBarcodes.contains(item.barcode);
              final hasName = existingNames.contains(item.name.toLowerCase().trim());
              if (!hasBarcode && !hasName) {
                merged.add(item);
              }
            }
            await saveProducts(merged);
            return merged;
          }
        }
      }

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        final loaded = list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
        if (loaded.isNotEmpty) {
          return loaded;
        }
      }
    } catch (e) {
      // Si falla la lectura, devuelve el catálogo maestro por defecto
    }
    
    // Guardar los productos iniciales por defecto
    final initial = defaultProducts;
    await saveProducts(initial);
    return initial;
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

  // --- CATÁLOGO DE PRODUCTOS SEMILLA (ESTILO ELEVENTA CON MÁS DE 140 ARTÍCULOS) ---
  static List<Product> get defaultProducts => List.from(tienditaMasterCatalog);

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
