/// Visual style for individual OTP input fields.
enum OtpFieldStyle {
  /// Rounded rectangle boxes (default).
  box,

  /// Underline-only fields.
  underline,

  /// Fully custom field rendering via [OtpAuthFlow.fieldBuilder].
  custom,
}
