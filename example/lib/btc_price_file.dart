import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

import 'rest.dart';

/// Returns the BTC price file path.
Future<File> btcPriceFile() async {
  final tempPath = (await getTemporaryDirectory()).path;
  final file = File('$tempPath/btc_price.json');
  if (!(await file.exists())) {
    await file.writeAsString('{}', flush: true);
  }
  return file;
}

/// A stream of update events of the data file.
Stream<dynamic> btcPriceStream() => btcPriceFile().asStream()
  .map((file) => file.path)
  .asyncExpand((path) => (Platform.isAndroid
    ? PollingFileWatcher(path) : FileWatcher(path)).events)
  .asyncMap((_) => readBtcPrice());

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
