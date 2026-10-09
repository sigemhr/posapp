import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModuleProvider extends ChangeNotifier {
  // Por defecto en etapa de desarrollo, todos los módulos están 100% desbloqueados
  final Set<String> _unlockedModules = {
    'all_inclusive_pro',
    'no_ads',
    'barcode_scanner',
    'inventory_control',
    'credit_book',
    'thermal_printer',
  };

  ModuleProvider() {
    _loadFromPreferences();
  }

  // Acceso total a todas las características sin restricciones
  bool isUnlocked(String moduleId) => true;

  bool get hasAds => false;

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('unlocked_modules') ?? [];
      _unlockedModules.addAll(list);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> unlockModule(String moduleId) async {
    _unlockedModules.add(moduleId);
    if (moduleId == 'all_inclusive_pro') {
      _unlockedModules.addAll([
        'no_ads',
        'barcode_scanner',
        'inventory_control',
        'credit_book',
        'thermal_printer',
      ]);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlocked_modules', _unlockedModules.toList());
    } catch (_) {}
  }

  Future<void> resetAllModules() async {
    _unlockedModules.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('unlocked_modules');
    } catch (_) {}
  }
}
