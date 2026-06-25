import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform-aware configuration for OTP autofill fields.
abstract final class OtpAutofillConfig {
  /// Autofill hints used across iOS and Android.
  static const List<String> autofillHints = [AutofillHints.oneTimeCode];

  /// Whether the current platform supports iOS-style SMS code autofill.
  static bool get isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether the current platform supports Android SMS Retriever.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Keyboard type tuned per platform for OTP entry.
  static TextInputType get keyboardType {
    if (isIos) {
      // Visible password avoids phone-number suggestions on iOS.
      return TextInputType.visiblePassword;
    }
    return TextInputType.number;
  }

  /// Input formatters for OTP fields.
  static List<TextInputFormatter> formatters(int otpLength) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(otpLength),
      ];

  /// Commits the autofill context after a successful code fill (iOS).
  static void finishAutofillContext() {
    if (isIos) {
      TextInput.finishAutofillContext(shouldSave: false);
    }
  }

  /// Wraps [child] in an [AutofillGroup] when autofill is supported.
  static Widget wrapAutofillGroup({required Widget child}) {
    return AutofillGroup(child: child);
  }
}
