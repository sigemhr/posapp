# PuntoZen POS (Mobile App en Flutter)

Aplicación móvil de **Punto de Venta e Inventarios** desarrollada en **Flutter 3.47 con Dart 3.13**, diseñada específicamente para **tienditas de abarrotes, minisúpers y comercios de conveniencia**.

---

## 💡 Modelo de Negocio Implementado
1. **Nivel Básico (100% GRATIS):**
   * Cobro rápido en mostrador.
   * Teclado numérico ergonómico para marcar importes directos sin código (Venta Común).
   * Cálculo de cambio instantáneo con botones de billetes mexicanos (\$50, \$100, \$200, \$500, \$1000).
   * Tickets en espera (2 cuentas simultáneas para no pausar la fila).
   * **Monetización:** Banner discreto de anuncios AdMob en el pie de página.
2. **Desbloqueo por Módulos (Pago Único • Sin Mensualidades):**
   * **Eliminar Anuncios:** \$99 MXN.
   * **Lector de Código de Barras:** \$99 MXN (cámara o escáner Bluetooth/USB).
   * **Control de Inventarios & Mermas:** \$149 MXN.
   * **Libreta de Fiado & Cobro por WhatsApp:** \$79 MXN.
   * **Impresora Térmica & Cajón:** \$99 MXN (Bluetooth 58mm/80mm).
   * **Paquete PRO Todo Incluido:** \$299 MXN (desbloquea todo y quita anuncios de por vida).

---

## 🚀 Cómo Ejecutar la App en tu Computadora

Abre una terminal en la carpeta del proyecto y ejecuta:

### 1. Probar en el navegador (Microsoft Edge con Hot Reload)
```bash
cd "C:\Users\Alexis Duarte\Desktop\puntozen_pos"
flutter run -d edge
```
* **Hot Reload:** Puedes modificar cualquier pantalla o widget, presionar la tecla `r` en la terminal y ver los cambios reflejados en **0.5 segundos** en tu pantalla sin recargar.

### 2. Probar en tu celular Android (cuando lo conectes por USB)
1. Conecta tu teléfono Android a la PC con un cable USB.
2. Activa **"Depuración USB"** en las opciones de desarrollador de tu celular.
3. Ejecuta:
```bash
flutter run
```
La aplicación se instalará directamente en tu celular.

---

## 📁 Arquitectura del Código

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart          # Tema Material 3, Plus Jakarta Sans y alto contraste
├── data/
│   └── tiendita_dataset.dart       # Catálogo maestro de +140 artículos estilo Eleventa con EAN-13
├── models/
│   ├── product.dart                # Modelo de producto (código de barras, peso/granel, stock, costo)
│   ├── cart_item.dart              # Artículo en el ticket con cálculo de subtotal
│   ├── sale_ticket.dart            # Ticket de venta finalizado (folio, método de cobro, cambio)
│   ├── customer.dart               # Modelo de cliente de la libreta de fiado
│   ├── credit_payment.dart         # Registro de abono a cuenta corriente
│   └── app_module.dart             # Catálogo de módulos desbloqueables y precios
├── providers/
│   ├── pos_provider.dart           # Motor del POS (tickets en espera, teclado numérico, cobro)
│   ├── inventory_provider.dart     # Inventario, filtros, stock y merge con catálogo maestro
│   ├── customer_provider.dart      # Gestión de clientes, deudas y abonos
│   └── module_provider.dart        # Estado de módulos desbloqueados y persistencia
├── screens/
│   ├── home_screen.dart            # Navegación principal (Caja, Inventario, Libreta, Módulos, Corte Z)
│   ├── pos/
│   │   ├── pos_screen.dart         # Pantalla táctil de cobro con búsqueda rápida y lector USB
│   │   └── widgets/
│   │       ├── numeric_keypad.dart # Teclado táctil ergonómico para el pulgar
│   │       ├── change_dialog.dart  # Modal de cambio con billetes mexicanos y fiado
│   │       ├── receipt_dialog.dart # Ticket térmico simulado con envío a WhatsApp
│   │       └── ad_banner_widget.dart # Banner de anuncios del nivel gratuito
│   ├── inventory/
│   │   └── inventory_screen.dart   # Búsqueda, botón Catálogo Eleventa y alta con autocompletado
│   ├── credit/
│   │   └── credit_book_screen.dart # Libreta de fiado digital y abonos
│   ├── modules/
│   │   └── modules_screen.dart     # Tienda de desbloqueos con pago único
│   └── reports/
│       └── reports_screen.dart     # Corte Z de caja con desglose de efectivo, tarjetas y fiados
└── services/
    └── storage_service.dart        # Persistencia local (SharedPreferences) y migración automática v1 -> v2
```

> 📄 **Documentación para Asistentes de IA**: Consulta [`CLAUDE.md`](file:///c:/Users/Alexis%20Duarte/Desktop/puntozen_pos/CLAUDE.md) para una guía detallada del flujo de datos, convenciones y arquitectura técnica del proyecto.

