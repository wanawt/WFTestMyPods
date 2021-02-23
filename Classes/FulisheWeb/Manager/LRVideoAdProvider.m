//
//  LRVideoAdProvider.m
//  LRAD
//
//  激励视频
//
//  Created by 张维凡 on 2020/12/9.
//

#import "LRVideoAdProvider.h"
#import "BUAdSDK.h"
#import "UIView+LRAddition.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "GDTRewardVideoAd.h"
#import <KSAdSDK/KSAdSDK.h>
#import <WindSDK/WindSDK.h>
//#import <AdFulishe/XMAd.h>

#import "LRAdConfigManager.h"
#import "LRAdStrategyManager.h"
#import "LRAdConfigModel.h"

@interface LRVideoAdProvider () <BUNativeExpressRewardedVideoAdDelegate, GDTRewardedVideoAdDelegate, KSRewardedVideoAdDelegate, LRAdStrategyDelegate, WindRewardedVideoAdDelegate>
//, XMVideoAdDelegate> {
//    XMVideoAd *_videoAd;
//}

@property (nonatomic, copy) NSString *adId;
@property (nonatomic, strong) HHFlsAdModel *adModel;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, weak) id<LRVideoAdProtocol> delegate;
@property (nonatomic, strong) UIViewController *controller;

@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *rewardedAd;
@property (nonatomic, strong) GDTRewardVideoAd *rewardGDTAd;
@property (nonatomic, strong) KSRewardedVideoAd *rewardedKSAd;
@property (nonatomic, strong) WindRewardedVideoAd *rewardedSigmobAd;

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) LRAdStrategyManager *strategyManager;

@property (nonatomic, assign) BOOL adLoadIsTimeout; // 加载超时
@property (nonatomic, assign) BOOL adIsShowing;     // 已展示广告

@end

@implementation LRVideoAdProvider

+ (LRVideoAdProvider *)sharedInstance {
    static LRVideoAdProvider *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LRVideoAdProvider alloc] init];
    });
    return manager;
}

+ (void)videoAdWithAd:(HHFlsAdModel *)flsAdConfig
             delegate:(id<LRVideoAdProtocol>)delegate
       fromController:(id)controller {
    LRVideoAdProvider *videoAd = [LRVideoAdProvider sharedInstance];
    if (flsAdConfig) {
        LRLog(@"激励-展示平台顺序：%@", [flsAdConfig sort]);
        videoAd.adLoadIsTimeout = NO;
        videoAd.adIsShowing = NO;
        [videoAd.datas removeAllObjects];
        videoAd.adModel = flsAdConfig;
        videoAd.delegate = delegate;
        videoAd.controller = controller;
        [videoAd loadAdverts];
    } else {
        LRLog(@"error code: %@ 广告位ID有误，请核对！", @(LRAdErrorCode102));
        [videoAd loadAdFailed];
    }
}

- (void)loadAdFailed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAd:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:@"" code:LRAdErrorCode303 userInfo:@{@"message":@"没有加载出广告！"}];
        [self.delegate lrRewardedVideoAd:[self configAdModel] didFailWithError:error];
    }
}

- (void)loadAdverts {
    [self.strategyManager refreshAds];
}

- (void)reloadAdvert {
    NSMutableArray *tmpArray = [self.adModel.sort mutableCopy];
    if (tmpArray.count == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAd:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"" code:LRAdErrorCode303 userInfo:@{@"message":@"没有加载出广告！"}];
            [self.delegate lrRewardedVideoAd:[self configAdModel] didFailWithError:error];
        }
        return;
    }
    [tmpArray removeObjectAtIndex:0];
    self.adModel.sort = tmpArray;
    [self.strategyManager refreshAds];
}

- (void)loadVideoAdWithUserId:(NSString *)userId {
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = userId;
    self.rewardedAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:self.adModel.csj.configVideo.advertId rewardedVideoModel:model];
    self.rewardedAd.delegate = self;
    [self.rewardedAd loadAdData];
}

- (void)showSplashAd {
    NSTimeInterval loadTimeout = 10;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(loadTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.adLoadIsTimeout = YES;
        [self.strategyManager refreshAds];
        if (self.datas.count > 0) {
            LRLog(@"%@秒内加载完成%@个广告", @(loadTimeout), @(self.datas.count));
        } else {
            LRLog(@"error code: %@  %@秒内未加载出广告，已超时！", @(LRAdErrorCode303), @(loadTimeout));
            if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAd:didFailWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"" code:LRAdErrorCode303 userInfo:@{@"message":@"未加载出广告，已超时！"}];
                [self.delegate lrRewardedVideoAd:[self configAdModel] didFailWithError:error];
            }
        }
    });
}

- (void)show:(LRAdModel *)adModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidLoad:)]) {
        [self.delegate lrRewardedVideoAdDidLoad:adModel];
    }
    self.adIsShowing = YES;
    if (adModel.platform.integerValue == LRAdPlatformTypeCSJ) {
        LRLog(@"展示穿山甲广告");
        [self.rewardedAd showAdFromRootViewController:self.controller];
    } else if (adModel.platform.integerValue == LRAdPlatformTypeGDT) {
        LRLog(@"展示广点通广告");
        [self.rewardGDTAd showAdFromRootViewController:self.controller];
    } else if (adModel.platform.integerValue == LRAdPlatformTypeKS) {
        LRLog(@"展示快手广告");
        [self.rewardedKSAd showAdFromRootViewController:self.controller];
    } else if (adModel.platform.integerValue == LRAdPlatformTypeSigmob) {
        LRLog(@"展示Sigmob广告");
        /* 使用isReady检查对应广告位的广告是否可以播放 */
        BOOL isReady = [self.rewardedSigmobAd isReady:self.adId];
        if (isReady) {
            NSError *error = nil;
            [self.rewardedSigmobAd playAd:self.controller withPlacementId:self.adId options:nil error:&error];
            if (error) {
                LRLog(@"Sigmob isReady:%@", error);
                [self reloadAdvert];
            }
        } else {
            LRLog(@"Sigmob video is not ready");
            [self reloadAdvert];
        }
    }
//    else if (adModel.platform.integerValue == LRAdPlatformTypeDF) {
//        LRLog(@"展示东方广告");
//        _videoAd.adDelegate = self;
//        [_videoAd playAdFromVC:self.controller playCompletion:^(BOOL success, NSString * _Nullable errMsg) {
//            self->_videoAd = nil;
//            if (!success) {
//                [self reloadAdvert];
//            }
//        }];
//    }
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (LRAdModel *)configAdModel {
    LRAdModel *adModel = [[LRAdModel alloc] init];
    adModel.adId = self.adId;
    return adModel;
}

#pragma mark - CSJ Delegate

/**
 回调进入证明广告物料已成功加载
 */
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRAdModel *model = [[LRAdModel alloc] initWithAdId:self.adId adView:self.rewardedAd];
    model.isAdVaild = self.rewardedAd.adValid;
    model.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeCSJ)];
    [self show:model];
    if (rewardedVideoAd == nil) {
        LRLog(@"error code: %@ 平台没有返回广告", @(LRAdErrorCode302));
    }
}

/**
 此回调方法中可定位具体的失败原因对应的错误码，打印error即可。所有错误码详情请见链接。
 */
- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self reloadAdvert];
    LRLog(@"CSJ nativeExpressRewardedVideoAd:didFailWithError:%@", error);
}

/**
 建议在此回调方法中进行广告的展示操作，可保证播放流畅和展示流畅，用户体验更好。
 可以调用 [BUNativeExpressRewardedVideoAd showAdFromRootViewController:].
 */
- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidDownLoadVideo");
}

/**
 渲染成功回调。3100之后版本SDK，广告展示之后才会回调
 */
- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdViewRenderSuccess");

//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdViewRenderSuccess:)]) {
//        LRAdModel *adModel = [[LRAdModel alloc] init];
//        adModel.adId = self.adId;
//        [self.delegate lrRewardedVideoAdViewRenderSuccess:adModel];
//    }
}

/**
 渲染失败，网络原因或者硬件原因导致渲染失败,可以更换手机或者网络环境测试。建议升级到穿山甲平台最新版本
 */
- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    LRLog(@"CSJ nativeExpressRewardedVideoAdViewRenderFail:error:%@", error);
    self.adIsShowing = NO;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdViewRenderFail:error:)]) {
//        LRAdModel *adModel = [[LRAdModel alloc] init];
//        adModel.adId = self.adId;
//        [self.delegate lrRewardedVideoAdViewRenderFail:adModel error:error];
//    }
}

/**
 模版激励视频广告即将展示
 */
- (void)nativeExpressRewardedVideoAdWillVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdWillVisible");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdWillVisible:)]) {
//        LRAdModel *adModel = [[LRAdModel alloc] init];
//        adModel.adId = self.adId;
//        [self.delegate lrRewardedVideoAdWillVisible:adModel];
//    }
}

/**
 模版激励视频广告已经展示
 */
- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidVisible");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidVisible:)]) {
        [self.delegate lrRewardedVideoAdDidVisible:[self configAdModel]];
    }
}

/**
 模版激励视频广告即将关闭
 */
- (void)nativeExpressRewardedVideoAdWillClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdWillClose");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdWillClose:)]) {
//        [self.delegate lrRewardedVideoAdWillClose:[self configAdModel]];
//    }
}

/**
 用户关闭广告时会触发此回调，注意：任何广告的关闭操作必须用户主动触发;可在此回调方法中进行客户端奖励发放的处理，具体可依据项目需求进行奖励发放时机的选择
 */
- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidClose");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClose:)]) {
        [self.delegate lrRewardedVideoAdDidClose:[self configAdModel]];
    }
}

/**
 点击回调方法
 */
- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidClick");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClick:)]) {
        [self.delegate lrRewardedVideoAdDidClick:[self configAdModel]];
    }
}

/**
 跳过回调方法
 */
- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidClickSkip");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClickSkip:)]) {
        [self.delegate lrRewardedVideoAdDidClickSkip:[self configAdModel]];
    }
}

/**
 视频正常播放完成时可触发此回调方法，当广告播放发生异常时，不会进入此回调;
 可在此回调方法中进行客户端奖励发放的处理，具体可依据项目需求进行奖励发放时机的选择
 */
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidPlayFinish:didFailWithError:%@", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidPlayFinish:didFailWithError:)]) {
        [self.delegate lrRewardedVideoAdDidPlayFinish:[self configAdModel] didFailWithError:error];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardVideoAdDidRewardEffective:)]) {
        [self.delegate lrRewardVideoAdDidRewardEffective:YES];
    }
}

/**
 异步请求的服务器验证成功回调。现在包括两个验证方法:1. C2C需要服务器验证2。S2S不需要服务器验证。nativeExpressRewardedVideoAdServerRewardDidFail:异步请求的服务器验证失败回调。可在此回调方法中打印error，定位具体失败的原因，或通过抓包定位具体原因，抓包地址：https://域名或者ip地址/api/ad/union/sdk/get_ads/ 提供返回的数据进行确认）到【留言反馈】-【技术类提问入口（技术类暂仅支持此入口的提问回复）】进行反馈，相关同学会为您处理
 @param verify :return YES when return value is 2000.
 */
- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    LRLog(@"CSJ nativeExpressRewardedVideoAdServerRewardDidSucceed");
}

/**
  Server verification which is requested asynchronously is failed.
  @param rewardedVideoAd express rewardVideo Ad
  @param error request error info
 */
- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    LRLog(@"CSJ nativeExpressRewardedVideoAdServerRewardDidFail");
}

/**
 参数可区分是打开的appstore/网页/视频广告详情页面
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeExpressRewardedVideoAdDidCloseOtherController:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd interactionType:(BUInteractionType)interactionType {
    LRLog(@"CSJ nativeExpressRewardedVideoAdDidCloseOtherController");
}

#pragma mark - GDT delegate
/**
 广告数据加载成功回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    if (rewardedVideoAd == nil) {
        LRLog(@"error code: %@ 平台没有返回广告", @(LRAdErrorCode302));
    }
    LRLog(@"gdt_rewardVideoAdDidLoad");
    if (!self.rewardGDTAd.isAdValid) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdLoseEffectiveness)]) {
            [self.delegate lrRewardedVideoAdLoseEffectiveness];
        }
        return;
    }
    LRAdModel *model = [[LRAdModel alloc] initWithAdId:self.adId adView:self.rewardGDTAd];
    model.isAdVaild = rewardedVideoAd.adValid;
    model.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeGDT)];
    [self show:model];
}

/**
 视频数据下载成功回调，已经下载过的视频会直接回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdVideoDidLoad");
}

/**
 视频播放页即将展示回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdWillVisible");
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdWillVisible:)]) {
//        LRAdModel *adModel = [[LRAdModel alloc] init];
//        adModel.adId = self.adId;
//        [self.delegate lrRewardedVideoAdWillVisible:adModel];
//    }
}

/**
 视频广告曝光回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdDidExposed");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidVisible:)]) {
        [self.delegate lrRewardedVideoAdDidVisible:[self configAdModel]];
    }
}

/**
 视频播放页关闭回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdDidClose");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClose:)]) {
        [self.delegate lrRewardedVideoAdDidClose:[self configAdModel]];
    }
}

/**
 视频广告信息点击回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdDidClicked");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClick:)]) {
        [self.delegate lrRewardedVideoAdDidClick:[self configAdModel]];
    }
}

/**
 视频广告各种错误信息回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    self.adIsShowing = NO;
    [self reloadAdvert];
    LRLog(@"GDT didFailWithError error is %@", error);
    LRLog(@"GDT error code: %@  广告加载失败", @(LRAdErrorCode301));
}

/**
 视频广告播放达到激励条件回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdDidRewardEffective");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardVideoAdDidRewardEffective:)]) {
        [self.delegate lrRewardVideoAdDidRewardEffective:YES];
    }
}

/**
 视频广告视频播放完成

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    LRLog(@"gdt_rewardVideoAdDidPlayFinish");
}

#pragma mark - KS Delegate
/**
 This method is called when video ad material loaded successfully.
 */
- (void)rewardedVideoAdDidLoad:(KSRewardedVideoAd *)rewardedVideoAd {
    if (rewardedVideoAd == nil) {
        LRLog(@"error code: %@ 平台没有返回广告", @(LRAdErrorCode302));
    }
    LRLog(@"KS rewardedVideoAdDidLoad %@", rewardedVideoAd);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (rewardedVideoAd.isValid) {
            LRAdModel *model = [[LRAdModel alloc] initWithAdId:self.adId adView:self.rewardedKSAd];
            model.isAdVaild = rewardedVideoAd.isValid;
            model.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeKS)];
            [self show:model];
        }
    });
}
/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    self.adIsShowing = NO;
    [self reloadAdvert];
    LRLog(@"KS didFailWithError %@", error);
    LRLog(@"error code: %@  广告加载失败", @(LRAdErrorCode301));
}
/**
 This method is called when cached successfully.
 */
- (void)rewardedVideoAdVideoDidLoad:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdVideoDidLoad");
}
/**
 This method is called when video ad slot will be showing.
 */
- (void)rewardedVideoAdWillVisible:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdWillVisible");
}
/**
 This method is called when video ad slot has been shown.
 */
- (void)rewardedVideoAdDidVisible:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdDidVisible")
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidVisible:)]) {
        LRAdModel *adModel = [[LRAdModel alloc] init];
        adModel.adId = self.adId;
        [self.delegate lrRewardedVideoAdDidVisible:adModel];
    }
}
/**
 This method is called when video ad is about to close.
 */
- (void)rewardedVideoAdWillClose:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdWillClose");
}
/**
 This method is called when video ad is closed.
 */
- (void)rewardedVideoAdDidClose:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdDidClose");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClose:)]) {
        [self.delegate lrRewardedVideoAdDidClose:[self configAdModel]];
    }
}

/**
 This method is called when video ad is clicked.
 */
- (void)rewardedVideoAdDidClick:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdDidClick");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClick:)]) {
        [self.delegate lrRewardedVideoAdDidClick:[self configAdModel]];
    }
}
/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)rewardedVideoAdDidPlayFinish:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    LRLog(@"KS rewardedVideoAdDidPlayFinish:didFailWithError: error is %@", error);
}
/**
 This method is called when the user clicked skip button.
 */
- (void)rewardedVideoAdDidClickSkip:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdDidClickSkip");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClickSkip:)]) {
        [self.delegate lrRewardedVideoAdDidClickSkip:[self configAdModel]];
    }
}
/**
 This method is called when the video begin to play.
 */
- (void)rewardedVideoAdStartPlay:(KSRewardedVideoAd *)rewardedVideoAd {
    LRLog(@"KS rewardedVideoAdStartPlay");
}
/**
 This method is called when the user close video ad.
 */
- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd hasReward:(BOOL)hasReward {
    LRLog(@"KS rewardedVideoAd:hasReward:%@", @(hasReward));
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardVideoAdDidRewardEffective:)]) {
        [self.delegate lrRewardVideoAdDidRewardEffective:YES];
    }
}

#pragma mark - Sigmob Delegate

/**
 激励视频广告物料加载成功（此时isReady=YES）
 广告是否ready请以当前回调为准
 */
- (void)onVideoAdLoadSuccess:(NSString *)placementId {
    LRLog(@"Sigmob onVideoAdLoadSuccess");
    LRAdModel *model = [[LRAdModel alloc] initWithAdId:self.adId adView:self.rewardedSigmobAd];
    model.isAdVaild = [self.rewardedSigmobAd isReady:placementId];
    model.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeSigmob)];
    [self show:model];
}


/**
 激励视频广告加载时发生错误
 @param error 发生错误时会有相应的code和message
 @param placementId 广告位Id
 */
- (void)onVideoError:(NSError *)error placementId:(NSString *)placementId {
    LRLog(@"Sigmob onVideoError:%@ placementId:%@", error, placementId);
    self.adIsShowing = NO;
    [self reloadAdvert];
}

/**
 激励视频广告关闭
 @param info WindRewardInfo里面包含一次广告关闭中的是否完整观看等参数
 @param placementId 广告位Id
 */
- (void)onVideoAdClosedWithInfo:(WindRewardInfo *)info placementId:(NSString *)placementId {
    LRLog(@"Sigmob onVideoAdClosedWithInfo:placementId:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClose:)]) {
        [self.delegate lrRewardedVideoAdDidClose:[self configAdModel]];
    }
}

/**
 激励视频广告开始播放
 @param placementId 广告位Id
 */
- (void)onVideoAdPlayStart:(NSString *)placementId {
    LRLog(@"Sigmob onVideoAdPlayStart:%@", placementId);
}

/**
 激励视频广告发生点击
 @param placementId 广告位Id
 */
- (void)onVideoAdClicked:(NSString *)placementId {
    LRLog(@"Sigmob onVideoAdClicked:%@", placementId);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClick:)]) {
        [self.delegate lrRewardedVideoAdDidClick:[self configAdModel]];
    }
}

/**
 激励视频广告调用播放时发生错误
 @param error 发生错误时会有相应的code和message
 @param placementId 广告位Id
 */
- (void)onVideoAdPlayError:(NSError *)error placementId:(NSString *)placementId {
    
}

/**
 激励视频广告视频播关闭
 @param placementId 广告位Id
 */
- (void)onVideoAdPlayEnd:(NSString *)placementId {
    
}

/**
 激励视频广告AdServer返回广告(表示渠道有广告填充)
 @param placementId 广告位Id
 */
- (void)onVideoAdServerDidSuccess:(NSString *)placementId {
    
}

/**
 激励视频广告AdServer无广告返回(表示渠道无广告填充)
 @param placementId 广告位Id
 */
- (void)onVideoAdServerDidFail:(NSString *)placementId {
    LRLog(@"Sigmob onVideoAdServerDidFail: %@", placementId);
    self.adIsShowing = NO;
    [self reloadAdvert];
}

//#pragma mark - DF Delegate
//
///// 曝光回调
//- (void)videoAdDidExposure:(XMVideoAd *)ad {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidVisible:)]) {
//        [self.delegate lrRewardedVideoAdDidVisible:[self configAdModel]];
//    }
//}
//
///// 点击回调
//- (void)videoAdDidClick:(XMVideoAd *)ad {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClick:)]) {
//        [self.delegate lrRewardedVideoAdDidClick:[self configAdModel]];
//    }
//}
//
///// 关闭
//- (void)videoAdDidClose:(XMVideoAd *)ad {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidClose:)]) {
//        [self.delegate lrRewardedVideoAdDidClose:[self configAdModel]];
//    }
//}
//
///// 视频播放结束回调
//- (void)videoAdPlayFinished:(BOOL)finished error:(XMError *)error {
//    if (error) {
//        [self reloadAdvert];
//    }
//}

///// 视频上方自定义额外的试图，例如vip充值可跳过广告(慎用)
///// @param ad ad
//- (UIView *)videoAdCustomExtraView:(XMVideoAd *)ad {
//
//}
//
///// 自定义试图是否常驻激励视频（无论是播放时，还是播放结束），默认false
//- (BOOL)videoAdCustomExtraViewAlwaysOnContainer:(XMVideoAd *)ad {
//
//}

///// 额外的视频被点击（注意只能去打开新的页面，且是fullscreen的全屏）
//- (void)videoAdExtraViewDidClick:(XMVideoAd *)ad controller:(UIViewController *)vc {
//
//}

#pragma mark - Strategy Getter

- (LRAdStrategyManager *)strategyManager {
    if (!_strategyManager) {
        _strategyManager = [[LRAdStrategyManager alloc] init];
        _strategyManager.delegate = self;
    }
    return _strategyManager;
}

#pragma mark - Ad Strategy Delegate

- (NSArray *)lr_advertArray {
    return self.datas;
}

- (NSArray *)lr_advertPlatformStrategyArray {
    return self.adModel.sort;
}

- (BOOL)lr_advertLoadIsTimeout {
    return self.adLoadIsTimeout;
}

- (void)lr_matchedStrategyAdvertModel:(LRAdModel *)adModel {
    [self show:adModel];
}

- (BOOL)lr_advertIsShowing {
    return self.adIsShowing;
}

- (void)lr_matchedAdPlatformNotSupport {
    [self reloadAdvert];
}

- (void)lr_loadGdtAdvert {
    self.rewardGDTAd = [[GDTRewardVideoAd alloc] initWithPlacementId:self.adModel.gdt.configVideo.advertId];
    self.rewardGDTAd.delegate = self;
    self.rewardGDTAd.videoMuted = NO; // 设置模板激励视频是否静音
    [self.rewardGDTAd loadAd];
}

- (void)lr_loadKsAdvert {
    self.rewardedKSAd=[[KSRewardedVideoAd alloc] initWithPosId:self.adModel.ks.configVideo.advertId rewardedVideoModel:[KSRewardedVideoModel new]];
    [KSAdSDKManager setUserInfoBlock:^(KSAdUserInfo *userInfo) {
        // 设置userId
        // userInfo.userId = @"1afds23";
    }];
    self.rewardedKSAd.delegate = self;
    [self.rewardedKSAd loadAdData];
}

- (void)lr_loadCsjAdvert {
    if (@available(iOS 14, *)) {
        // iOS14方式访问 IDFA
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                NSString *idfaStr = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadVideoAdWithUserId:idfaStr];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadVideoAdWithUserId:@"123"];
                });
            }
        }];
    } else {
        // 使用原方式访问 IDFA
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            NSString *idfaStr = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
            [self loadVideoAdWithUserId:idfaStr];
        } else {
            [self loadVideoAdWithUserId:@"123"];
        }
    }
}

- (void)lr_loadSigmobAdvert {
//    self.adId = @"ea704a607ce";
    WindAdRequest *request = [WindAdRequest request];
    self.rewardedSigmobAd = [WindRewardedVideoAd sharedInstance];
    [self.rewardedSigmobAd setDelegate:self];
    [self.rewardedSigmobAd loadRequest:request withPlacementId:self.adModel.smb.configVideo.advertId];
}

//- (void)lr_loadDfAdvert {
//    [XMVideoAdProvider videoAdModelWithPosition:self.adModel.df.configVideo.advertIdentify completion:^(XMVideoAd * _Nullable model, XMError *_Nullable error) {
//        self->_videoAd = model;
//        if (error || model == nil) {
//            [self reloadAdvert];
//        } else {
//            LRAdModel *tmpModel = [[LRAdModel alloc] initWithAdId:self.adId adView:model];
//            tmpModel.isAdVaild = model.effective;
//            tmpModel.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeDF)];
//            if (self.delegate && [self.delegate respondsToSelector:@selector(lrRewardedVideoAdDidLoad:)]) {
//                [self.delegate lrRewardedVideoAdDidLoad:tmpModel];
//            }
//            [self show:tmpModel];
//        }
//    }];
//}

@end
