import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

import 'package:flt_worker/android.dart';

import 'rest.dart';

/// An example for using low level `WorkManager` api on the Android platform,
/// which polls Bitcoin price periodically every 900 seconds.
class WorkManagerBtcPrices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BtcPricesState();
}

class _BtcPricesState extends State<WorkManagerBtcPrices> {
  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    cancelAllWorkByTag('btc');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _startPolling();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitcoin Price'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: _buildDashboard(),
        ),
      ),
    );
  }

  /// Renders the latest Bitcoin price by watching a data file.
  Widget _buildDashboard() => StreamBuilder<double>(
    stream: _priceStream,
    builder: (_, snapshot) => Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '₿1',
            style: TextStyle(
              color: Colors.lime.shade700,
              fontSize: 56,
              height: 1.618,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '\n=\n',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 36,
                  height: null,
                ),
              ),
              TextSpan(
                text: snapshot.hasData ? '\$${snapshot.data}' : '',
                style: const TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              TextSpan(
                text: snapshot.hasData ? '\nUpdated at: ${DateFormat.Hm().format(DateTime.now())}' : '',
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                  height: null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// Enqueues a work request to poll the price.
  void _startPolling() async {
    await initializeWorker(doWork);
    enqueueWorkRequest(const PeriodicWorkRequest(
      repeatInterval: Duration(seconds: 30),
      tags: ['btc'],
      constraints: WorkConstraints(
        networkType: NetworkType.connected,
      ),
    ));
  }

  /// A stream of update events of the data file.
  Stream<double> get _priceStream => _dataFile().asStream()
      .map((file) => file.path)
      .asyncExpand((path) => PollingFileWatcher(path).events)
      .asyncMap((_) => _priceFromFile());

  /// Reads the price from a data file.
  Future<double> _priceFromFile() async {
    try {
      final priceStr = await (await _dataFile()).readAsString();
      return priceStr.isNotEmpty ? double.parse(priceStr) : null;
    } catch (e) {
      debugPrint('read data file failed: $e');
      return null;
    }
  }
}

/// Worker callback running in the background isolate.
Future<void> doWork(WorkPayload payload) => _pollBtcPrice();

/// The worker polling the latest BTC price.
Future<void> _pollBtcPrice() async {
  debugPrint('--- polling BTC price');
  final resp = await getJson('https://api.coinbase.com/v2/prices/spot?currency=USD');
  await (await _dataFile()).writeAsString("${resp['data']['amount']}");
}

/// Returns the BTC price file path.
Future<File> _dataFile() async {
  final tempPath = (await getTemporaryDirectory()).path;
  final file = File('$tempPath/btc_price.json');
  if (!(await file.exists())) {
    await file.writeAsString('{}', flush: true);
  }
  return file;
}
