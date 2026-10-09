import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/module_provider.dart';
import '../../models/product.dart';
import '../../models/sale_ticket.dart';
import '../../data/tiendita_dataset.dart';
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
      return;
    }

    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Escanear Código de Barras', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa el código o usa tu pistola lectora USB:', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            TextField(
              controller: codeCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ej. 7501055300075',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (code) {
                Navigator.pop(ctx);
                _processBarcode(code.trim());
              },
            ),
            const SizedBox(height: 12),
            const Text('Pruebas rápidas (artículos comunes):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('🥤 Coca 600ml', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501055300075');
                  },
                ),
                ActionChip(
                  label: const Text('🧀 Doritos 58g', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501011165432');
                  },
                ),
                ActionChip(
                  label: const Text('🍞 Pan Bimbo', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501000100011');
                  },
                ),
                ActionChip(
                  label: const Text('🥛 Leche Lala', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501020511122');
                  },
                ),
                ActionChip(
                  label: const Text('🍜 Maruchan', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501055307777');
                  },
                ),
                ActionChip(
                  label: const Text('📓 Cuaderno Scribe', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501037800016');
                  },
                ),
                ActionChip(
                  label: const Text('🖊️ Pluma Bic', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501004100017');
                  },
                ),
                ActionChip(
                  label: const Text('🟣 Fabuloso 1L', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('7501035912344');
                  },
                ),
                ActionChip(
                  label: const Text('🔋 Pilas AA', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _processBarcode('041333001051');
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processBarcode(codeCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Escanear'),
          ),
        ],
      ),
    );
  }

  void _processBarcode(String barcode) {
    if (barcode.isEmpty) return;
    final inv = context.read<InventoryProvider>();
    final pos = context.read<PosProvider>();

    // 1. Buscar en inventario actual
    final existing = inv.findByBarcode(barcode);
    if (existing != null) {
      pos.addProduct(existing);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escaneado: ${existing.name} - \$${existing.price.toStringAsFixed(2)}'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      return;
    }

    // 2. Si no está en inventario, buscar en el catálogo maestro Eleventa
    final masterMatch = findInTienditaCatalogByBarcode(barcode);
    if (masterMatch != null) {
      inv.addProduct(masterMatch);
      pos.addProduct(masterMatch);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Encontrado en catálogo maestro y agregado: ${masterMatch.name} (\$${masterMatch.price.toStringAsFixed(2)})'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4F46E5),
        ),
      );
      return;
    }

    // 3. No encontrado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código "$barcode" no encontrado en el inventario ni en catálogo maestro.'),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
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

  int _mobileTab = 0; // 0: Catálogo, 1: Ticket, 2: Teclado/Granel

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final inv = context.watch<InventoryProvider>();
    final cart = pos.currentCart;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMobile ? 'PuntoZen POS' : 'Abarrotes & Tiendita PuntoZen',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            Text(
              'Hoy: \$${pos.todayTotalSales.toStringAsFixed(2)} (${pos.todayTicketsCount} tickets)',
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
          if (!isMobile)
            IconButton(
              tooltip: 'Alternar Vista',
              onPressed: () => setState(() => _showCatalog = !_showCatalog),
              icon: Icon(_showCatalog ? Icons.view_sidebar_outlined : Icons.grid_view_rounded),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isMobile ? 86 : 42),
          child: Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de Ticket 1 / Ticket 2
                Row(
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
                            Text('Vaciar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          ],
                        ),
                      ),
                  ],
                ),
                // En Celulares: Barra de Pestañas Adaptativa (Catálogo / Ticket / Teclado)
                if (isMobile) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMobileSegmentPill(
                          index: 0,
                          icon: Icons.grid_view_rounded,
                          label: 'Catálogo',
                          badgeCount: null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMobileSegmentPill(
                          index: 1,
                          icon: Icons.receipt_long_rounded,
                          label: 'Ticket',
                          badgeCount: cart.isNotEmpty ? cart.length : null,
                          trailingAmount: cart.isNotEmpty ? '\$${pos.currentTotal.toStringAsFixed(0)}' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMobileSegmentPill(
                          index: 2,
                          icon: Icons.dialpad_rounded,
                          label: 'Teclado',
                          badgeCount: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: isMobile
            // ==========================================
            // DISEÑO MÓVIL OPTIMIZADO PARA CELULARES
            // ==========================================
            ? Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: _mobileTab,
                      children: [
                        // Pestaña 0: Catálogo a pantalla completa
                        _buildMobileCatalogTab(inv, pos),
                        // Pestaña 1: Ticket a pantalla completa
                        _buildMobileTicketTab(pos),
                        // Pestaña 2: Teclado táctil a pantalla completa
                        _buildMobileKeypadTab(pos),
                      ],
                    ),
                  ),
                  // Banner de Anuncio en Nivel Gratuito
                  AdBannerWidget(
                    onRemoveAdsPressed: widget.onNavigateToModules,
                  ),
                ],
              )
            // ==========================================
            // DISEÑO PARA TABLETS Y PANTALLAS GRANDES (SPLIT VIEW)
            // ==========================================
            : Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Lado Izquierdo: Catálogo
                        if (_showCatalog)
                          Expanded(
                            flex: 6,
                            child: _buildTabletCatalogPanel(inv),
                          ),

                        // Lado Derecho: Carrito / Ticket Actual
                        Expanded(
                          flex: _showCatalog ? 5 : 10,
                          child: _buildTabletTicketPanel(pos, cart),
                        ),
                      ],
                    ),
                  ),

                  // Teclado Numérico y Botón de Cobro Fijo al Fondo (Tablet)
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

  // ==========================================
  // WIDGETS AUXILIARES PARA CELULARES
  // ==========================================

  Widget _buildMobileSegmentPill({
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
    String? trailingAmount,
  }) {
    final isSelected = _mobileTab == index;
    return InkWell(
      onTap: () => setState(() => _mobileTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF475569)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailingAmount ?? '$badgeCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCatalogTab(InventoryProvider inv, PosProvider pos) {
    final cart = pos.currentCart;
    final totalItems = cart.fold<int>(0, (sum, i) => sum + i.quantity.toInt());

    return Stack(
      children: [
        Column(
          children: [
            // Barra de búsqueda rápida
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: SizedBox(
                height: 40,
                child: TextField(
                  onChanged: inv.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar entre ${inv.products.length} productos...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
            ),

            // Selector de Categorías Horizontal
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

            // Grid de Productos Móvil (2 columnas con suficiente espacio táctil)
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(10, 6, 10, cart.isNotEmpty ? 80 : 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.18,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: inv.products.length,
                itemBuilder: (context, index) {
                  final product = inv.products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        ),

        // Barra flotante inferior de cobro rápido cuando hay productos en el ticket
        if (cart.isNotEmpty)
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40000000),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$totalItems',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ticket #${pos.activeTicketIndex + 1}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('\$${pos.currentTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _mobileTab = 1),
                    icon: const Icon(Icons.receipt_long, color: Colors.white, size: 16),
                    label: const Text('Ver Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _openCheckoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cobrar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileTicketTab(PosProvider pos) {
    final cart = pos.currentCart;

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 12),
              const Text(
                'El ticket actual está vacío',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Toca productos del catálogo o ingresa importes con el teclado para comenzar la venta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => setState(() => _mobileTab = 0),
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: const Text('Explorar Catálogo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Lista de artículos del ticket a ancho completo
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cart.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = cart[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Emoji del producto
                    Text(item.product.iconEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    // Nombre y precio unitario
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            '\$${item.customPrice.toStringAsFixed(2)} c/u',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    // Controles de cantidad táctiles grandes
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => pos.decrementQuantity(index),
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                          Text(
                            '${item.quantity.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          InkWell(
                            onTap: () => pos.incrementQuantity(index),
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Subtotal
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Panel de Cobro Fijo al fondo del ticket móvil
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${cart.length} artículos en ticket:',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${pos.currentTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _mobileTab = 0),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ Agregar Más'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openCheckoutDialog,
                      icon: const Icon(Icons.payments_outlined, size: 20),
                      label: Text(
                        'COBRAR \$${pos.currentTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileKeypadTab(PosProvider pos) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFEEF2FF),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ticket actual: ${pos.currentCart.length} productos (\$${pos.currentTotal.toStringAsFixed(2)})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3730A3)),
                  ),
                ),
                if (pos.currentCart.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _mobileTab = 1),
                    child: const Text('Ver Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
          ),
          NumericKeypad(
            onCheckoutPressed: _openCheckoutDialog,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES PARA TABLET / DESKTOP
  // ==========================================

  Widget _buildTabletCatalogPanel(InventoryProvider inv) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Barra de búsqueda rápida
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: SizedBox(
              height: 38,
              child: TextField(
                onChanged: inv.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Buscar producto o código...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),

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
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletTicketPanel(PosProvider pos, List<dynamic> cart) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700), maxLines: 1),
                                  Text('\$${item.customPrice.toStringAsFixed(2)} c/u', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
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
    );
  }

  Widget _buildProductCard(Product product) {
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
