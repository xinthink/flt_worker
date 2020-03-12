import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
  try {
    Function callback;
    if (args.isNotEmpty) {
      final handle = CallbackHandle.fromRawHandle(args[0]);
      if (handle != null) {
        callback = PluginUtilities.getCallbackFromHandle(handle);
      }
    }

    if (callback != null) {
      callback();
    } else {
      debugPrint('Callback not found for method=${call.method} args=$args');
    }
  } catch (e, s) {
    debugPrint('Callback invocation failure: $e, $s');
  }

  return Future.value();
}
