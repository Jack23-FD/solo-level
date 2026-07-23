import 'package:flutter_test/flutter_test.dart';
import 'package:sololeveling/main.dart';

void main() {
  testWidgets('SoloLevelApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloLevelApp());
    expect(find.byType(SoloLevelApp), findsOneWidget);
  });
}
