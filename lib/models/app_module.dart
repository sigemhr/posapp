class AppModule {
  final String id;
  final String name;
  final String description;
  final double priceMxn;
  final String icon;
  final bool isProFeature;

  const AppModule({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMxn,
    required this.icon,
    this.isProFeature = true,
  });

  static const List<AppModule> catalog = [
    AppModule(
      id: 'no_ads',
      name: 'Eliminar Anuncios',
      description: 'Quita los anuncios de la pantalla de cobro y cortes para siempre.',
      priceMxn: 99.0,
      icon: '🚫',
    ),
    AppModule(
      id: 'barcode_scanner',
      name: 'Lector de Código de Barras',
      description: 'Usa la cámara como escáner ultra-rápido o conecta lectores Bluetooth/USB.',
      priceMxn: 99.0,
      icon: '📷',
    ),
    AppModule(
      id: 'inventory_control',
      name: 'Inventarios y Mermas',
      description: 'Alertas de stock bajo, cálculo de ganancias y conteo físico rápido.',
      priceMxn: 149.0,
      icon: '📊',
    ),
    AppModule(
      id: 'credit_book',
      name: 'Libreta de Fiado',
      description: 'Lleva las cuentas que te deben los vecinos y envíales recordatorio por WhatsApp con su ticket.',
      priceMxn: 79.0,
      icon: '📒',
    ),
    AppModule(
      id: 'thermal_printer',
      name: 'Impresora Térmica & Cajón',
      description: 'Imprime tickets térmicos por Bluetooth (58mm/80mm) y abre la gaveta de dinero.',
      priceMxn: 99.0,
      icon: '🖨️',
    ),
    AppModule(
      id: 'all_inclusive_pro',
      name: 'Paquete PRO Todo Incluido',
      description: 'Desbloquea todos los módulos para siempre y elimina todos los anuncios con 40% de descuento.',
      priceMxn: 299.0,
      icon: '⭐',
    ),
  ];
}
