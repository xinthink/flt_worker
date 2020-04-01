import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

import 'rest.dart';

const kTagBtcPricesWork = 'com.example.btc_prices_task';

/// Returns the BTC price file path.
Future<File> btcPriceFile() async {
  final dir = (await getTemporaryDirectory()).path;
  final file = File('$dir/btc_price.json');
  if (!(await file.exists())) {
    await file.writeAsString('{}', flush: true);
  }
  return file;
}

/// A stream of updated BTC prices.
Stream<dynamic> btcPriceStream() async* {
  // yield the initial value
  yield await readBtcPrice();

  // yield a value whenever the file is modified
  final path = (await btcPriceFile()).path;
  final updates = (Platform.isAndroid
      ? PollingFileWatcher(path) : FileWatcher(path)).events;
  await for (final _ in updates) {
    yield await readBtcPrice();
  }
}

/// Reads the price from a data file.
Future<dynamic> readBtcPrice() async {
  try {
    final json = jsonDecode(await (await btcPriceFile()).readAsString());
    return json['amount'] != null ? json : null;
  } catch (e) {
    debugPrint('read data file failed: $e');
    return null;
  }
}

/// Fetches the latest BTC price via CoinBase rest api.
Future<void> fetchBtcPrice() async {
  debugPrint('--- fetching BTC price');
  final resp = await getJson('https://api.coinbase.com/v2/prices/spot?currency=USD');
  await (await btcPriceFile()).writeAsString('''{
  "amount": ${resp['data']['amount']},
  "time": ${DateTime.now().millisecondsSinceEpoch}
}''');
}
