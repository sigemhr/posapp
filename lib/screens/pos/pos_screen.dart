import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/module_provider.dart';
import '../../models/product.dart';
import '../../models/sale_ticket.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/change_dialog.dart';
import 'widgets/receipt_dialog.dart';
import 'widgets/ad_banner_widget.dart';

class PosScreen extends StatefulWidget {
  final VoidCallback onNavigateToModules;

  const PosScreen({super.key, required this.onNavigateToModules});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  bool _showCatalog = true;

  void _openCheckoutDialog() async {
    final pos = context.read<PosProvider>();
    final SaleTicket? ticket = await showDialog<SaleTicket>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeDialog(pos: pos),
    );

    if (ticket != null && mounted) {
      final inv = context.read<InventoryProvider>();
      for (final item in ticket.items) {
        inv.updateStock(item.product.id, item.quantity);
      }
      showDialog(
        context: context,
        builder: (context) => ReceiptDialog(ticket: ticket),
      );
    }
  }

  void _onBarcodeScanPressed() {
    final moduleProvider = context.read<ModuleProvider>();
    if (!moduleProvider.isUnlocked('barcode_scanner')) {
      _showModuleLockedDialog('Lector de Códigos de Barra', 'barcode_scanner', 99.0);
    } else {
      // Simula escaneo exitoso de un producto común
      final inv = context.read<InventoryProvider>();
      final coca = inv.findByBarcode('7501055300075');
      if (coca != null) {
        context.read<PosProvider>().addProduct(coca);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Escaneado: ${coca.name} - \$${coca.price.toStringAsFixed(2)}'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    }
  }

  void _onProductTapped(Product product) {
    if (product.isByWeight) {
      _openBulkSaleDialog(product);
    } else {
      context.read<PosProvider>().addProduct(product);
    }
  }

  void _openBulkSaleDialog(Product product) {
    final amountCtrl = TextEditingController(text: product.price.toStringAsFixed(product.price % 1 == 0 ? 0 : 2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(product.iconEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(
                    'Venta a granel / mostrador (Base: \$${product.price.toStringAsFixed(2)})',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuánto importe se cobra? (ej. 17.50):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            // Atajos rápidos de importe
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('\$10'),
                  onPressed: () => amountCtrl.text = '10.00',
                ),
                ActionChip(
                  label: const Text('\$15'),
                  onPressed: () => amountCtrl.text = '15.00',
                ),
                ActionChip(
                  label: const Text('\$17.50', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  backgroundColor: const Color(0xFFEEF2FF),
                  onPressed: () => amountCtrl.text = '17.50',
                ),
                ActionChip(
                  label: const Text('\$20'),
                  onPressed: () => amountCtrl.text = '20.00',
                ),
                ActionChip(
                  label: const Text('\$25'),
                  onPressed: () => amountCtrl.text = '25.00',
                ),
                ActionChip(
                  label: const Text('\$50'),
                  onPressed: () => amountCtrl.text = '50.00',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0.0;
              if (amount > 0) {
                context.read<PosProvider>().addProductWithCustomPrice(product, amount);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar al Ticket'),
          ),
        ],
      ),
    );
  }

  void _showModuleLockedDialog(String moduleName, String moduleId, double price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFEA580C)),
            const SizedBox(width: 8),
            Expanded(child: Text('Módulo $moduleName')),
          ],
        ),
        content: Text(
          'Esta función es parte de los módulos de pago único (\$${price.toStringAsFixed(0)} MXN sin mensualidades).\n\n¿Deseas activarla ahora para tu negocio?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigateToModules();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: Text('Ver Módulos (\$${price.toStringAsFixed(0)})'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final inv = context.watch<InventoryProvider>();
    final cart = pos.currentCart;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abarrotes & Tiendita PuntoZen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            Text(
              'Ventas hoy: \$${pos.todayTotalSales.toStringAsFixed(2)} (${pos.todayTicketsCount} tickets)',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
            ),
          ],
        ),
        actions: [
          // Botón Escáner de Códigos de Barra
          IconButton(
            tooltip: 'Escanear Código de Barras',
            onPressed: _onBarcodeScanPressed,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_scanner, color: Color(0xFF4F46E5), size: 22),
            ),
          ),
          // Alternar entre Catálogo o Ticket grande
          IconButton(
            tooltip: 'Alternar Vista',
            onPressed: () => setState(() => _showCatalog = !_showCatalog),
            icon: Icon(_showCatalog ? Icons.view_sidebar_outlined : Icons.grid_view_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: const Color(0xFFF1F5F9),
            child: Row(
              children: [
                _buildTicketTab(0, 'Ticket 1', pos.activeTicketIndex == 0),
                const SizedBox(width: 8),
                _buildTicketTab(1, 'Ticket 2 (En Espera)', pos.activeTicketIndex == 1),
                const Spacer(),
                if (cart.isNotEmpty)
                  InkWell(
                    onTap: () => pos.clearCurrentCart(),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                        SizedBox(width: 4),
                        Text('Vaciar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Lado Izquierdo: Catálogo de productos rápidos
                  if (_showCatalog)
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          children: [
                            // Selector de Categorías
                            SizedBox(
                              height: 44,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                itemCount: inv.categories.length,
                                itemBuilder: (context, i) {
                                  final cat = inv.categories[i];
                                  final isSelected = inv.selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
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

                            // Grid de Productos de Tiendita
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.15,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: inv.products.length,
                                itemBuilder: (context, index) {
                                  final product = inv.products[index];
                                  return InkWell(
                                    onTap: () => _onProductTapped(product),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(product.iconEmoji, style: const TextStyle(fontSize: 22)),
                                                  if (product.isByWeight) ...[
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFEF3C7),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text('Granel', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text(
                                                '\$${product.price.toStringAsFixed(product.price % 1 == 0 ? 0 : 2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                  color: Color(0xFF059669),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            product.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            product.isByWeight ? 'Venta por peso / importe' : 'Stock: ${product.stock.toInt()} pzs',
                                            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Lado Derecho: Carrito / Ticket Actual
                  Expanded(
                    flex: _showCatalog ? 5 : 10,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Column(
                        children: [
                          // Lista de artículos en el ticket
                          Expanded(
                            child: cart.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_cart_outlined, size: 40, color: Color(0xFFCBD5E1)),
                                        SizedBox(height: 8),
                                        Text('Ticket vacío', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                        Text('Toca productos o ingresa importe', style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                    itemCount: cart.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    itemBuilder: (context, index) {
                                      final item = cart[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            // Cantidad + Controles
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () => pos.decrementQuantity(index),
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      child: Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                    ),
                                                  ),
                                                  Text('${item.quantity.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                                  InkWell(
                                                    onTap: () => pos.incrementQuantity(index),
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Nombre
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.product.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700), maxLines: 1),
                                                  Text('\$${item.customPrice.toStringAsFixed(2)} c/u', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                                ],
                                              ),
                                            ),
                                            // Subtotal
                                            Text(
                                              '\$${item.subtotal.toStringAsFixed(2)}',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Teclado Numérico y Botón de Cobro Fijo al Fondo (Zona del Pulgar)
            NumericKeypad(
              onCheckoutPressed: _openCheckoutDialog,
            ),

            // Banner de Anuncio en Nivel Gratuito
            AdBannerWidget(
              onRemoveAdsPressed: widget.onNavigateToModules,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTab(int index, String label, bool isActive) {
    return InkWell(
      onTap: () => context.read<PosProvider>().switchTicket(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
