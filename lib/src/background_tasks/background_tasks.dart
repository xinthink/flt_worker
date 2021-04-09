/// The low level api specific for the iOS platform, mapping to the `BackgroundTasks` framework.
library background_tasks;

import 'models.dart';
import '../utils.dart';

export 'models.dart';

/// Schedules a previously registered background task for execution.
Future<bool> submitTaskRequest(BGTaskRequest request)
  => apiChannel.invokeMethod('$METHOD_PREFIX#submitTaskRequest', request.toJson()) as Future<bool>;

/// Cancels a scheduled task request with the [identifier].
Future<void> cancelTaskRequest(String identifier)
  => apiChannel.invokeMethod('$METHOD_PREFIX#cancelTaskRequest', identifier);

/// Cancels all scheduled task requests.
Future<void> cancelAllTaskRequests()
  => apiChannel.invokeMethod('$METHOD_PREFIX#cancelAllTaskRequests');

/// Simulate launch BGTask with the given [identifier], **debugging only**
Future<void> simulateLaunchTask(String identifier)
  => apiChannel.invokeMethod('$METHOD_PREFIX#simulateLaunchTask', identifier);
