import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';
import 'utils.dart';

/// Callback dispatcher, which is the entry of the isolate running background workers.
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  // final channel = MethodChannel('$CHANNEL_NAME');
  // channel.setMethodCallHandler(_executeBackgroundTask);
  apiChannel.setMethodCallHandler(_executeBackgroundTask);
}

/// Run the specified function in the background isoloate.
Future<dynamic> _executeBackgroundTask(MethodCall call) {
  final args = call.arguments;
  WorkerFn callback;
  Map<String, dynamic> payload;

  if (args.isNotEmpty) {
    final handle = CallbackHandle.fromRawHandle(args[0]);
    payload = Map.castFrom(args[1]);
    if (handle != null) {
      callback = PluginUtilities.getCallbackFromHandle(handle);
    }
  }

  if (callback != null) {
    return callback(WorkPayload.fromJson(payload));
  }

  debugPrint('Callback not found for method=${call.method} args=$args');
  return Future.value();
}
