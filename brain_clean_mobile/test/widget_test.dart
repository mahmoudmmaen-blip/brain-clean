import 'package:brain_clean_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Diagnostic screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BrainCleanApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Diagnostic 6-Point Test'), findsOneWidget);
    expect(find.text('Start Brain Clean'), findsOneWidget);
  });
}
