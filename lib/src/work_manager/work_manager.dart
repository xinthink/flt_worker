/// The low level api specific for the Android platform, mapping to the `WorkManager` library.
library work_manager;

import 'models.dart';
import '../utils.dart';

export 'models.dart';

/// Enqueues one item for background processing.
Future<bool> enqueueWorkRequest(WorkRequest request)
  => enqueueWorkRequests([request]);

/// Enqueues one or more items for background processing.
Future<bool> enqueueWorkRequests(Iterable<WorkRequest> requests) async {
  return await apiChannel.invokeMethod('$METHOD_PREFIX#enqueue',
    requests.map((r) => r.toJson()).toList(growable: false)
  );
}

/// Cancels all unfinished work with the given [tag].
///
/// Note that cancellation is a best-effort policy and work that is already executing may continue to run.
Future<bool> cancelAllWorkByTag(String tag) async
  => await apiChannel.invokeMethod('$METHOD_PREFIX#cancelAllWorkByTag', tag);

/// Cancels all unfinished work in the work chain with the given [name].
///
/// Note that cancellation is a best-effort policy and work that is already executing may continue to run.
Future<bool> cancelUniqueWork(String name) async
  => await apiChannel.invokeMethod('$METHOD_PREFIX#cancelUniqueWork', name);

/// Cancels work with the given [uuid] if it isn't finished.
///
/// Note that cancellation is a best-effort policy and work that is already executing may continue to run.
Future<bool> cancelWorkById(String uuid) async
  => await apiChannel.invokeMethod('$METHOD_PREFIX#cancelWorkById', uuid);

/// Cancels all unfinished work.
///
/// **Use this method with extreme caution!**
/// By invoking it, you will potentially affect other modules or libraries in your codebase.
/// It is strongly recommended that you use one of the other cancellation methods at your disposal.
Future<bool> cancelAllWork() async
  => await apiChannel.invokeMethod('$METHOD_PREFIX#cancelAllWork');
