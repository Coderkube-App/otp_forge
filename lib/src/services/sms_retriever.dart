import 'dart:async';

import 'package:flutter/services.dart';

import '../utils/otp_parser.dart';

/// Listens for incoming SMS messages via the Android SMS Retriever API.
///
/// On iOS and other platforms this is a no-op; autofill is handled by
/// [AutofillHints.oneTimeCode] on the hidden input field.
class SmsRetrieverService {
  SmsRetrieverService._();

  static const MethodChannel _channel = MethodChannel(
    'otp_forge/sms_retriever',
  );

  static StreamSubscription<String>? _subscription;
  static StreamController<String>? _controller;

  /// Stream of raw SMS message bodies received via SMS Retriever.
  static Stream<String> get smsStream {
    _controller ??= StreamController<String>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  /// Starts the Android SMS Retriever API. Returns the app hash if available.
  static Future<String?> start() async {
    try {
      return await _channel.invokeMethod<String>('startRetriever');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Stops the SMS Retriever listener.
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopRetriever');
    } on MissingPluginException {
      // Not on Android — ignore.
    } on PlatformException {
      // Ignore platform errors during cleanup.
    }
    await _stopListening();
  }

  static Future<void> _startListening() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await start();
  }

  static Future<void> _stopListening() async {
    _channel.setMethodCallHandler(null);
    await stop();
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onSmsReceived') {
      final message = call.arguments as String?;
      if (message != null && message.isNotEmpty) {
        _controller?.add(message);
      }
    }
  }

  /// Parses an OTP of [length] from a received SMS [message].
  static String? parseOtp(String message, {required int length}) {
    return OtpParser.extract(message, length: length);
  }

  /// Disposes internal resources. Call when no longer needed.
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _controller?.close();
    _controller = null;
  }
}

/// Convenience wrapper that emits parsed OTP codes from [SmsRetrieverService].
class OtpAutoFillService {
  OtpAutoFillService({required this.otpLength});

  final int otpLength;
  StreamSubscription<String>? _smsSubscription;
  final StreamController<String> _otpController =
      StreamController<String>.broadcast();

  /// Stream of parsed OTP codes ready to fill into the input.
  Stream<String> get otpStream => _otpController.stream;

  /// Starts listening for SMS and emits parsed OTP codes.
  Future<void> start() async {
    await SmsRetrieverService.start();
    _smsSubscription ??= SmsRetrieverService.smsStream.listen((message) {
      final otp = SmsRetrieverService.parseOtp(message, length: otpLength);
      if (otp != null) {
        _otpController.add(otp);
      }
    });
  }

  /// Stops listening and releases resources.
  Future<void> dispose() async {
    await _smsSubscription?.cancel();
    _smsSubscription = null;
    await _otpController.close();
    await SmsRetrieverService.dispose();
  }
}
