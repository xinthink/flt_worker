import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flt_worker/flt_worker.dart';

void main() {
  const MethodChannel channel = MethodChannel('flt_worker');

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
    expect(await FltWorker.platformVersion, '42');
  });
}
