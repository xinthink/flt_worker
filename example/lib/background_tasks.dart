import 'dart:async';
import 'dart:io';

import 'package:flt_worker/ios.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

/// BackgroundTasks api example for the iOS platform.
class BackgroundTasksExample extends StatelessWidget {
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

  /// Renders the latest counter by watching a data file.
  Widget _buildCounter() => FutureBuilder<String>(
    future: _counterFile().then((f) => f.path),
    builder: (_, snapshot) => snapshot.hasData
      ? StreamBuilder(
        stream: _counterStream(snapshot.data),
        builder: (_, __) => _buildCounterStatus(),
      )
      : Container(),
  );

  /// Renders the counter & a button to increase its value.
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

  /// Submit a background task to update the counter.
  void _increaseCounter(int counter) {
    submitTaskRequest(BGProcessingTaskRequest("com.example.task1",
      input: <String, dynamic>{
        'counter': counter,
      },
    ));
  }

  /// A stream of update events of the counter file.
  Stream<dynamic> _counterStream(String path) => FileWatcher(path).events;

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

/// A worker callback running in the background isolate.
Future<void> doWork(Map<String, dynamic> payload) => _counterWork(payload['input']);

/// The worker working on the counter.
Future<void> _counterWork(Map<String, dynamic> input) async {
  debugPrint('--- counting, input=$input');
  final counter = input['counter'] ?? 0;
  await (await _counterFile()).writeAsString('${counter + 1}');
//  int counter = 0;
//  final file = await _counterFile();
//  try {
//    final counterStr = await file.readAsString();
//    counter = counterStr.isNotEmpty ? int.parse(counterStr) : 0;
//  } catch (e) {
//    debugPrint('read counter file failed: $e');
//  }
//
//  await file.writeAsString('${counter + 1}');
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
