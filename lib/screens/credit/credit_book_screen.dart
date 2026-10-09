import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer.dart';

class CreditBookScreen extends StatelessWidget {
  const CreditBookScreen({super.key});

  void _openAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final nicknameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final limitCtrl = TextEditingController(text: '1500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Nuevo Vecino / Cliente', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  hintText: 'Ej. Carmen Rodríguez',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nicknameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apodo / Referencia (Opcional)',
                  hintText: 'Ej. Doña Carmen de la esquina',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono celular (WhatsApp)',
                  hintText: '10 dígitos (ej. 5512345678)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Límite de crédito',
                  prefixText: '\$',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final newCust = Customer(
                  id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  nickname: nicknameCtrl.text.trim().isNotEmpty ? nicknameCtrl.text.trim() : null,
                  phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                  creditLimit: double.tryParse(limitCtrl.text) ?? 1500.0,
                  currentDebt: 0.0,
                  lastActivity: DateTime.now(),
                );
                context.read<CustomerProvider>().addCustomer(newCust);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vecino "$name" agregado a la libreta'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _openPaymentDialog(BuildContext context, Customer customer) {
    final amountCtrl = TextEditingController(
      text: customer.currentDebt > 0 ? customer.currentDebt.toStringAsFixed(0) : '50',
    );
    final notesCtrl = TextEditingController(text: 'Abono en efectivo');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.payments_outlined, color: Color(0xFF059669)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Registrar Abono: ${customer.name}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo pendiente:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    '\$${customer.currentDebt.toStringAsFixed(2)} MXN',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
              decoration: const InputDecoration(
                labelText: 'Monto a Abonar *',
                prefixText: '\$ ',
                prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
              ),
            ),
            const SizedBox(height: 10),
            // Botones rápidos para abono
            Wrap(
              spacing: 6,
              children: [
                if (customer.currentDebt > 0)
                  ActionChip(
                    label: const Text('Liquidar Todo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFFDCFCE7),
                    onPressed: () {
                      amountCtrl.text = customer.currentDebt.toStringAsFixed(2);
                    },
                  ),
                ActionChip(
                  label: const Text('\$50', style: TextStyle(fontSize: 11)),
                  onPressed: () => amountCtrl.text = '50',
                ),
                ActionChip(
                  label: const Text('\$100', style: TextStyle(fontSize: 11)),
                  onPressed: () => amountCtrl.text = '100',
                ),
                ActionChip(
                  label: const Text('\$200', style: TextStyle(fontSize: 11)),
                  onPressed: () => amountCtrl.text = '200',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0.0;
              if (amount > 0) {
                context.read<CustomerProvider>().registerPayment(
                      customerId: customer.id,
                      amount: amount,
                      notes: notesCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Abono de \$${amount.toStringAsFixed(2)} registrado exitosamente'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Abono'),
          ),
        ],
      ),
    );
  }

  void _showWhatsAppMessageDialog(BuildContext context, Customer customer) {
    final prov = context.read<CustomerProvider>();
    final url = prov.buildWhatsAppUrl(customer);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.chat, color: Color(0xFF25D366)),
            SizedBox(width: 8),
            Text('Cobro por WhatsApp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${customer.displayName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (customer.phone != null)
              Text('Teléfono: ${customer.phone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Hola ${customer.name}, buen día 👋 le saludamos de su Tiendita de confianza 🛒. '
                'Le compartimos que su saldo actual en la libreta de fiado es de \$${customer.currentDebt.toStringAsFixed(2)} MXN. '
                '¡Cualquier duda quedamos a sus órdenes!',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Al pulsar Copiar Enlace, puedes abrir WhatsApp Web o pegarlo directamente en el chat con tu cliente.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enlace de WhatsApp copiado al portapapeles'),
                  backgroundColor: Color(0xFF25D366),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copiar Enlace WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProvider = context.watch<CustomerProvider>();
    final customers = custProvider.customers;
    final totalDebt = custProvider.totalOutstandingDebt;
    final debtorCount = custProvider.debtorCount;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Libreta de Fiado', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Agregar Cliente Fiado',
            onPressed: () => _openAddCustomerDialog(context),
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4F46E5),
              child: Icon(Icons.person_add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de Cartera Total Fiada
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33EF4444),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.white70, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'TOTAL FIADO EN LA CALLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${totalDebt.toStringAsFixed(2)} MXN',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$debtorCount',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const Text(
                        'con saldo',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Buscador de Clientes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: custProvider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar vecino por nombre, apodo o cel...',
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
          const SizedBox(height: 12),

          // Lista de Vecinos y Cuentas
          Expanded(
            child: customers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 8),
                        Text('No se encontraron clientes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: customers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final hasDebt = customer.currentDebt > 0;
                      final percentUsed = (customer.currentDebt / customer.creditLimit).clamp(0.0, 1.0);

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: hasDebt ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                            width: hasDebt ? 1.5 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: hasDebt ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                    child: Text(
                                      customer.name.substring(0, customer.name.isNotEmpty ? 1 : 0).toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: hasDebt ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.displayName,
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                        ),
                                        if (customer.phone != null)
                                          Text(
                                            '📱 ${customer.phone}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${customer.currentDebt.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: hasDebt ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                        ),
                                      ),
                                      Text(
                                        hasDebt ? 'Debe' : 'Al corriente',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: hasDebt ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Barra de crédito
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentUsed,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percentUsed > 0.8
                                        ? const Color(0xFFDC2626)
                                        : (percentUsed > 0.5 ? const Color(0xFFEA580C) : const Color(0xFF059669)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Límite: \$${customer.creditLimit.toStringAsFixed(0)} MXN',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                  Text(
                                    'Último mov: ${dateFormat.format(customer.lastActivity)}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Botones de Acción
                              Row(
                                children: [
                                  // Botón Cobro por WhatsApp
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showWhatsAppMessageDialog(context, customer),
                                      icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF25D366)),
                                      label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        side: const BorderSide(color: Color(0xFF86EFAC)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Botón Registrar Abono
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openPaymentDialog(context, customer),
                                      icon: const Icon(Icons.add_card, size: 16),
                                      label: const Text('Abonar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
