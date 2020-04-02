import 'package:flutter/foundation.dart';

import 'work_manager.dart';
import '../models.dart';

/// Enqueues a request to work in the background.
Future<bool> enqueueWorkIntent(WorkIntent intent) =>
  enqueueWorkRequest(parseWorkIntent(intent));

Future<bool> cancelWork(String id) => cancelAllWorkByTag(id);

Future<bool> wmCancelAllWork() => cancelAllWork();

@visibleForTesting
WorkRequest parseWorkIntent(WorkIntent intent) {
  final tags = [intent.identifier] + (intent.tags ?? []);

  return intent.repeatInterval != null
  ? PeriodicWorkRequest(
    tags: tags,
    input: intent.input,
    initialDelay: intent.initialDelay,
    constraints: intent.constraints,
    repeatInterval: intent.repeatInterval,
    flexInterval: intent.flexInterval,
  )
  : OneTimeWorkRequest(
    tags: tags,
    input: intent.input,
    initialDelay: intent.initialDelay,
    constraints: intent.constraints,
  );
}
