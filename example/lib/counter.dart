import 'package:flt_worker/flt_worker.dart';
import 'package:flutter/material.dart';

import 'counter_file.dart';

/// WorkManager api example for the Android platform.
class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
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

  /// Renders the latest counter by watching a data file.
  Widget _buildCounter() => StreamBuilder<int>(
    stream: counterStream(),
    builder: (_, snapshot) => Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Increases the counter via an unified API on both platforms.\n',
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
        TextButton(
          child: const Text('Count'),
          onPressed: () => _increaseCounter(snapshot.data),
        ),
      ],
    )
  );

  /// Enqueues a work request to update the counter.
  void _increaseCounter(int counter) {
    enqueueWorkIntent(WorkIntent(
      identifier: kTagCounterWork,
      input: <String, dynamic>{
        'counter': counter,
      },
      isProcessingTask: true,
    ));
  }
}
