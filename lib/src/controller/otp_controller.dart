import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/otp_state.dart';
import '../services/sms_retriever.dart';
import '../utils/otp_parser.dart';

/// Callback that verifies an OTP against a backend. Return `true` on success.
typedef VerifyOtpCallback = Future<bool> Function(String otp);

/// Callback invoked when the user requests a resend.
typedef OnResendCallback = Future<void> Function();

/// Validates an OTP string. Return an error message or `null` if valid.
typedef OtpValidator = String? Function(String otp);

/// Headless controller for OTP verification logic without UI.
///
/// ```dart
/// final controller = OtpController(
///   otpLength: 6,
///   verifyOtp: (otp) => api.verifyOtp(otp),
/// );
/// controller.verifyOtp();
/// controller.resendOtp();
/// ```
class OtpController extends ChangeNotifier {
  OtpController({
    this.otpLength = 6,
    this.resendDuration = const Duration(seconds: 30),
    VerifyOtpCallback? verifyOtp,
    this.onResend,
    this.validator,
    this.autoReadOtp = false,
    this.autoVerify = true,
  }) : _verifyOtp = verifyOtp {
    _startResendTimer();
    if (autoReadOtp) {
      _initAutoFill();
    }
  }

  /// Number of OTP digits expected.
  final int otpLength;

  /// Duration before the resend action becomes available.
  final Duration resendDuration;

  /// Backend verification callback. Return `true` on success.
  final VerifyOtpCallback? _verifyOtp;

  /// Called when the user triggers a resend.
  final OnResendCallback? onResend;

  /// Optional client-side validator run before [verifyOtp].
  final OtpValidator? validator;

  /// Whether to listen for incoming SMS via SMS Retriever (Android).
  final bool autoReadOtp;

  /// Automatically call [verifyOtp] when all digits are entered.
  final bool autoVerify;

  String _otp = '';
  OtpState _state = OtpState.idle;
  String? _errorMessage;
  int _remainingSeconds = 0;
  bool _canResend = false;
  Timer? _resendTimer;
  OtpAutoFillService? _autoFillService;
  StreamSubscription<String>? _autoFillSubscription;
  bool _disposed = false;

  /// Current OTP value.
  String get otp => _otp;

  /// Current verification state.
  OtpState get state => _state;

  /// Error message from validation or verification failure.
  String? get errorMessage => _errorMessage;

  /// Seconds remaining before resend is available.
  int get remainingSeconds => _remainingSeconds;

  /// Whether the resend action is currently enabled.
  bool get canResend => _canResend;

  /// Whether input and actions are locked (during verification).
  bool get isLocked =>
      _state == OtpState.verifying || _state == OtpState.success;

  /// Updates the OTP value. Called by the input widget or auto-fill.
  void updateOtp(String value) {
    if (isLocked) return;

    final sanitized = value.replaceAll(RegExp(r'\D'), '');
    final trimmed = sanitized.length > otpLength
        ? sanitized.substring(0, otpLength)
        : sanitized;

    if (trimmed == _otp) return;

    _otp = trimmed;
    _errorMessage = null;

    if (_otp.isEmpty) {
      _setState(OtpState.idle);
    } else if (_otp.length < otpLength) {
      _setState(OtpState.typing);
    } else {
      _setState(OtpState.typing);
      if (autoVerify) {
        unawaited(verifyOtp());
      }
    }

    notifyListeners();
  }

  /// Clears the current OTP and resets to idle.
  void clear() {
    _otp = '';
    _errorMessage = null;
    _setState(OtpState.idle);
    notifyListeners();
  }

  /// Verifies the current OTP against the backend callback.
  Future<bool> verifyOtp() async {
    if (isLocked) return false;

    final validationError = validator?.call(_otp);
    if (validationError != null) {
      _errorMessage = validationError;
      _setState(OtpState.failed);
      notifyListeners();
      return false;
    }

    if (!OtpParser.isValidFormat(_otp, length: otpLength)) {
      _errorMessage = 'Invalid OTP';
      _setState(OtpState.failed);
      notifyListeners();
      return false;
    }

    if (_verifyOtp == null) return true;

    _setState(OtpState.verifying);
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _verifyOtp(_otp);
      if (_disposed) return false;

      if (success) {
        _setState(OtpState.success);
      } else {
        _errorMessage = 'Verification failed';
        _setState(OtpState.failed);
      }
      notifyListeners();
      return success;
    } catch (e) {
      if (_disposed) return false;
      _errorMessage = e.toString();
      _setState(OtpState.failed);
      notifyListeners();
      return false;
    }
  }

  /// Triggers a resend and restarts the countdown timer.
  Future<void> resendOtp() async {
    if (!_canResend || onResend == null) return;

    _canResend = false;
    clear();
    notifyListeners();

    try {
      await onResend!();
    } catch (e) {
      if (!_disposed) {
        _errorMessage = e.toString();
        _setState(OtpState.failed);
        _canResend = true;
        notifyListeners();
      }
      return;
    }

    if (_disposed) return;

    _startResendTimer();
    if (autoReadOtp) {
      await SmsRetrieverService.start();
    }
    notifyListeners();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _remainingSeconds = resendDuration.inSeconds;
    _canResend = resendDuration.inSeconds <= 0;

    if (_canResend) {
      notifyListeners();
      return;
    }

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        _canResend = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> _initAutoFill() async {
    _autoFillService = OtpAutoFillService(otpLength: otpLength);
    await _autoFillService!.start();
    _autoFillSubscription = _autoFillService!.otpStream.listen((code) {
      updateOtp(code);
    });
  }

  void _setState(OtpState newState) {
    _state = newState;
  }

  @override
  void dispose() {
    _disposed = true;
    _resendTimer?.cancel();
    _autoFillSubscription?.cancel();
    _autoFillService?.dispose();
    super.dispose();
  }
}
