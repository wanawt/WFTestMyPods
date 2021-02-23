//
//  LRDevice.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRDevice : NSObject

/**
 状态栏高度
  */
+ (CGFloat)lr_statusBarHeight;

+ (CGFloat)lr_safeHeight;

/**
 导航栏高度
  */
+ (CGFloat)lr_navigationBarHeight;


/**
 导航栏加状态栏高度
  */
+ (CGFloat)lr_topHeight;


/**
 X底部高度
  */
+ (CGFloat)lr_bottomOffset;

/**
 底部高度+tabbar高度
 */
+ (CGFloat)lr_tabbarHeight;

+ (BOOL)lr_isPhoneX;

@end

NS_ASSUME_NONNULL_END
