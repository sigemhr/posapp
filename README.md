# PuntoZen POS

Point-of-sale application for small retail businesses, built with **Flutter and Dart**.

**Status: in development.** This repository contains application code; store publication, payment processing, advertising delivery and hardware compatibility are not verified by this documentation.

## Application areas

- Checkout and sales tickets, including parked tickets and change calculation.
- Product catalog and inventory screens.
- Customer credit records and payment tracking.
- Sales reporting and module configuration screens.
- Camera barcode scanning integration through `mobile_scanner`.

## Technical stack

- Flutter / Dart — application and UI.
- Provider — state management.
- SharedPreferences — local persistence.
- Material 3 and Google Fonts — interface styling.

This project is distinct from the separate vikyPOS codebase that uses Riverpod and Drift.

## Architecture

```text
lib/
├── core/theme/     # Application theme
├── data/           # Product dataset
├── models/         # Products, tickets, customers and credit payments
├── providers/      # Checkout, inventory, customers and module state
├── screens/        # Checkout, inventory, credit, reports and modules
└── services/       # Local storage
```

## Run locally

Install Flutter with a Dart SDK compatible with `pubspec.yaml` and configure a target device.

```bash
git clone https://github.com/sigemhr/posapp.git
cd posapp
flutter pub get
flutter devices
flutter run
```

## Development checks

```bash
flutter analyze
flutter test
```

These are commands to run locally; their current results are not asserted here.

## Author

**Alexis Duarte García** — Senior Full Stack Developer  
[GitHub](https://github.com/sigemhr) · [LinkedIn](https://www.linkedin.com/in/alexis-duarte-1a1a61138/)

## Español

Aplicación de punto de venta en desarrollo para pequeños comercios. Incluye pantallas de caja, inventario, crédito a clientes y reportes; utiliza Flutter, Provider y persistencia local con SharedPreferences.
