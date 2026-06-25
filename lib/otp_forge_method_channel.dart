import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'otp_forge_platform_interface.dart';

/// An implementation of [OtpForgePlatform] that uses method channels.
class MethodChannelOtpForge extends OtpForgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('otp_forge');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
