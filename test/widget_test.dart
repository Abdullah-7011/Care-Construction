import 'package:flutter_test/flutter_test.dart';
import 'package:care_construction/main.dart';

void main() {
  testWidgets('Care Construction smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CareConstructionApp());
    expect(find.byType(CareConstructionApp), findsOneWidget);
  });
}
