import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_forge/otp_forge.dart';

void main() {
  group('OtpParser', () {
    test('extracts OTP from common SMS formats', () {
      expect(
        OtpParser.extract('Your OTP is 123456', length: 6),
        '123456',
      );
      expect(
        OtpParser.extract('123456 is your verification code', length: 6),
        '123456',
      );
      expect(
        OtpParser.extract('Use code: 654321 to verify', length: 6),
        '654321',
      );
    });

    test('returns null when OTP length does not match', () {
      expect(
        OtpParser.extract('Your OTP is 1234', length: 6),
        isNull,
      );
    });

    test('validates digit format', () {
      expect(OtpParser.isValidFormat('123456', length: 6), isTrue);
      expect(OtpParser.isValidFormat('12345', length: 6), isFalse);
      expect(OtpParser.isValidFormat('abcdef', length: 6), isFalse);
    });
  });

  group('OtpController', () {
    late OtpController controller;

    tearDown(() {
      controller.dispose();
    });

    test('starts in idle state', () {
      controller = OtpController(otpLength: 6);
      expect(controller.state, OtpState.idle);
      expect(controller.otp, isEmpty);
    });

    test('transitions to typing when digits are entered', () {
      controller = OtpController(otpLength: 6, autoVerify: false);
      controller.updateOtp('123');
      expect(controller.state, OtpState.typing);
      expect(controller.otp, '123');
    });

    test('validates OTP before verification', () async {
      controller = OtpController(
        otpLength: 6,
        autoVerify: false,
        validator: (otp) =>
            otp.length != 6 ? 'Invalid OTP' : null,
      );
      controller.updateOtp('123');
      final result = await controller.verifyOtp();
      expect(result, isFalse);
      expect(controller.state, OtpState.failed);
      expect(controller.errorMessage, 'Invalid OTP');
    });

    test('verifies OTP via callback', () async {
      controller = OtpController(
        otpLength: 6,
        autoVerify: false,
        verifyOtp: (otp) async => otp == '123456',
      );
      controller.updateOtp('123456');
      final result = await controller.verifyOtp();
      expect(result, isTrue);
      expect(controller.state, OtpState.success);
    });

    test('handles verification failure', () async {
      controller = OtpController(
        otpLength: 6,
        autoVerify: false,
        verifyOtp: (_) async => false,
      );
      controller.updateOtp('123456');
      final result = await controller.verifyOtp();
      expect(result, isFalse);
      expect(controller.state, OtpState.failed);
    });

    test('auto-verifies when all digits entered', () async {
      var verified = false;
      controller = OtpController(
        otpLength: 4,
        verifyOtp: (otp) async {
          verified = true;
          return true;
        },
      );
      controller.updateOtp('1234');
      await Future<void>.delayed(Duration.zero);
      expect(verified, isTrue);
      expect(controller.state, OtpState.success);
    });

    test('resend restarts countdown timer', () async {
      controller = OtpController(
        otpLength: 6,
        resendDuration: Duration.zero,
        onResend: () async {},
      );
      expect(controller.canResend, isTrue);
      await controller.resendOtp();
      expect(controller.state, OtpState.idle);
      expect(controller.otp, isEmpty);
    });

    test('resend re-enables button when API fails', () async {
      controller = OtpController(
        otpLength: 6,
        resendDuration: Duration.zero,
        onResend: () async => throw Exception('Network error'),
      );
      controller.updateOtp('123456');
      expect(controller.canResend, isTrue);

      await controller.resendOtp();

      expect(controller.canResend, isTrue);
      expect(controller.state, OtpState.failed);
      expect(controller.errorMessage, contains('Network error'));
    });

    test('clear resets state', () {
      controller = OtpController(otpLength: 6, autoVerify: false);
      controller.updateOtp('123');
      controller.clear();
      expect(controller.otp, isEmpty);
      expect(controller.state, OtpState.idle);
    });
  });

  group('OtpAutofillConfig', () {
    test('provides oneTimeCode autofill hint', () {
      expect(
        OtpAutofillConfig.autofillHints,
        contains(AutofillHints.oneTimeCode),
      );
    });

    test('formatters limit input to otp length', () {
      final formatters = OtpAutofillConfig.formatters(4);
      expect(formatters.length, 2);
    });
  });

  group('OtpTheme', () {
    test('copyWith preserves unset values', () {
      const theme = OtpTheme(borderRadius: 12, fieldWidth: 50);
      final copy = theme.copyWith(spacing: 16);
      expect(copy.borderRadius, 12);
      expect(copy.fieldWidth, 50);
      expect(copy.spacing, 16);
    });
  });
}
