/// Background tasks scheduler for Flutter.
library flt_worker;

import 'dart:async';

import 'src/callback_dispatcher.dart';
import 'src/utils.dart';

/// Initialize the worker plugin, which will start a callback ioslate.
///
/// All background work will be dispatched to the [worker] function,
/// which will run in a headless ioslate.
///
/// You may assign different tasks to other functions according to the input of each work.
Future<void> initializeWorker(WorkerFn worker) =>
  apiChannel.invokeMethod(
    '$METHOD_PREFIX#initialize',
    [
      ensureRawHandle(callbackDispatcher),
      ensureRawHandle(worker),
    ]);

/// Provides a immdiate callback to test the callback isolate.
Future<void> testWorker() =>
  apiChannel.invokeMethod('$METHOD_PREFIX#test');
