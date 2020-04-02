/// Background tasks scheduler for Flutter.
library flt_worker;

import 'dart:async';
import 'dart:io';

import 'src/background_tasks/delegate.dart' as bg;
import 'src/callback_dispatcher.dart';
import 'src/models.dart';
import 'src/utils.dart';
import 'src/work_manager/delegate.dart' as wm;

export 'src/models.dart';

/// Initialize the worker plugin, which will start a callback isolate.
///
/// All background work will be dispatched to the [worker] function,
/// which will run in a headless isolate.
///
/// You may assign different tasks to other functions according to the input of each work.
Future<void> initializeWorker(WorkerFn worker) =>
  apiChannel.invokeMethod(
    '$METHOD_PREFIX#initialize',
    [
      ensureRawHandle(callbackDispatcher),
      ensureRawHandle(worker),
    ]);

/// Enqueues a request to work in the background.
final Future<bool> Function(WorkIntent intent) enqueueWorkIntent =
  Platform.isAndroid ? wm.enqueueWorkIntent : bg.enqueueWorkIntent;

/// Cancels all unfinished work with the given [id].
///
/// Note that cancellation is a best-effort policy and work that is already executing may continue to run.
final Future<bool> Function(String id) cancelWork =
  Platform.isAndroid ? wm.cancelWork : bg.cancelWork;

/// Cancels all unfinished work.
///
/// **Use this method with extreme caution!**
/// By invoking it, you will potentially affect other modules or libraries in your codebase.
/// It is strongly recommended that you use one of the other cancellation methods at your disposal.
final Future<bool> Function() cancelAllWork =
  Platform.isAndroid ? wm.wmCancelAllWork : bg.cancelAllWork;

///// Provides a immediate callback to test the callback isolate.
//Future<void> testWorker() =>
//  apiChannel.invokeMethod('$METHOD_PREFIX#test');
