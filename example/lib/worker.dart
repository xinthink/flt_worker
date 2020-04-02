import 'dart:io';

import 'package:flt_worker/flt_worker.dart';
import 'package:flt_worker/ios.dart' show submitTaskRequest, BGAppRefreshTaskRequest;

import 'btc_price_file.dart';
import 'counter_file.dart';

/// Worker callback running in the background isolate.
Future<void> worker(WorkPayload payload) {
  if (payload.tags.contains(kTagCounterWork)) {
    return _increaseCounter(payload.input);
  } else if (payload.tags.contains(kTagBtcPricesWork)) {
    return _fetchBtcPrice();
  } else {
    return Future.value();
  }
}

/// The worker increasing the counter.
Future<void> _increaseCounter(Map<String, dynamic> input) =>
  writeCounter((input['counter'] ?? 0) + 1);

/// Fetches the latest BTC price via CoinBase rest api.
Future<void> _fetchBtcPrice() async {
  try {
    await fetchBtcPrice();
  } finally {
    if (Platform.isIOS) {
      Future.delayed(Duration(milliseconds: 50), () =>
        submitTaskRequest(BGAppRefreshTaskRequest(kTagBtcPricesWork,
          earliestBeginDate: DateTime.now().add(Duration(seconds: 30)),
        )));
    }
  }
}
