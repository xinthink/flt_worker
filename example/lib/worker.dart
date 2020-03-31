import 'package:flt_worker/flt_worker.dart';
import 'package:flt_worker_example/btc_price_file.dart';

import 'counter_file.dart';

/// Worker callback running in the background isolate.
Future<void> worker(WorkPayload payload) {
  if (payload.id == 'com.example.counter_task' ||
      payload.tags.contains('counter')) {
    return _increaseCounter(payload.input);
  } else if (payload.tags.contains('btc')) {
    return fetchBtcPrice();
  }

  return Future.value();
}

/// The worker increasing the counter.
Future<void> _increaseCounter(Map<String, dynamic> input) =>
  writeCounter((input['counter'] ?? 0) + 1);
