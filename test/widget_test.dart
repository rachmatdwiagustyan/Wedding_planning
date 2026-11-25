import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planning/main.dart';

void main() {
  testWidgets('Talenta Event Organizer smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TalentaEventOrganizerApp());
    expect(find.byType(TalentaEventOrganizerApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
  });
}
