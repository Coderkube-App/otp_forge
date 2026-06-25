import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Renders VerificationScreen smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OtpForgeExampleApp());

    // Verify that the screen title is present.
    expect(find.text('Verify your phone'), findsOneWidget);
  });
}
