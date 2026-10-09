import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<Product> _products = List.from(StorageService.defaultProducts);
  bool _isLoading = true;

  InventoryProvider() {
    _init();
  }

  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _products = await StorageService.loadProducts();
    _isLoading = false;
    notifyListeners();
  }
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  List<Product> get products {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'Todos' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.barcode != null && p.barcode!.contains(_searchQuery));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['Todos', ...cats];
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Product? findByBarcode(String barcode) {
    try {
      return _products.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  int get totalProductsCount => _products.length;

  Future<void> addProduct(Product product) async {
    _products.add(product);
    notifyListeners();
    await StorageService.saveProducts(_products);
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
      await StorageService.saveProducts(_products);
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
    await StorageService.saveProducts(_products);
  }

  /// Importa el catálogo maestro de tiendita estilo Eleventa (+140 productos).
  /// [overwrite] = true: Reemplaza todo el catálogo actual.
  /// [overwrite] = false: Agrega solo los artículos faltantes sin duplicar códigos o nombres.
  Future<int> importMasterCatalog({bool overwrite = false}) async {
    int addedCount = 0;
    if (overwrite) {
      _products = List.from(StorageService.defaultProducts);
      addedCount = _products.length;
    } else {
      final existingBarcodes = _products
          .where((p) => p.barcode != null && p.barcode!.isNotEmpty)
          .map((p) => p.barcode!)
          .toSet();
      final existingNames = _products.map((p) => p.name.toLowerCase().trim()).toSet();

      for (final p in StorageService.defaultProducts) {
        final hasBarcode = p.barcode != null && existingBarcodes.contains(p.barcode);
        final hasName = existingNames.contains(p.name.toLowerCase().trim());

        if (!hasBarcode && !hasName) {
          _products.add(p);
          addedCount++;
        }
      }
    }
    notifyListeners();
    await StorageService.saveProducts(_products);
    return addedCount;
  }

  Future<void> updateStock(String productId, double quantityDeducted) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index];
      _products[index] = current.copyWith(
        stock: (current.stock - quantityDeducted).clamp(0, 99999),
      );
      notifyListeners();
      await StorageService.saveProducts(_products);
    }
  }
}
