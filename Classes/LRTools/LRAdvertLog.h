//
//  LRAdvertLog.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/29.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
# define LRLog(fmt, ...) [[LRAdvertLog sharedInstance] logDebugMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__]];
#else
# define LRLog(fmt, ...) NSLog(@"" fmt);
#endif

NS_ASSUME_NONNULL_BEGIN

@interface LRAdvertLog : NSObject

@property (nonatomic, assign) BOOL showDebugLog;

+ (LRAdvertLog *)sharedInstance;

- (void)logDebugMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
