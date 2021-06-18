library dynamic_photo_cropper;

export './src/image-cropper.dart';

import 'dart:async';

import 'package:flutter/services.dart';

class DynamicPhotoCropper {
  static const MethodChannel _channel = const MethodChannel('dynamic_photo_cropper');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
