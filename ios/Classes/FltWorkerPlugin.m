#import "FltWorkerPlugin.h"
#import "BGTaskMgrDelegate.h"
#import "BGTaskHandler.h"

@implementation FltWorkerPlugin {
  BGTaskMgrDelegate *_delegate;
//  FlutterEngine *_headlessEngine;
//  FlutterMethodChannel *_callbackChannel;
//  BOOL _isHeadlessEnginRegistered;
//  NSUserDefaults *_userDefaults;
//  NSDictionary *_workers;
}

static FltWorkerPlugin *instance = nil;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  @synchronized (self) {
    if (instance == nil) {
      instance = [[FltWorkerPlugin alloc] initWithRegistrar:registrar];
//      [registrar addApplicationDelegate:instance];
    }
  }
  
  // channel for api calls should be registerd for both instances of engine,
  // so that it's available in the headless isolate
//  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@PLUGIN_PKG
//                                                              binaryMessenger:[registrar messenger]];
//  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (FuncRegisterPlugins) registerPlugins {
  return BGTaskHandler.registerPlugins;
}

+ (void) setRegisterPlugins:(FuncRegisterPlugins)registerPlugins {
  BGTaskHandler.registerPlugins = registerPlugins;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _delegate = [[BGTaskMgrDelegate alloc] initWithRegistrar:registrar];
    [registrar addMethodCallDelegate:self channel:_delegate.methodChannel];
//    _userDefaults = [[NSUserDefaults alloc] init];

    // init a headless engine instance for callback
//    _headlessEngine = [[FlutterEngine alloc] initWithName:@"flt_worker_isolate"
//                                                  project:nil
//                                   allowHeadlessExecution:YES];
//
//    // channel for callbacks
//    FlutterMethodChannel *callbackChannel = [FlutterMethodChannel methodChannelWithName:@PLUGIN_PKG"/callback"
//                                                   binaryMessenger:[_headlessEngine binaryMessenger]];

    // register BGTask identifiers
    [BGTaskMgrDelegate registerBGTaskHandler];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSLog(@"--- handling method call: %@ args=%@", call.method, call.arguments);
  NSString *method = call.method;
  NSArray *args = call.arguments;
  if ([@API_METHOD(initialize) isEqualToString:method]) {
    [_delegate saveHandles:args];
    result(nil);
  } else if ([@API_METHOD(test) isEqualToString:method]) {
//    [BGTaskHandler.instance handleBGTask:nil];
    result(nil);
  } else if (![_delegate handleMethodCall:call result:result]) {
    result(FlutterMethodNotImplemented);
  }
}

@end
