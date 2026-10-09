import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/product.dart';
import '../../data/tiendita_dataset.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showImportCatalogDialog(BuildContext context) {
    final inv = context.read<InventoryProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF4F46E5), size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Catálogo Maestro Eleventa',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Base de datos precargada con más de 185 artículos más vendidos en tienditas de abarrotes de México.',
              style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Códigos de barra reales (Coca-Cola, Bimbo, Sabritas, Scribe, Bic, etc.)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('✅ Precios de venta y costos de compra promedio sugeridos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('✅ Papelería escolar (cuadernos, lápices, plumas, pegamento, tijeras)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('✅ Limpieza completa, granel, farmacia de emergencia y pilas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Actualmente tienes ${inv.totalProductsCount} productos registrados.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final count = await inv.importMasterCatalog(overwrite: false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Se agregaron $count productos faltantes al catálogo.'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              side: const BorderSide(color: Color(0xFF4F46E5)),
            ),
            child: const Text('Agregar Faltantes'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final count = await inv.importMasterCatalog(overwrite: true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Catálogo restaurado: $count productos cargados.'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reemplazar Todo'),
          ),
        ],
      ),
    );
  }

  void _openAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    String category = 'Abarrotes';
    String emoji = '📦';
    bool isByWeight = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void tryAutocomplete(String barcode) {
            final match = findInTienditaCatalogByBarcode(barcode);
            if (match != null) {
              setDialogState(() {
                nameCtrl.text = match.name;
                priceCtrl.text = match.price.toStringAsFixed(match.price % 1 == 0 ? 0 : 2);
                costCtrl.text = match.cost.toStringAsFixed(match.cost % 1 == 0 ? 0 : 2);
                category = match.category;
                emoji = match.iconEmoji;
                isByWeight = match.isByWeight;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡Datos autocompletados desde catálogo maestro: "${match.name}"!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF4F46E5),
                ),
              );
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const Text('Nuevo Producto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: barcodeCtrl,
                    onChanged: (val) {
                      if (val.trim().length >= 8) {
                        tryAutocomplete(val.trim());
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Código de Barras',
                      hintText: 'Escanea o ingresa EAN-13',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, size: 20),
                        tooltip: 'Buscar en catálogo maestro',
                        onPressed: () => tryAutocomplete(barcodeCtrl.text.trim()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del producto *', hintText: 'Ej. Coca-Cola 600ml'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Precio Venta *', prefixText: '\$'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: costCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Costo Compra', prefixText: '\$'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Categoría:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Venta por peso / a granel (ej. jamón, huevo, fruta)', style: TextStyle(fontSize: 12)),
                    value: isByWeight,
                    onChanged: (val) => setDialogState(() => isByWeight = val ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final cost = double.tryParse(costCtrl.text) ?? 0.0;
                  if (name.isNotEmpty && price > 0) {
                    final newProduct = Product(
                      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      price: price,
                      cost: cost,
                      barcode: barcodeCtrl.text.trim().isNotEmpty ? barcodeCtrl.text.trim() : null,
                      category: category,
                      iconEmoji: emoji,
                      isByWeight: isByWeight,
                      stock: 50,
                    );
                    context.read<InventoryProvider>().addProduct(newProduct);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Producto "$name" agregado con éxito'), backgroundColor: const Color(0xFF059669)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catálogo de Productos', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(
              '${inv.totalProductsCount} artículos disponibles',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Precargar catálogo estilo Eleventa',
            onPressed: () => _showImportCatalogDialog(context),
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF4F46E5), size: 16),
                  SizedBox(width: 4),
                  Text('Eleventa', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _openAddProductDialog(context),
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4F46E5),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: inv.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código de barras...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Filtro de categorías
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: inv.categories.length,
              itemBuilder: (context, i) {
                final cat = inv.categories[i];
                final isSelected = inv.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569)),
                    onSelected: (_) => inv.setCategory(cat),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Lista de Productos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: inv.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final product = inv.products[i];
                final margin = product.price - product.cost;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(product.iconEmoji, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.barcode != null)
                          Text('Código: ${product.barcode}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        Text(
                          'Stock: ${product.stock.toInt()} | Ganancia: +\$${margin.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
