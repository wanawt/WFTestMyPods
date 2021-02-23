//
//  LRVideoAdProvider.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/9.
//

#import <UIKit/UIKit.h>
#import "LRAdModel.h"
#import "HHHeader.h"
#import "HHFlsAdModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LRVideoAdProtocol <NSObject>
@optional

- (void)lrRewardedVideoAdDidLoad:(LRAdModel *)adModel;

/**
 此回调方法中可定位具体的失败原因对应的错误码，打印error即可。
 */
- (void)lrRewardedVideoAd:(LRAdModel *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;

/**
 广告已出现
 */
- (void)lrRewardedVideoAdDidVisible:(LRAdModel *)rewardedVideoAd;

/**
 广告已关闭
 */
- (void)lrRewardedVideoAdDidClose:(LRAdModel *)rewardedVideoAd;

/**
 点击广告
 */
- (void)lrRewardedVideoAdDidClick:(LRAdModel *)rewardedVideoAd;

/**
 点击跳过按钮
 */
- (void)lrRewardedVideoAdDidClickSkip:(LRAdModel *)rewardedVideoAd;

/**
 视频播放完毕
 */
- (void)lrRewardedVideoAdDidPlayFinish:(LRAdModel *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;

/**
 视频广告无效
 */
- (void)lrRewardedVideoAdLoseEffectiveness;

/**
 视频广告播放达到激励条件
 */
- (void)lrRewardVideoAdDidRewardEffective:(BOOL)hasReward;

@end

@interface LRVideoAdProvider : NSObject

+ (LRVideoAdProvider *)sharedInstance;

+ (void)videoAdWithAd:(HHFlsAdModel *)flsAdConfig
             delegate:(id<LRVideoAdProtocol>)delegate
       fromController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
