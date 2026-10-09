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

  Future<void> addProduct(Product product) async {
    _products.add(product);
    notifyListeners();
    await StorageService.saveProducts(_products);
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
