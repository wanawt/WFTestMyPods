//
//  LRAdvertLog.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/29.
//

#import "LRAdvertLog.h"
#import "HHAdViewManager.h"

@interface LRAdvertLog ()

@end

@implementation LRAdvertLog

+ (LRAdvertLog *)sharedInstance {
    static LRAdvertLog *adLog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adLog = [[LRAdvertLog alloc] init];
    });
    return adLog;
}

- (void)logDebugMessage:(NSString *)message {
    if (self.showDebugLog) {
        NSLog(@"LRAD: %@", message);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";

        UITextView *textView = [[HHAdViewManager sharedManager] debugLogTextView];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableString *string = [textView.text mutableCopy];
            [string appendFormat:@"\n[%@] LRAD: %@\n", [formatter stringFromDate:[NSDate date]], message];
            textView.text = string;
        });
    }
}

@end
