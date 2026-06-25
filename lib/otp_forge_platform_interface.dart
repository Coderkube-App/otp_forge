import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'otp_forge_method_channel.dart';

abstract class OtpForgePlatform extends PlatformInterface {
  /// Constructs a OtpForgePlatform.
  OtpForgePlatform() : super(token: _token);

  static final Object _token = Object();

  static OtpForgePlatform _instance = MethodChannelOtpForge();

  /// The default instance of [OtpForgePlatform] to use.
  ///
  /// Defaults to [MethodChannelOtpForge].
  static OtpForgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OtpForgePlatform] when
  /// they register themselves.
  static set instance(OtpForgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
