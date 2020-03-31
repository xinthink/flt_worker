import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';

/// Returns the counter file path.
Future<File> counterFile() async {
  final tempPath = (await getTemporaryDirectory()).path;
  final file = File('$tempPath/counter.txt');
  if (!(await file.exists())) {
    await file.create();
  }
  return file;
}

/// A stream of the updated counter values.
Stream<int> counterStream() => counterFile().asStream()
  .map((file) => file.path)
  .asyncExpand((path) => (Platform.isAndroid
    ? PollingFileWatcher(path) : FileWatcher(path)).events)
  .asyncMap((_) => readCounter());

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
