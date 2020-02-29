#import <Flutter/Flutter.h>

@interface FltWorkerPlugin : NSObject<FlutterPlugin> {
  NSObject<FlutterPluginRegistrar> *_registrar;
  FlutterEngine *_headlessEngine;
  FlutterMethodChannel *_callbackChannel;
}
@end
