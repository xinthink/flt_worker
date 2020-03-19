//
//  utils.h
//  Pods
//
//  Created by Yingxin Wu on 2020/3/13.
//

#ifndef utils_h
#define utils_h

#import <Flutter/Flutter.h>

#define PLUGIN_PKG "dev.thinkng.flt_worker"
#define API_METHOD(NAME) "FltWorkerPlugin#"#NAME
#define DISPATCHER_KEY "dev.thinkng.flt_worker/callback_dispatcher_handle"
#define WORKER_KEY "dev.thinkng.flt_worker/worker_handle"
#define IS_NONNULL(V) V && ![NSNull.null isEqual:V]
#define TASK_KEY(id) [NSString stringWithFormat:@"dev.thinkng.flt_worker/tasks/%@", id]
#define WORKER_DEFAULTS_LONG(K) [[workerDefaults() objectForKey:@K] longValue] ?: 0

/** Retrieves the `UserDefaults` instance for FltWorkerPlugin. */
NSUserDefaults* workerDefaults(void);

/** Returns raw function handle of the callback dispatcher. */
int64_t dispatcherHandle(void);

/** Returns raw handle of the worker function. */
int64_t workerHandle(void);

typedef void (^FuncRegisterPlugins)(NSObject<FlutterPluginRegistry>*registry);

#endif /* utils_h */
