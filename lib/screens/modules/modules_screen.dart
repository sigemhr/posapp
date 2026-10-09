import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/module_provider.dart';
import '../../models/app_module.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Módulos y Desbloqueos',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de Propuesta: Cero suscripciones mensuales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: Color(0xFF38BDF8), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'PAGO ÚNICO • DE POR VIDA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFBAE6FD),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Sin mensualidades ni cobros sorpresa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'El nivel básico de cobro es 100% GRATIS con anuncios. Desbloquea las herramientas que tu negocio necesite una sola vez.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFE0E7FF), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Módulos Disponibles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          // Lista de Módulos
          ...AppModule.catalog.map((module) {
            final isUnlocked = moduleProvider.isUnlocked(module.id);
            final isProBundle = module.id == 'all_inclusive_pro';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isProBundle ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                  width: isProBundle ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isProBundle ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(module.icon, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  module.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                              if (isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Text(
                                    'ACTIVO',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.description,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                          ),
                          const SizedBox(height: 12),

                          // Precio y Botón de Desbloqueo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${module.priceMxn.toStringAsFixed(0)} MXN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isProBundle ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
                                ),
                              ),
                              if (!isUnlocked)
                                ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.heavyImpact();
                                    moduleProvider.unlockModule(module.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('¡Módulo "${module.name}" desbloqueado con éxito!'),
                                        backgroundColor: const Color(0xFF059669),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isProBundle ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 38),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: Text(
                                    isProBundle ? 'COMPRAR PRO' : 'DESBLOQUEAR',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          // Botón para reiniciar demos de compra
          Center(
            child: TextButton(
              onPressed: () {
                moduleProvider.resetAllModules();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulos restablecidos a modo gratuito con anuncios.')),
                );
              },
              child: const Text('Restablecer a modo gratuito de prueba', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
