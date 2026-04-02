import 'package:flutter/foundation.dart';

class BackendConfig {
  static const String _physicalDeviceUrl =
      String.fromEnvironment(
        'CONTRACT_GUARDIAN_API_URL',
        defaultValue: 'http://192.168.29.52:8000',
      );

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _physicalDeviceUrl;
      case TargetPlatform.iOS:
        return _physicalDeviceUrl;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8000';
      case TargetPlatform.fuchsia:
        return _physicalDeviceUrl;
    }
  }
}
