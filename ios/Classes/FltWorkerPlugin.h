#import <Flutter/Flutter.h>

typedef void (^FuncRegisterPlugins)(NSObject<FlutterPluginRegistry>*registry);

@interface FltWorkerPlugin : NSObject<FlutterPlugin>

/**
 * Provides a callback to register needed plugins for the headless isolate.
 *
 * Example:
 * ```
 * - (BOOL)application:(UIApplication *)application
 *     didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 *   FltWorkerPlugin.registerPlugins = ^(NSObject<FlutterPluginRegistry> *registry) {
 *     [GeneratedPluginRegistrant registerWithRegistry:registry];
 *   };
 * }
 * ```
 */
@property (class, copy) FuncRegisterPlugins registerPlugins;
@end
