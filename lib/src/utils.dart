import 'dart:ui';

import 'package:flutter/services.dart';

const CHANNEL_NAME = 'dev.thinkng.flt_worker';
const METHOD_PREFIX = 'FltWorkerPlugin';

/// The shared method channel for api calls
const apiChannel = const MethodChannel(CHANNEL_NAME);

/// Returns the raw handle of the [callback] function, throws if it doesn't exist.
int ensureRawHandle(void Function() callback) {
  final handle = PluginUtilities.getCallbackHandle(callback)?.toRawHandle();
  if (handle == null) {
    throw Exception('CallbackHandle not found for the specified function. Make sure to use a top level function');
  }
  return handle;
}
