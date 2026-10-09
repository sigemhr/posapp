import 'package:flutter/material.dart';
import '../../../models/sale_ticket.dart';

class ReceiptDialog extends StatelessWidget {
  final SaleTicket ticket;

  const ReceiptDialog({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono de Éxito
            const Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(Icons.check, color: Color(0xFF059669), size: 32),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '¡Cobro Exitoso!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 16),

            // Ticket térmico estilizado
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    '*** TIENDITA PUNTOZEN ***',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[800]),
                  ),
                  Text(
                    'Folio: #${ticket.folio.toString().padLeft(5, '0')}  •  ${ticket.paymentMethod}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const Divider(height: 16),

                  // Lista de artículos
                  ...ticket.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity.toInt()}x ${item.product.name}',
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),

                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      Text('\$${ticket.total.toStringAsFixed(2)} MXN',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF059669))),
                    ],
                  ),
                  if (ticket.paymentMethod == 'Efectivo') ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pago con:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('\$${ticket.paidAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cambio entregado:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        Text('\$${ticket.changeAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF065F46))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botón Compartir por WhatsApp
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket listo para enviar por WhatsApp al cliente'),
                    backgroundColor: Color(0xFF25D366),
                  ),
                );
              },
              icon: const Icon(Icons.share, size: 18, color: Color(0xFF25D366)),
              label: const Text('Enviar Ticket por WhatsApp', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),

            // Botón Nuevo Cobro
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('NUEVO COBRO', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
