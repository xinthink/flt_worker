/// Background tasks scheduler for Flutter.
library flt_worker;

import 'dart:async';
import 'dart:ui';

import 'src/callback_dispatcher.dart';
import 'src/constants.dart';

/// Initialize the worker plugin, which will start a callback ioslate.
Future<void> initialize() => apiChannel.invokeMethod(
  '$METHOD_PREFIX#initialize',
  [_ensureRawHandle(callbackDispatcher)]);

/// Provides a immdiate callback to test the callback isolate.
Future<void> test(void Function() callback) =>
  apiChannel.invokeMethod('$METHOD_PREFIX#test', [_ensureRawHandle(callback)]);

/// Returns the raw handle of the [callback] function, throws if it doesn't exist.
int _ensureRawHandle(void Function() callback) {
  final handle = PluginUtilities.getCallbackHandle(callback)?.toRawHandle();
  if (handle == null) {
    throw Exception('CallbackHandle not found for the specified function. Make sure to use a top level function');
  }
  return handle;
}
