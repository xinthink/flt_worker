import 'dart:ui';

import 'package:flutter/services.dart';

import 'models.dart';

const CHANNEL_NAME = 'dev.thinkng.flt_worker';
const METHOD_PREFIX = 'FltWorkerPlugin';

/// Typedef of a worker function.
typedef WorkerFn = Future<void> Function(WorkPayload payload);

/// The shared method channel for api calls
const apiChannel = const MethodChannel(CHANNEL_NAME);

/// Returns the raw handle of the [callback] function, throws if it doesn't exist.
int ensureRawHandle(Function callback) {
  final handle = PluginUtilities.getCallbackHandle(callback)?.toRawHandle();
  if (handle == null) {
    throw Exception('CallbackHandle not found for the specified function. Make sure to use a top level function');
  }
  return handle;
}
