import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

import 'package:flt_worker/android.dart';

/// WorkManager api example for the Android platform.
class WorkManagerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeWorker(doWork);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkManager Example'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: _buildCounter(),
        ),
      ),
    );
  }

  Widget _buildCounter() => FutureBuilder<String>(
    future: _counterFile().then((f) => f.path),
    builder: (_, snapshot) => snapshot.hasData
      ? StreamBuilder(
        stream: _counterStream(snapshot.data),
        builder: (_, __) => _buildCounterStatus(),
      )
      : Container(),
  );

  Widget _buildCounterStatus() => FutureBuilder<int>(
    future: _counterFromFile(),
    builder: (_, snapshot) => Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Increases the counter via an one-off work\n',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            children: <TextSpan>[
              TextSpan(
                text: snapshot.hasData ? '${snapshot.data}' : '',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 48,
                  height: 1.618,
                ),
              ),
            ],
          ),
        ),
        RaisedButton(
          child: const Text('Count'),
          onPressed: () => _increaseCounter(snapshot.data),
        ),
      ],
    )
  );

  void _increaseCounter(int counter) {
    enqueueWorkRequest(OneTimeWorkRequest(
      tags: ['counter'],
      constraints: WorkConstraints(
        networkType: NetworkType.notRequired,
      ),
      input: <String, dynamic>{
        'counter': counter,
      },
    ));
  }

  Stream<void> _counterStream(String path) =>
    (Platform.isAndroid ? PollingFileWatcher(path) : FileWatcher(path)).events;

  Future<int> _counterFromFile() async {
    try {
      final counterStr = await (await _counterFile()).readAsString();
      return counterStr.isNotEmpty ? int.parse(counterStr) : 0;
    } catch (e) {
      debugPrint('read counter file failed: $e');
      return 0;
    }
  }
}

/// Callback for the worker running in the background isolate.
Future<void> doWork(Map<String, dynamic> payload) => _counterWork(payload['input']);

/// The worker working on the counter.
Future<void> _counterWork(Map<String, dynamic> input) async {
  final counter = 1 + (input['counter'] ?? 0);
  await (await _counterFile()).writeAsString('$counter');
}

/// Returns the counter file path.
Future<File> _counterFile() async {
  final tempPath = (await getTemporaryDirectory()).path;
  final file = File('$tempPath/counter.txt');
  if (!(await file.exists())) {
    await file.create();
  }
  return file;
}
