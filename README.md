# flt_worker

[![Pub][pub-badge]][pub]
[![Check Status][check-badge]][github-runs]
[![MIT][license-badge]][license]

The flt_worker plugin allows you to schedule and execute Dart-written background tasks in a dedicated isolate, by utilizing the [WorkManager] API on Android, and the [BackgroundTasks] API on iOS 13, respectively.

## Integration

`pubspec.yaml`

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
