//
//  LRDevice.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import "LRDevice.h"

@implementation LRDevice

+ (CGFloat)lr_statusBarHeight {
    if ([UIScreen mainScreen].bounds.size.height > 736) {
        return 44;
    }
    return 20;
}

+ (CGFloat)lr_safeHeight {
    if ([UIScreen mainScreen].bounds.size.height > 736) {
        return 40;
    }
    return 0;
}

+ (CGFloat)lr_navigationBarHeight {
    return 44;
}

+ (CGFloat)lr_topHeight {
    return [LRDevice lr_statusBarHeight]+[LRDevice lr_navigationBarHeight];
}

+ (CGFloat)lr_bottomOffset {
    if ([UIScreen mainScreen].bounds.size.height > 736) {
        return 34;
    }
    return 0;
}

+ (CGFloat)lr_tabbarHeight {
    return 49 + [LRDevice lr_bottomOffset];
}

+ (BOOL)lr_isPhoneX {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return NO;  // 不是手机
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[UIApplication sharedApplication].windows lastObject];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

@end
