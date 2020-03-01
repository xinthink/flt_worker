/// Background tasks scheduler for Flutter.
library flt_worker;

import 'dart:async';

import 'src/callback_dispatcher.dart';
import 'src/utils.dart';

/// Initialize the worker plugin, which will start a callback ioslate.
Future<void> initialize() => apiChannel.invokeMethod(
  '$METHOD_PREFIX#initialize',
  [ensureRawHandle(callbackDispatcher)]);

/// Provides a immdiate callback to test the callback isolate.
Future<void> test(void Function() callback) =>
  apiChannel.invokeMethod('$METHOD_PREFIX#test', [ensureRawHandle(callback)]);
