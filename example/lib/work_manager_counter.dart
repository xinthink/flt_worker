import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

import 'package:flt_worker/android.dart';

/// WorkManager api example for the Android platform.
class WorkManagerCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeWorker(doWork);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
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

  /// Renders the latest counter by watching a data file.
  Widget _buildCounter() => StreamBuilder<int>(
    stream: _counterStream,
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

  /// Enqueues a work request to update the counter.
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

  /// A stream of update events of the counter file.
  Stream<int> get _counterStream => _counterFile().asStream()
      .map((file) => file.path)
      .asyncExpand((path) => PollingFileWatcher(path).events)
      .asyncMap((_) => _counterFromFile());

  /// Reads counter from a file.
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

/// Worker callback running in the background isolate.
Future<void> doWork(WorkPayload payload) => _counterWork(payload.input);

/// The worker working on the counter.
Future<void> _counterWork(Map<String, dynamic> input) async {
  debugPrint('--- counting, input=$input');
  final counter = input['counter'] ?? 0;
  await (await _counterFile()).writeAsString('${counter + 1}');
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
