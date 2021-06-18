import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_photo_cropper/dynamic_photo_cropper.dart';

void main() {
  const MethodChannel channel = MethodChannel('dynamic_photo_cropper');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DynamicPhotoCropper.platformVersion, '42');
  });
}
