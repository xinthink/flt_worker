import 'package:flutter/material.dart';

import 'package:flt_worker/flt_worker.dart';

void main() {
  runApp(MyApp());
  FltWorker.initialize();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            child: const Text('Test Callback'),
            onPressed: () {
              FltWorker.test(cb);
            },
          ),
        ),
      ),
    );
}

void cb() {
  debugPrint('--- callback invoked');
  FltWorker.test(cb1); // register another callback inside the background isolate
}

void cb1() {
  debugPrint('--- callback 01 invoked');
}
