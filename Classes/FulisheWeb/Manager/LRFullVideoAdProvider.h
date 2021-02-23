//
//  LRFullVideoAdProvider.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/25.
//

#import <Foundation/Foundation.h>

#import "HHFlsAdModel.h"
#import "LRAdModel.h"
#import "HHHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LRFullVideoAdDelegate <NSObject>

@optional

- (void)lrFullscreenVideoAdDidLoad:(LRAdModel *)adModel;

/// 视频出现
- (void)lrFullscreenVideoAdDidVisible:(LRAdModel *)adModel;

/// 视频关闭
- (void)lrFullscreenVideoAdDidClose:(LRAdModel *)adModel;

/// 加载失败
- (void)lrFullscreenVideoAdLoadFailed:(LRAdModel *)adModel error:(NSError *)error;

@end

@interface LRFullVideoAdProvider : NSObject

+ (LRFullVideoAdProvider *)sharedInstance;

+ (void)showKsAdWithAdId:(HHFlsAdModel *)flsAdConfig
                delegate:(id<LRFullVideoAdDelegate>)delegate
          rootController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
