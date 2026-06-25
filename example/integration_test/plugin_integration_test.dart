import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:otp_forge/otp_forge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OtpController can be instantiated', (WidgetTester tester) async {
    final controller = OtpController(
      otpLength: 6,
      verifyOtp: (otp) async => true,
      onResend: () async {},
    );
    expect(controller, isNotNull);
  });
}
