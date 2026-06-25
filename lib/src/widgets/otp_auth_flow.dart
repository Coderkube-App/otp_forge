import 'package:flutter/material.dart';

import '../controller/otp_controller.dart';
import '../models/otp_field_style.dart';
import '../models/otp_state.dart';
import '../models/otp_theme.dart';
import 'otp_input.dart';

/// Callback invoked after successful OTP verification.
typedef OnSuccessCallback = void Function(String otp);

/// Callback invoked when verification or validation fails.
typedef OnErrorCallback = void Function(String message);

/// Production-ready OTP verification widget with SMS autofill, validation,
/// resend timer, and backend integration.
///
/// ```dart
/// OtpAuthFlow(
///   otpLength: 6,
///   autoReadOtp: true,
///   resendDuration: const Duration(seconds: 30),
///   verifyOtp: (otp) async => await authApi.verifyOtp(otp),
///   onSuccess: (otp) => Get.offAll(HomeView()),
///   onError: (message) => Get.snackbar('Error', message),
/// )
/// ```
class OtpAuthFlow extends StatefulWidget {
  const OtpAuthFlow({
    super.key,
    this.controller,
    this.otpLength = 6,
    this.autoReadOtp = false,
    this.autoVerify = true,
    this.resendDuration = const Duration(seconds: 30),
    this.fieldStyle = OtpFieldStyle.box,
    this.theme = const OtpTheme(),
    this.fieldBuilder,
    this.verifyOtp,
    this.onResend,
    this.validator,
    this.onSuccess,
    this.onError,
    this.resendText = 'Resend OTP',
    this.resendCountdownText,
    this.showResend = true,
    this.autofocus = true,
    this.inputBuilder,
  });

  /// Optional external controller for headless or shared-state usage.
  final OtpController? controller;

  /// Number of OTP digits.
  final int otpLength;

  /// Enable Android SMS Retriever API for automatic OTP reading.
  final bool autoReadOtp;

  /// Automatically verify when all digits are entered.
  final bool autoVerify;

  /// Countdown duration before resend becomes available.
  final Duration resendDuration;

  /// Visual style for OTP fields.
  final OtpFieldStyle fieldStyle;

  /// Theme customization for OTP fields.
  final OtpTheme theme;

  /// Custom field builder when [fieldStyle] is [OtpFieldStyle.custom].
  final OtpFieldBuilder? fieldBuilder;

  /// Backend verification. Return `true` on success.
  final VerifyOtpCallback? verifyOtp;

  /// Called when the user taps resend.
  final OnResendCallback? onResend;

  /// Client-side OTP validator.
  final OtpValidator? validator;

  /// Called after successful verification.
  final OnSuccessCallback? onSuccess;

  /// Called on validation or verification failure.
  final OnErrorCallback? onError;

  /// Label for the resend button.
  final String resendText;

  /// Countdown label. Use `{seconds}` as placeholder. Defaults to
  /// `'Resend in {seconds}s'`.
  final String? resendCountdownText;

  /// Whether to show the resend section.
  final bool showResend;

  /// Whether to autofocus the OTP input.
  final bool autofocus;

  /// Optional wrapper to customize layout around the OTP input.
  final Widget Function(BuildContext context, Widget child)? inputBuilder;

  @override
  State<OtpAuthFlow> createState() => _OtpAuthFlowState();
}

class _OtpAuthFlowState extends State<OtpAuthFlow> {
  late OtpController _controller;
  late bool _ownsController;
  OtpState? _lastNotifiedState;

  @override
  void initState() {
    super.initState();
    _initController();
    _controller.addListener(_onStateChanged);
  }

  void _initController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        OtpController(
          otpLength: widget.otpLength,
          autoReadOtp: widget.autoReadOtp,
          autoVerify: widget.autoVerify,
          resendDuration: widget.resendDuration,
          verifyOtp: widget.verifyOtp,
          onResend: widget.onResend,
          validator: widget.validator,
        );
  }

  @override
  void didUpdateWidget(covariant OtpAuthFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onStateChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      _initController();
      _controller.addListener(_onStateChanged);
      _lastNotifiedState = null;
    }
  }

  void _onStateChanged() {
    final current = _controller.state;
    if (current == _lastNotifiedState) return;

    if (current == OtpState.success) {
      widget.onSuccess?.call(_controller.otp);
    } else if (current == OtpState.failed && _controller.errorMessage != null) {
      widget.onError?.call(_controller.errorMessage!);
    }

    _lastNotifiedState = current;
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _countdownLabel(int seconds) {
    final template = widget.resendCountdownText ?? 'Resend in {seconds}s';
    return template.replaceAll('{seconds}', seconds.toString());
  }

  /// Resend is available on the widget or on an external controller.
  bool get _hasResendHandler =>
      widget.onResend != null || _controller.onResend != null;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final input = OtpInput(
          controller: _controller,
          otpLength: widget.otpLength,
          fieldStyle: widget.fieldStyle,
          theme: widget.theme,
          fieldBuilder: widget.fieldBuilder,
          autofocus: widget.autofocus,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.inputBuilder?.call(context, input) ?? input,
            if (widget.showResend && _hasResendHandler) ...[
              const SizedBox(height: 24),
              if (_controller.canResend)
                TextButton(
                  onPressed: _controller.resendOtp,
                  child: Text(widget.resendText),
                )
              else
                Text(
                  _countdownLabel(_controller.remainingSeconds),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
            ],
            if (_controller.state == OtpState.verifying) ...[
              const SizedBox(height: 16),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        );
      },
    );
  }
}
