/// A unified and simplified API for scheduling general background tasks.
///
/// The background tasks scheduler is based on
/// the [BackgroundTasks](https://developer.apple.com/documentation/backgroundtasks) framework on iOS 13+,
/// and the [WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager) APIs
/// on Android.
///
/// For more complex tasks, you may want to use the flatform-specific low-level
/// [work_manager] and [background_tasks] APIs for Android and iOS devices respectively.
library flt_worker;

import 'dart:async';

import 'src/callback_dispatcher.dart';
import 'src/functions.dart' as impl;
import 'src/models.dart';
import 'src/utils.dart';

export 'src/models.dart';

/// Initializes the plugin by registering a [worker] callback.
///
/// All background work will be dispatched to the [worker] function,
/// which will run in a headless isolate.
///
/// You may assign different tasks to other functions according to the [input][WorkPayload] of each work.
/// For example:
/// ```
/// Future<void> worker(WorkPayload payload) {
///   final id = payload.tags.first;
///   switch (id) {
///     case 'task1':
///       return onTask1();
///     default:
///       return Future.value();
///   }
/// }
///
/// ...
/// initializeWorker(worker);
/// ```
Future<void> initializeWorker(WorkerFn worker) =>
  apiChannel.invokeMethod(
    '$METHOD_PREFIX#initialize',
    [
      ensureRawHandle(callbackDispatcher),
      ensureRawHandle(worker),
    ]);

/// Enqueues a [intent] to work in the background.
///
/// You can specify input data and constraints like network or battery status
/// to the background work via the [WorkIntent].
///
/// Example:
/// ```
/// enqueueWorkIntent(WorkIntent(
///   identifier: 'task1',
///   initialDelay: Duration(seconds: 59),
///   constraints: WorkConstraints(
///     networkType: NetworkType.connected,
///     batteryNotLow: true,
///   ),
///   input: <String, dynamic>{
///     'counter': counter,
///   },
/// ));
/// ```
///
/// For the iOS platform, all `identifier`s must be registered in the `Info.plist` file,
/// please see the [integration guide](https://github.com/xinthink/flt_worker#integration) for more details.
///
/// The `identifier` will always be prepended to the `tags` properties,
/// which you can retrieve from the `WorkPayload` when handling the work later.
Future<bool> enqueueWorkIntent(WorkIntent intent) => impl.enqueueWorkIntent(intent);

/// Cancels all unfinished work with the given [identifier].
///
/// Note that cancellation is a best-effort policy and work that is already executing may continue to run.
Future<bool> cancelWork(String identifier) => impl.cancelWork(identifier);

/// Cancels all unfinished work.
///
/// **Use this method with extreme caution!**
/// By invoking it, you will potentially affect other modules or libraries in your codebase.
/// It is strongly recommended that you use one of the other cancellation methods at your disposal.
Future<bool> cancelAllWork() => impl.cancelAllWork();
