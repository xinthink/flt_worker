package dev.thinkng.flt_worker_example;

import androidx.annotation.NonNull;

import dev.thinkng.flt_worker.FltWorkerPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    FltWorkerPlugin.registerPluginsForWorkers = registry -> null;
  }
}
