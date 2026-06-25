/// Utility for extracting OTP codes from SMS messages and other text.
abstract final class OtpParser {
  /// Extracts a numeric OTP of [length] digits from [text].
  ///
  /// Handles common SMS formats such as:
  /// - "Your OTP is 123456"
  /// - "123456 is your verification code"
  /// - "Use code: 123456"
  static String? extract(String text, {required int length}) {
    if (text.isEmpty || length <= 0) return null;

    final exactMatch = RegExp(r'\b(\d{' + length.toString() + r'})\b');
    final match = exactMatch.firstMatch(text);
    if (match != null) return match.group(1);

    // Fallback: find any contiguous digit sequence of the required length.
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= length) {
      return digitsOnly.substring(0, length);
    }

    return null;
  }

  /// Returns true if [value] contains only digits and matches [length].
  static bool isValidFormat(String value, {required int length}) {
    return RegExp(r'^\d{' + length.toString() + r'}$').hasMatch(value);
  }
}
