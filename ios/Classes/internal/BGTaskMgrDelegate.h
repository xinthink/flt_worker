//
//  BGTaskMgrDelegate.h
//  flt_worker
//
//  Created by Yingxin Wu on 2020/3/12.
//

#ifndef BGTaskMgrDelegate_h
#define BGTaskMgrDelegate_h

#import <Flutter/Flutter.h>

@interface BGTaskMgrDelegate : NSObject

@property (readonly, nonatomic) FlutterMethodChannel *methodChannel;

/** Register background task indentifiers. */
+ (void)registerBGTaskHandler;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

- (instancetype)initWithEngine:(FlutterEngine*)engine;

- (BOOL)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

/** Save dispatcher & worker handles for later use */
- (void)saveHandles:(NSArray*)args;

/** Makes a payload dict used as input of the dart worker */
- (NSDictionary*)packPayloadForTask:(NSString*)identifier;
@end

#endif /* BGTaskMgrDelegate_h */
