//
//  LRInfoFlowAdProvider.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/15.
//

#import <UIKit/UIKit.h>
#import "LRAdModel.h"
#import "HHFlsAdModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LRInfoFlowAdDelegate <NSObject>
@optional

- (void)lrInfoFlowAdIsLoading:(BOOL)isLoading;

/**
 * 广告加载成功
 */
- (void)lrNativeExpressAdSuccessToLoad:(LRAdModel *)adModel;

/**
 * 广告加载失败
 */
- (void)lrNativeExpressAdFailToLoad:(LRAdModel *)nativeExpressAdManager error:(NSError *_Nullable)error;

/**
 * 广告被点击
 */
- (void)lrNativeExpressAdViewDidClick:(LRAdModel *)nativeExpressAdView;

/**
播放状态改变
@param playerState : 播放状态
*/
//- (void)lrNativeExpressAdView:(LRAdModel *)nativeExpressAdView stateDidChanged:(LRPlayerPlayState)playerState;

/**
 * 播放结束
 * @param error : 播放错误
 */
- (void)lrNativeExpressAdViewPlayerDidPlayFinish:(LRAdModel *)nativeExpressAdView error:(NSError *)error;

/**
 * 点击广告之后，即将Present广告内容
 */
- (void)lrNativeExpressAdViewWillPresentScreen:(LRAdModel *)nativeExpressAdView;

@end

@interface LRInfoFlowAdProvider : NSObject

+ (LRInfoFlowAdProvider *)sharedInstance;

+ (void)infoFlowAdWithAd:(HHFlsAdModel *)flsAdConfig
                delegate:(id<LRInfoFlowAdDelegate>)delegate
              adViewSize:(CGSize)size
                 adCount:(NSInteger)adCount
          fromController:(UIViewController *)controller;

/// Provider是否可以加载广告，
/// 如果加载失败次数大于5次，就禁止加载，直到下次加载成功，失败次数会清零（目前只用于信息流列表）
+ (BOOL)canReloadAd;

/// 清理Provider，新闻详情页面，弹窗优先级比底部新闻高，所以弹窗出现的时候清理掉Provider状态
+ (void)clearProvider;

@end

NS_ASSUME_NONNULL_END
