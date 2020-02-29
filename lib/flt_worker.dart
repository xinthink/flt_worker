import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _PKG_NAME = 'dev.thinkng.flt_worker';
const _METHOD_PREFIX = 'FltWorkerPlugin';

/// Background worker scheduler plugin.
class FltWorker {
  FltWorker._();

  static const _channel = const MethodChannel(_PKG_NAME);

  /// Initialize the worker plugin, which will start a callback ioslate.
  static Future<void> initialize() => _channel.invokeMethod(
    '$_METHOD_PREFIX#initialize',
    [_ensureRawHandle(_callbackDispatcher)]);

  /// Provides a immdiate callback to test the callback isolate.
  static Future<void> test(void Function() callback) =>
    _channel.invokeMethod('$_METHOD_PREFIX#test', [_ensureRawHandle(callback)]);

  static int _ensureRawHandle(void Function() callback) {
    final handle = PluginUtilities.getCallbackHandle(callback)?.toRawHandle();
    if (handle == null) {
      throw Exception('CallbackHandle not found for the specified function. Make sure to use a top level function');
    }
    return handle;
  }
}

/// Callback dispatcher, which is the entry of the isolate running background workers.
void _callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  final channel = MethodChannel('$_PKG_NAME/callback');
  channel.setMethodCallHandler(_executeBackgroundTask);
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
