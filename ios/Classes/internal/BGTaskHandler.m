//
//  BGTaskHandler.m
//  flt_worker
//
//  Created by Yingxin Wu on 2020/3/13.
//

#import "BGTaskHandler.h"
#import "BGTaskMgrDelegate.h"

static BGTaskHandler *_instance = nil;
static FuncRegisterPlugins _registerPlugins = nil;

@implementation BGTaskHandler {
  BGTaskMgrDelegate *_delegate;
  FlutterEngine *_headlessEngine;
  BOOL _headlessEngineStarted;
}

+ (FuncRegisterPlugins) registerPlugins {
  return _registerPlugins;
}

+ (void) setRegisterPlugins:(FuncRegisterPlugins)registerPlugins {
  _registerPlugins = registerPlugins;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
}

+ (BGTaskHandler*) instance {
  @synchronized (self) {
    if (_instance == nil) {
      _instance = [[BGTaskHandler alloc] init];
    }
  }
  return _instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // init a headless engine instance for callback
    _headlessEngine = [[FlutterEngine alloc] initWithName:@"flt_worker_isolate"
                                                  project:nil
                                   allowHeadlessExecution:YES];
    [self startCallbackDispatcher];

    // methodCallHandler must be set on a running engine
    _delegate = [[BGTaskMgrDelegate alloc] initWithEngine:_headlessEngine];
    [_delegate.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
      [self handleMethodCall:call result:result];
    }];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  if (![_delegate handleMethodCall:call result:result]) {
    result(FlutterMethodNotImplemented);
  }
}

/** Start a headless engine instance with the entry handle */
- (void)startCallbackDispatcher {
  @synchronized (self) {
    if (!_headlessEngineStarted) {
      int64_t handle = dispatcherHandle();
      FlutterCallbackInformation *cbInfo = [FlutterCallbackCache lookupCallbackInformation:handle];
      if (cbInfo == nil) {
        NSLog(@"callback not found for handle: %lld", handle);
        return;
      }

      [_headlessEngine runWithEntrypoint:cbInfo.callbackName libraryURI:cbInfo.callbackLibraryPath];
      _registerPlugins(_headlessEngine);
      _headlessEngineStarted = YES;
    }
  }
}

- (void)handleBGTask:(BGTask * _Nonnull)task {
  NSString *identifier = task.identifier;
  NSLog(@"Handling BGTask id=%@", identifier);
    
  int64_t handle = workerHandle();
  [_delegate.methodChannel invokeMethod:@API_METHOD(dispatch)
                              arguments:@[
                                @(handle),
                                [_delegate packPayloadForTask:identifier],
                              ]
                                 result:^(id _Nullable result) {
    if ([result isKindOfClass:[FlutterError class]]) {
      NSLog(@"BGTask '%@' execution failed: %@ %@", identifier, ((FlutterError*) result).code, ((FlutterError*) result).message);
      [task setTaskCompletedWithSuccess:NO];
    } else if (result == FlutterMethodNotImplemented) {
      NSLog(@"Dart worker for BGTask '%@' is NOT implemented", identifier);
      [task setTaskCompletedWithSuccess:NO];
    } else {
      NSLog(@"BGTask '%@' done. result=%@", identifier, result);
      [task setTaskCompletedWithSuccess:YES];
    }
  }];

  task.expirationHandler = ^{
    NSLog(@"WARN: BGTask expired. id=%@", identifier);
  };
}

@end
