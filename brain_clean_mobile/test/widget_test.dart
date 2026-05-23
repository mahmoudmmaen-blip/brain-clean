import 'package:brain_clean_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Diagnostic screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BrainCleanApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Diagnostic 6-Point Test'), findsOneWidget);
    expect(find.text('BRAIN CLARITY SCORE'), findsOneWidget);
    expect(find.textContaining('Live'), findsOneWidget);
  });
}
