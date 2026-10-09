import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/pos_provider.dart';

class NumericKeypad extends StatefulWidget {
  final VoidCallback onCheckoutPressed;

  const NumericKeypad({
    super.key,
    required this.onCheckoutPressed,
  });

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  bool _isKeypadExpanded = true;
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _addQuickDeliItem(PosProvider pos, String name, String emoji) {
    if (pos.keypadBuffer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escribe primero el importe para "$name" (ej. 17.50) en el teclado'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4F46E5),
        ),
      );
      return;
    }
    pos.addCustomAmount(name: name, iconEmoji: emoji, category: 'Granel');
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final buffer = pos.keypadBuffer;
    final total = pos.currentTotal;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
            if (pos.keypadBuffer.isNotEmpty) {
              pos.addCustomAmount();
            }
          } else if (key == LogicalKeyboardKey.backspace) {
            pos.keypadInput('⌫');
          } else if (key == LogicalKeyboardKey.escape) {
            pos.keypadInput('C');
          } else if (key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) {
            pos.keypadInput('.');
          } else if (event.character != null && RegExp(r'^[0-9]$').hasMatch(event.character!)) {
            pos.keypadInput(event.character!);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pantalla de Marcar Importe Directo (ej. 17.50 de jamón)
            Row(
              children: [
                // Pantalla de entrada
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: buffer.isNotEmpty ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                        width: buffer.isNotEmpty ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Importe: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              buffer.isEmpty ? '\$0.00' : '\$$buffer',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: buffer.isEmpty
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                        if (buffer.isNotEmpty)
                          Row(
                            children: [
                              InkWell(
                                onTap: () => pos.keypadInput('⌫'),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.backspace_outlined, size: 18, color: Color(0xFF64748B)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => pos.keypadInput('C'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Botón para expandir/colapsar teclado táctil
                IconButton(
                  tooltip: _isKeypadExpanded ? 'Ocultar teclado táctil' : 'Mostrar teclado táctil',
                  onPressed: () => setState(() => _isKeypadExpanded = !_isKeypadExpanded),
                  icon: Icon(
                    _isKeypadExpanded ? Icons.keyboard_hide_outlined : Icons.keyboard_outlined,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Botones de acceso rápido para Granel y Cremería común
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickDeliChip(pos, '🥓 Jamón', () => _addQuickDeliItem(pos, 'Jamón a granel', '🥓')),
                  _buildQuickDeliChip(pos, '🧀 Queso', () => _addQuickDeliItem(pos, 'Queso a granel', '🧀')),
                  _buildQuickDeliChip(pos, '🫓 Tortillas', () => _addQuickDeliItem(pos, 'Tortillas', '🫓')),
                  _buildQuickDeliChip(pos, '🥚 Huevo', () => _addQuickDeliItem(pos, 'Huevo', '🥚')),
                  _buildQuickDeliChip(pos, '🥖 Bolillo', () => _addQuickDeliItem(pos, 'Bolillo / Pan', '🥖')),
                  _buildQuickDeliChip(pos, '🏷️ Venta Común', () => pos.addCustomAmount(name: 'Venta Común')),
                ],
              ),
            ),

            // Teclado Numérico Táctil Estándar (1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 00, ., C, ⌫, AGREGAR)
            if (_isKeypadExpanded) ...[
              const SizedBox(height: 6),
              Column(
                children: [
                  Row(
                    children: [
                      _buildKeypadButton('1', pos),
                      _buildKeypadButton('2', pos),
                      _buildKeypadButton('3', pos),
                      _buildKeypadButton('⌫', pos, label: '⌫', isAction: true, onTap: () => pos.keypadInput('⌫')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildKeypadButton('4', pos),
                      _buildKeypadButton('5', pos),
                      _buildKeypadButton('6', pos),
                      _buildKeypadButton('C', pos, label: 'C', isAction: true, onTap: () => pos.keypadInput('C')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildKeypadButton('7', pos),
                      _buildKeypadButton('8', pos),
                      _buildKeypadButton('9', pos),
                      _buildKeypadButton('.', pos, label: '.', isAction: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildKeypadButton('0', pos),
                      _buildKeypadButton('00', pos, label: '00', onTap: () {
                        pos.keypadInput('0');
                        pos.keypadInput('0');
                      }),
                      // Botón Agregar Importe Directo
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: buffer.isEmpty ? null : () => pos.addCustomAmount(),
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: Text(
                                buffer.isEmpty ? 'AGREGAR' : 'AGREGAR \$$buffer',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFF1F5F9),
                                disabledForegroundColor: const Color(0xFF94A3B8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Botón Gigante de Cobro
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: total > 0 ? widget.onCheckoutPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669), // Verde cobro
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          total > 0 ? 'COBRAR' : 'TICKET VACÍO',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)} MXN',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String val,
    PosProvider pos, {
    String? label,
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: onTap ?? () => pos.keypadInput(val),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: isAction ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
              foregroundColor: isAction ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
              elevation: 0,
              side: BorderSide(
                color: isAction ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              label ?? val,
              style: TextStyle(
                fontSize: isAction ? 12 : 16,
                fontWeight: isAction ? FontWeight.bold : FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDeliChip(PosProvider pos, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF1F5F9),
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: onTap,
      ),
    );
  }
}
