import 'dart:async';

import 'package:flutter/services.dart';

class FltWorker {
  static const MethodChannel _channel =
      const MethodChannel('dev.thinkng.flt_worker');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
