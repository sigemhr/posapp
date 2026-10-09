# CLAUDE.md - Guía de Arquitectura y Desarrollo para Claude

Este archivo proporciona el contexto completo, diseño de arquitectura, convenciones y flujo de datos del proyecto **PuntoZen POS** para que Claude (o cualquier modelo de lenguaje / desarrollador) pueda entender rápidamente el sistema y continuar su desarrollo sin fricción.

---

## 📌 1. Visión General del Proyecto

**PuntoZen POS** es una aplicación móvil y de escritorio de **Punto de Venta (POS) e Inventario** desarrollada en **Flutter (Dart)**, diseñada específicamente para el contexto comercial de **tienditas de la esquina, abarrotes y minisúpers en México y Latinoamérica**.

### Problemas que resuelve:
1. **Cobro ultra-rápido en mostrador**: Soporte de tickets simultáneos para no frenar la fila ("Ticket 2 en espera"), teclado numérico táctil para importes libres y cálculo de cambio con denominaciones de billetes mexicanos (\$50, \$100, \$200, \$500, \$1000).
2. **Catálogo Maestro Precargado (Estilo Eleventa)**: Base de datos precargada con más de 140 de los artículos de mayor rotación en México (Coca-Cola, Sabritas, Bimbo, Lácteos Lala, Abarrotes, Limpieza, Granel) con códigos de barra reales GS1 EAN-13 (prefijo 750), precios de venta sugeridos y costos de compra promedio.
3. **Venta a granel / mostrador**: Soporte nativo para productos que se venden por importe o peso variable (huevo, jamón, queso oaxaca, tortillas, frutas/verduras) sin necesidad obligatoria de báscula electrónica.
4. **Libreta de Fiado Digital**: Control de cuentas corrientes de clientes frecuentes con registro de deuda, abonos parciales, límite de crédito y notas de cobro.
5. **Modelo Freemium / Pago Único**: Gratuito con anuncios discretos; módulos avanzados desbloqueables mediante compra única sin mensualidades.

---

## 🛠️ 2. Stack Tecnológico

- **Framework**: Flutter 3.x (soporte Web, Android, Windows, iOS, macOS, Linux).
- **Lenguaje**: Dart 3.13+.
- **Gestión de Estado**: `provider: ^6.1.5+1` (`ChangeNotifierProvider`, `MultiProvider`).
- **Almacenamiento Local**: `shared_preferences: ^2.5.6` con serialización JSON (`StorageService`).
- **Formateo e Internacionalización**: `intl: ^0.20.3` (moneda mexicana MXN, fechas en español).
- **Tipografía y Estilo**: `google_fonts: ^6.2.1` (`Inter`, `Plus Jakarta Sans`) bajo Material 3.

---

## 📂 3. Estructura de Directorios

```text
puntozen_pos/
├── lib/
│   ├── main.dart                          # Punto de entrada, inicialización de providers y tema
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart             # Paleta de colores M3 (Índigo #4F46E5, Esmeralda #059669)
│   ├── data/
│   │   └── tiendita_dataset.dart          # Catálogo maestro (+140 productos estilo Eleventa) y helpers
│   ├── models/
│   │   ├── product.dart                   # Modelo Producto (código, precio, costo, stock, granel)
│   │   ├── cart_item.dart                 # Ítem en el ticket de compra actual
│   │   ├── sale_ticket.dart               # Ticket de venta finalizado (folio, método de pago, cambio)
│   │   ├── customer.dart                  # Cliente de la libreta de fiado (deuda, límite de crédito)
│   │   ├── credit_payment.dart            # Abono registrado a una cuenta de fiado
│   │   └── app_module.dart                # Definición de módulos de pago único
│   ├── providers/
│   │   ├── pos_provider.dart              # Lógica de cobro, carrito, 2 tickets simultáneos, métricas de hoy
│   │   ├── inventory_provider.dart        # Gestión de inventario, filtros, stock y merge con catálogo maestro
│   │   ├── customer_provider.dart         # Libreta de fiado, saldos, límites y abonos
│   │   └── module_provider.dart           # Estado de desbloqueo de módulos premium
│   ├── screens/
│   │   ├── home_screen.dart               # Navegación principal (tabs inferiores)
│   │   ├── pos/
│   │   │   ├── pos_screen.dart            # Pantalla principal de cobro con búsqueda rápida y split view
│   │   │   └── widgets/
│   │   │       ├── change_dialog.dart     # Diálogo de cobro y cálculo de cambio con billetes MXN
│   │   │       ├── numeric_keypad.dart    # Teclado numérico táctil para venta común
│   │   │       ├── receipt_dialog.dart    # Ticket digital con desglose para imprimir o compartir
│   │   │       └── ad_banner_widget.dart  # Banner publicitario removible
│   │   ├── inventory/
│   │   │   └── inventory_screen.dart      # Catálogo de productos, botón Eleventa y alta con autocompletado
│   │   ├── credit/
│   │   │   └── credit_book_screen.dart    # Libreta de fiado, listado de deudores y registro de abonos
│   │   ├── reports/
│   │   │   └── reports_screen.dart        # Reportes de ventas del día, márgenes y métricas
│   │   └── modules/
│   │       └── modules_screen.dart        # Tienda de módulos de pago único
│   └── services/
│       └── storage_service.dart           # Persistencia local (SharedPreferences) y migración v1 -> v2
└── pubspec.yaml                           # Dependencias y configuración de assets/fuentes
```

---

## 🧩 4. Módulos y Flujos de Datos Clave

### A. Catálogo Maestro estilo Eleventa (`lib/data/tiendita_dataset.dart`)
- **Contenido**: Más de 185 productos organizados en 14 categorías esenciales de tienditas mexicanas:
  - `Refrescos`, `Bebidas & Jugos`, `Botanas & Frituras`, `Galletas & Panecillos`, `Lácteos & Huevos`, `Carnes Frías`, `Abarrotes & Despensa`, `Dulces & Golosinas`, `Higiene Personal`, `Limpieza del Hogar` (ampliada con servilletas, servitoallas, papel aluminio, insecticidas, franelas, jergas, guantes), `Papelería & Escolares` (cuadernos Scribe, lápices Mirado, bolígrafos Bic, gomas, sacapuntas, pegamento Pritt, Resistol, tijeras, cintas Diurex/canela, cartulinas, hojas bond), `Farmacia & Varios` (pilas alcalinas Duracell, Sal de Uvas Picot, Alka-Seltzer, Aspirina, Paracetamol, Curitas, cinta de aislar), `Cigarros & Fósforos`, `Granel & Mostrador`.
- **EAN-13**: Códigos oficiales de México (prefijo `750...` y marcas registradas).
- **Helpers**:
  - `searchInTienditaCatalog(query)`: Búsqueda flexible por texto, categoría o código.
  - `findInTienditaCatalogByBarcode(barcode)`: Búsqueda exacta por código de barras.

### B. Inventario y Sincronización (`lib/providers/inventory_provider.dart`)
- **`importMasterCatalog({bool overwrite})`**:
  - `overwrite = false`: Fusiona los productos del catálogo maestro que falten en el inventario actual (sin duplicar ni alterar los productos personalizados ya creados).
  - `overwrite = true`: Restablece el inventario completo a los más de 185 productos maestros.
- **Autocompletado en Alta de Producto**:
  - Al ingresar o escanear un código de barras en el formulario de nuevo producto (`inventory_screen.dart`), el sistema busca en el catálogo maestro y autorellena: nombre, precio sugerido, costo de compra, categoría, emoji y si es a granel.

### C. Pantalla de Cobro POS Responsiva (`lib/screens/pos/pos_screen.dart`)
- **Diseño Adaptativo Móvil vs Tablet (`isMobile < 700px`)**:
  - **En Celulares (`< 700px`)**: 
    - Se elimina la división horizontal forzada en dos columnas estrechas.
    - Se implementa una navegación por pestañas optimizada para una sola mano: `[🛍️ Catálogo]`, `[🧾 Ticket (X)]`, `[🔢 Teclado]`.
    - **Catálogo a ancho completo**: Tarjetas legibles con espacio táctil holgado, búsqueda rápida y filtros.
    - **Barra Flotante de Cobro**: Al agregar artículos, aparece un pill flotante inferior (`🛒 3 arts • $65.00` | `Ver Ticket` | `Cobrar`) para cobrar rápidamente sin salir del catálogo.
    - **Ticket a ancho completo**: Lista espaciosa con botones grandes de cantidad `[-]` y `[+]`, desglose de subtotales y botón gigante de cobro.
    - **Teclado Táctil a ancho completo**: Accesos directos a cremería/granel y venta común sin robar espacio vertical al catálogo.
  - **En Tablets y Desktop (`>= 700px`)**:
    - Conserva la vista dual dividida (*split view*): Catálogo a la izquierda (`flex: 6`), Ticket en tiempo real a la derecha (`flex: 5`) y Teclado Numérico fijo al fondo.
- **Multi-Ticket**: Manejo de `Ticket 1` y `Ticket 2 (En Espera)` mediante `PosProvider.switchTicketTab(index)`.
- **Buscador en Tiempo Real**: Input de búsqueda sobre los filtros de categoría para encontrar cualquier producto rápidamente.
- **Lector de Código de Barras**:
  - Si el código existe en el inventario local, lo agrega al ticket.
  - Si el código no está en el inventario local pero existe en el **Catálogo Maestro**, lo importa al inventario y lo agrega al ticket automáticamente.
- **Venta a Granel**: Diálogo modal para especificar importe o peso en pesos mexicanos (\$10, \$15, \$17.50, \$20, \$50, o libre).

### D. Persistencia y Migración (`lib/services/storage_service.dart`)
- Llaves en `SharedPreferences`:
  - `puntozen_products_v3`: Clave actual de productos. Si no existe, migra automáticamente desde v2 o v1 fusionando los nuevos artículos del catálogo maestro sin pérdida de datos personalizados.
  - `puntozen_sales_v1`: Historial de tickets y ventas.
  - `puntozen_customers_v1`: Clientes de la libreta de fiado.
  - `puntozen_payments_v1`: Abonos y pagos de deuda.

---

## 💻 5. Comandos Frecuentes

```bash
# Analizar código y verificar linter (0 issues)
flutter analyze

# Ejecutar en el navegador para desarrollo rápido con Hot Reload (tecla 'r')
flutter run -d edge
# o
flutter run -d chrome

# Ejecutar en dispositivo físico Android (con depuración USB activa)
flutter run

# Compilar APK de producción para Android
flutter build apk --release
```

---

## 🎨 6. Convenciones de Código y Diseño

1. **Material Design 3**: Utilizar esquinas redondeadas consistentes (`BorderRadius.circular(12)` a `20`), sombras suaves y contrastes legibles para pantallas táctiles.
2. **Moneda y Precios**: Formatear siempre con el signo `$` seguido de dos decimales (ej. `\$${price.toStringAsFixed(2)}`).
3. **Escritura Asíncrona**: Siempre que se modifique el estado en un `Provider` que requiera persistencia, llamar a los métodos estáticos de `StorageService` (`saveProducts`, `saveSales`, etc.) de forma asíncrona.
4. **Verificación de Montado**: Al invocar `Navigator` o `ScaffoldMessenger` tras operaciones `async`, utilizar la comprobación `if (context.mounted)` para respetar las reglas de Flutter lints.
