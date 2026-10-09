import 'package:flutter_test/flutter_test.dart';
import 'package:puntozen_pos/main.dart';

void main() {
  testWidgets('PuntoZen POS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PuntoZenApp());
    expect(find.text('Abarrotes & Tiendita PuntoZen'), findsOneWidget);
  });
}
