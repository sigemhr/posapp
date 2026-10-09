import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/pos_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/module_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PuntoZenApp());
}

class PuntoZenApp extends StatelessWidget {
  const PuntoZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
      ],
      child: MaterialApp(
        title: 'PuntoZen POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
