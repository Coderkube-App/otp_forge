/// Represents the current state of the OTP verification flow.
enum OtpState {
  /// No input yet, waiting for user action.
  idle,

  /// User is actively entering digits.
  typing,

  /// OTP is being verified against the backend.
  verifying,

  /// OTP verification succeeded.
  success,

  /// OTP verification failed.
  failed,
}
