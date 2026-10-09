import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/product.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _openAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    String category = 'Abarrotes';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar Nuevo Producto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del producto *', hintText: 'Ej. Galletas Chokis'),
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
              TextField(
                controller: barcodeCtrl,
                decoration: const InputDecoration(labelText: 'Código de Barras (Opcional)'),
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
                  iconEmoji: '📦',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
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
