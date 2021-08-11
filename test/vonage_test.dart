import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonage/vonage.dart';

void main() {
  const MethodChannel channel = MethodChannel('vonage');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await Vonage.platformVersion, '42');
  // });
}
