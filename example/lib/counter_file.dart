import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

const kTagCounterWork = 'com.example.counter_task';

/// Returns the counter file path.
Future<File> counterFile() async {
  final dir = (await getTemporaryDirectory()).path;
  final file = File('$dir/counter.txt');
  if (!(await file.exists())) {
    await file.writeAsString('0');
  }
  return file;
}

/// A stream of the updated counter values.
Stream<int> counterStream() async* {
  // yield the initial value
  yield await readCounter();

  // yield a value whenever the file is modified
  final path = (await counterFile()).path;
  final updates = (Platform.isAndroid
    ? PollingFileWatcher(path) : FileWatcher(path)).events;
  await for (final _ in updates) {
    yield await readCounter();
  }
}

/// Reads counter from a file.
Future<int> readCounter() async {
  try {
    final counterStr = await (await counterFile()).readAsString();
    return counterStr.isNotEmpty ? int.parse(counterStr) : 0;
  } catch (e) {
    debugPrint('read counter file failed: $e');
    return 0;
  }
}

/// The worker working on the counter.
Future<void> writeCounter(int count) async {
  debugPrint('--- updating counter file => $count');
  await (await counterFile()).writeAsString('$count');
}
