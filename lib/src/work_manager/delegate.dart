import 'work_manager.dart';
import '../models.dart';

/// Enqueues a request to work in the background.
Future<bool> enqueueWorkIntent(WorkIntent intent) =>
  enqueueWorkRequest(_parseWorkIntent(intent));

WorkRequest _parseWorkIntent(WorkIntent intent) => OneTimeWorkRequest(
  tags: [intent.id] + (intent.tags ?? []),
  input: intent.input,
  initialDelay: intent.initialDelay,
  constraints: intent.constraints,
);
