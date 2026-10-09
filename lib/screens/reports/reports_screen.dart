import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final sales = pos.salesHistory;

    double cashTotal = 0;
    double cardTotal = 0;
    double creditTotal = 0;

    for (final ticket in sales) {
      if (ticket.paymentMethod == 'Efectivo') {
        cashTotal += ticket.total;
      } else if (ticket.paymentMethod == 'Tarjeta') {
        cardTotal += ticket.total;
      } else if (ticket.paymentMethod == 'Fiado') {
        creditTotal += ticket.total;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corte de Caja del Día (Corte Z)', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen General
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VENTAS TOTALES HOY', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  '\$${pos.todayTotalSales.toStringAsFixed(2)} MXN',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${pos.todayTicketsCount} tickets cobrados', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Turno Abierto', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Desglose por método de pago
          Row(
            children: [
              _buildMetricCard('Efectivo en Caja', '\$${cashTotal.toStringAsFixed(2)}', Icons.payments, const Color(0xFF059669)),
              const SizedBox(width: 8),
              _buildMetricCard('Tarjeta / QR', '\$${cardTotal.toStringAsFixed(2)}', Icons.credit_card, const Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              _buildMetricCard('Fiado Pendiente', '\$${creditTotal.toStringAsFixed(2)}', Icons.menu_book, const Color(0xFFEA580C)),
            ],
          ),
          const SizedBox(height: 24),

          // Historial de tickets
          const Text('Últimos Tickets del Día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),

          if (sales.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 8),
                  Text('No hay ventas registradas en este turno aún', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            ...sales.map((ticket) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        '#${ticket.folio}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                      ),
                    ),
                    title: Text(
                      '${ticket.paymentMethod} ${ticket.customerName != null ? "• ${ticket.customerName}" : ""}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      '${ticket.items.length} artículos  •  ${ticket.date.hour}:${ticket.date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: Text(
                      '\$${ticket.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF059669)),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
