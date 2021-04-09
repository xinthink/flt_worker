import 'dart:io';

import 'package:flt_worker/flt_worker.dart';
import 'package:flutter/material.dart';

import 'background_tasks_btc_prices.dart';
import 'background_tasks_counter.dart';
import 'btc_prices.dart';
import 'counter.dart';
import 'work_manager_btc_prices.dart';
import 'work_manager_counter.dart';
import 'worker.dart';

/// Background processing examples.
///
/// Force start iOS background tasks:
/// ```
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.btc_prices_task"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.counter_task"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.task1"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"dev.example.task2"]
/// ```
///
/// > See [iOS documentations](https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development)
void main() {
  runApp(MyApp());
  initializeWorker(worker);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Worker Examples'),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: const TextStyle(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text('High level API examples',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    child: const Text('Counter'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => Counter(),
                    )),
                  ),
                  TextButton(
                    child: const Text('Bitcoin price polling'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BtcPrices(),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 16),
                    child: const Text('Low level platform-specific API examples',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  ...(Platform.isAndroid ? _workManagerExamples(context) : _bgTasksExamples(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

List<Widget> _workManagerExamples(BuildContext context) => [
  TextButton(
    child: const Text('Counter\n(OneTimeWorkRequest)'),
    onPressed: () => Navigator.push(context, MaterialPageRoute(
      builder: (_) => WorkManagerCounter(),
    )),
  ),
  TextButton(
    child: const Text('Bitcoin price polling\n(PeriodicWorkRequest)'),
    onPressed: () => Navigator.push(context, MaterialPageRoute(
      builder: (_) => WorkManagerBtcPrices(),
    )),
  ),
];

List<Widget> _bgTasksExamples(BuildContext context) => [
  TextButton(
    child: const Text('Counter\n(BGProcessingTaskRequest)'),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => BackgroundTasksCounter(),
      ));
    },
  ),
  TextButton(
    child: const Text('Bitcoin price polling\n(BGAppRefreshTaskRequest)'),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => BackgroundTasksBtcPrices(),
      ));
    },
  ),
];
