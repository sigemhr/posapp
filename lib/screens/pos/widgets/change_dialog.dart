import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/pos_provider.dart';
import '../../../providers/customer_provider.dart';

class ChangeDialog extends StatefulWidget {
  final PosProvider pos;

  const ChangeDialog({super.key, required this.pos});

  @override
  State<ChangeDialog> createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  double _paidAmount = 0.0;
  String _paymentMethod = 'Efectivo';
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _paidAmount = widget.pos.currentTotal; // Por defecto importe exacto
    _paidController.text = _paidAmount.toStringAsFixed(_paidAmount % 1 == 0 ? 0 : 2);
  }

  void _setPaidAmount(double amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _paidAmount = amount;
      _paidController.text = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.pos.currentTotal;
    final change = (_paidAmount - total).clamp(0.0, 999999.0);
    final isShort = _paidAmount > 0 && _paidAmount < total;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cobrar Ticket',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total a Cobrar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3730A3)),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)} MXN',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Métodos de Pago
              Row(
                children: [
                  _buildMethodChip('Efectivo', Icons.money),
                  const SizedBox(width: 6),
                  _buildMethodChip('Tarjeta', Icons.credit_card),
                  const SizedBox(width: 6),
                  _buildMethodChip('CoDi / QR', Icons.qr_code_2),
                  const SizedBox(width: 6),
                  _buildMethodChip('Fiado', Icons.menu_book),
                ],
              ),
              const SizedBox(height: 16),

              if (_paymentMethod == 'Efectivo') ...[
                // Campo editable para teclear con cuánto paga (ej. $17.50, $20, $50.50)
                TextField(
                  controller: _paidController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    labelText: 'Paga con (Efectivo recibido):',
                    hintText: 'Ej. 20 ó 17.50',
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 20),
                      onPressed: () {
                        _paidController.clear();
                        setState(() => _paidAmount = 0.0);
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val) ?? 0.0;
                    setState(() {
                      _paidAmount = parsed;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Botones rápidos de billetes y monedas mexicanas
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildQuickCashButton(total, 'Exacto (\$${total.toStringAsFixed(2)})'),
                    if (total <= 20) _buildQuickCashButton(20.0, '\$20'),
                    if (total <= 50) _buildQuickCashButton(50.0, '\$50'),
                    if (total <= 100) _buildQuickCashButton(100.0, '\$100'),
                    if (total <= 200) _buildQuickCashButton(200.0, '\$200'),
                    if (total <= 500) _buildQuickCashButton(500.0, '\$500'),
                    if (total <= 1000) _buildQuickCashButton(1000.0, '\$1000'),
                  ],
                ),
                const SizedBox(height: 14),

                // Indicador de Cambio o Faltante
                if (isShort) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FALTAN:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                        ),
                        Text(
                          '\$${(total - _paidAmount).toStringAsFixed(2)} MXN',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFEA580C)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CAMBIO:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                        Text(
                          '\$${change.toStringAsFixed(2)} MXN',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ),
                ],
            ] else if (_paymentMethod == 'Fiado') ...[
              Consumer<CustomerProvider>(
                builder: (context, custProv, _) {
                  final customers = custProv.customers;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (customers.isNotEmpty) ...[
                        const Text(
                          'Selecciona un vecino registrado:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: customers.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 6),
                            itemBuilder: (context, i) {
                              final c = customers[i];
                              final isSelected = _selectedCustomerId == c.id;
                              return ChoiceChip(
                                label: Text(c.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                selected: isSelected,
                                selectedColor: const Color(0xFFDC2626),
                                labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1E293B)),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCustomerId = c.id;
                                      _customerController.text = c.displayName;
                                    } else {
                                      _selectedCustomerId = null;
                                      _customerController.clear();
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextField(
                        controller: _customerController,
                        onChanged: (val) {
                          if (_selectedCustomerId != null) {
                            setState(() => _selectedCustomerId = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Nombre del vecino / cliente',
                          hintText: 'Ej. Doña Carmen / Don Juan',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (_selectedCustomerId != null) ...[
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final c = custProv.findById(_selectedCustomerId!);
                            if (c == null) return const SizedBox.shrink();
                            return Text(
                              'Saldo actual: \$${c.currentDebt.toStringAsFixed(2)} | Límite: \$${c.creditLimit.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w700),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 20),

            // Botón de Confirmación
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  final custName = _customerController.text.trim();
                  final ticket = widget.pos.completeSale(
                    paidAmount: _paymentMethod == 'Efectivo' ? _paidAmount : total,
                    paymentMethod: _paymentMethod,
                    customerName: custName.isNotEmpty ? custName : null,
                    customerId: _selectedCustomerId,
                  );

                  // Si fue fiado y hay un cliente vinculado, sumar cargo
                  if (_paymentMethod == 'Fiado' && _selectedCustomerId != null) {
                    context.read<CustomerProvider>().addCreditSale(
                          customerId: _selectedCustomerId!,
                          amount: total,
                        );
                  }

                  Navigator.pop(context, ticket);
                },
                icon: const Icon(Icons.check_circle, size: 22),
                label: const Text('FINALIZAR COBRO', style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMethodChip(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _paymentMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF475569)),
              const SizedBox(height: 4),
              Text(
                method,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCashButton(double amount, String label) {
    final isSelected = (_paidAmount - amount).abs() < 0.01;
    return ElevatedButton(
      onPressed: () => _setPaidAmount(amount),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(60, 42),
        backgroundColor: isSelected ? const Color(0xFF3730A3) : const Color(0xFFF8FAFC),
        foregroundColor: isSelected ? Colors.white : const Color(0xFF1E293B),
        side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
