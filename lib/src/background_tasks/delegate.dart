import 'package:flutter/foundation.dart';

import 'background_tasks.dart';
import '../models.dart';

/// Enqueues a request to work in the background.
Future<bool> enqueueWorkIntent(WorkIntent intent) =>
  submitTaskRequest(parseWorkIntent(intent));

Future<bool> cancelWork(String id) => cancelTaskRequest(id).then((_) => true);

Future<bool> cancelAllWork() => cancelAllTaskRequests().then((_) => true);

@visibleForTesting
BGTaskRequest parseWorkIntent(WorkIntent intent) {
  bool network;
  if (intent.constraints?.networkType != null) {
    network = intent.constraints.networkType != NetworkType.notRequired;
  }

  DateTime earliestBeginDate = intent.initialDelay != null
    ? DateTime.now().add(intent.initialDelay) : null;

  return intent.isProcessingTask == true
    ? BGProcessingTaskRequest(
      intent.identifier,
      input: intent.input,
      earliestBeginDate: earliestBeginDate,
      requiresExternalPower: intent.constraints?.charging,
      requiresNetworkConnectivity: network,
    )
    : BGAppRefreshTaskRequest(
      intent.identifier,
      input: intent.input,
      earliestBeginDate: earliestBeginDate,
    );
}
