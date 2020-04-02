import 'background_tasks.dart';
import '../models.dart';

/// Enqueues a request to work in the background.
Future<bool> enqueueWorkIntent(WorkIntent intent) =>
  submitTaskRequest(_parseWorkIntent(intent));

BGTaskRequest _parseWorkIntent(WorkIntent intent) {
  bool network;
  if (intent.constraints?.networkType != null) {
    network = intent.constraints.networkType != NetworkType.notRequired;
  }

  return BGProcessingTaskRequest(
    intent.id,
    input: intent.input,
    earliestBeginDate: intent.initialDelay != null
      ? DateTime.now().add(intent.initialDelay) : null,
    requiresExternalPower: intent.constraints?.charging,
    requiresNetworkConnectivity: network,
  );
}
