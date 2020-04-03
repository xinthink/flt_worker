# flt_worker

[![Pub][pub-badge]][pub]
[![Check Status][check-badge]][github-runs]
[![MIT][license-badge]][license]

The `flt_worker` plugin allows you to schedule and execute Dart-written background tasks in a dedicated isolate, by utilizing the [WorkManager] API on Android, and the [BackgroundTasks] API on iOS 13.0+, respectively.

Background processing is suitable for time-consuming tasks like downloading/uploading offline data, fitting a machine learning model, etc. You can use this plugin to schedule work like that. A pre-registed Dart worker will be launched and run in the background whenever the system decides to run the task.

## Integration

Add a dependency to `pubspec.yaml`:
```yaml
dependencies:
  flt_worker: ^0.1.0
```

A worker is running in a separate instance of Flutter engine. Any plugin needed in the worker has to be registered again. In the following example, the `path_provider` plugin is registered for the background isolate.

iOS:
```obj-c
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];

  // set a callback to register all plugins to a headless engine instance
  FltWorkerPlugin.registerPlugins = ^(NSObject<FlutterPluginRegistry> *registry) {
    [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  };
  ...
}
```

Android:
```java
@Override
public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  GeneratedPluginRegistrant.registerWith(flutterEngine);

  // set a callback to register all plugins to a headless engine instance
  FltWorkerPlugin.registerPluginsForWorkers = registry -> {
    io.flutter.plugins.pathprovider.PathProviderPlugin.registerWith(
        registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    return null;
  };
}
```

Fortunately, `flt_worker` itself is always available for the worker, so you don't have to register it again.

One more thing have to be done if you're working on iOS: all task identifiers must be registered before you can subimit any `BGTaskRequest`.

Add lines like this to the `Info.plist` file:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>com.example.counter_task</string>
  <string>dev.example.task2</string>
  ...
</array>
```

## Usage

### Initialization & work dispatcher

Before you can schedule background tasks, a worker callback must be registerted to the plugin:

```dart
import 'package:flt_worker/flt_worker.dart';

void main() {
  runApp(MyApp());
  initializeWorker(worker);
}
```

Please notice that the callback must be a [top-level or static function][CallbackHandle].

The `worker` function acts as a dispatcher of all background tasks, you can call different functions according to the payload of the work, and return a `Future` so that the plugin can notify the system scheduler whenever the work is done.

```dart
Future<void> worker(WorkPayload payload) {
  if (payload.tags.contains('download')) {
    return _fetchData();
  } else if (...) {
    ...
  } else {
    return Future.value();
  }
}

/// Cache data for offline use
Future<void> _fetchData() async {
  // fetch data & update local storage
}
```

### Scheduling work

You can use the `enqueueWorkIntent` function to schedule a background `WorkIntent` like this:

```dart
enqueueWorkIntent(WorkIntent(
  identifier: 'counter',
  initialDelay: Duration(seconds: 59),
  input: <String, dynamic>{
    'counter': counter,
  },
));
```

The name of `WorkIntent` is chosen to avoid conflict with the term `WorkRequest` from the [WorkManager] API for Android.

Please see the documentation and also the example app to find out how to schedule different kinds of background work.

## High-level vs. low-level API

The background processing strategy and API is quite different on the Android and iOS platforms. The `flt_worker` plugin manages to provide a unified yet simplified API for general tasks, as the above example.

However, to leverage the full power of each platform's background processing features, you may consider the low-level platform-specific APIs.

For example, you can schedule a periodic work using the `WorkManager` API on an Android device:

```dart
import 'package:flt_worker/android.dart';

Future<void> _startPolling() async {
  await cancelAllWorkByTag('tag'); // cancel the previous work
  await enqueueWorkRequest(const PeriodicWorkRequest(
    repeatInterval: Duration(hours: 4),
    flexInterval: Duration(minutes: 5),
    tags: ['tag'],
    constraints: WorkConstraints(
      networkType: NetworkType.connected,
      storageNotLow: true,
    ),
    backoffCriteria: BackoffCriteria(
      policy: BackoffPolicy.linear,
      delay: Duration(minutes: 1),
    ),
  ));
}
```

Or to use the `BackgroundTasks` APIs on iOS 13.0+:

```dart
import 'package:flt_worker/ios.dart';

void _increaseCounter(int counter) {
  submitTaskRequest(BGProcessingTaskRequest(
    'com.example.counter_task',
    earliestBeginDate: DateTime.now().add(Duration(seconds: 10)),
    requiresNetworkConnectivity: false,
    requiresExternalPower: true,
    input: <String, dynamic>{
      'counter': counter,
    },
  ));
}
```

## Limitations

It's the very beginning of this library, some limitations you may need to notice are:

- It relies on the `BackgroundTasks` framework, which means it's not working on iOS before `13.0`
- For the Android platform, advanced features of `WorkManager` like [Chaining Work] are not yet supported

[github-runs]: https://github.com/xinthink/flt_worker/actions
[check-badge]: https://github.com/xinthink/flt_worker/workflows/check/badge.svg
[codecov-badge]: https://codecov.io/gh/xinthink/flt_worker/branch/master/graph/badge.svg
[codecov]: https://codecov.io/gh/xinthink/flt_worker
[license-badge]: https://img.shields.io/github/license/xinthink/flt_worker
[license]: https://raw.githubusercontent.com/xinthink/flt_worker/master/LICENSE
[pub]: https://pub.dev/packages/flt_worker
[pub-badge]: https://img.shields.io/pub/v/flt_worker.svg
[WorkManager]: https://developer.android.com/topic/libraries/architecture/workmanager
[BackgroundTasks]: https://developer.apple.com/documentation/backgroundtasks
[CallbackHandle]: https://api.flutter.dev/flutter/dart-ui/PluginUtilities/getCallbackHandle.html
[Chaining Work]: https://developer.android.com/topic/libraries/architecture/workmanager/how-to/chain-work
