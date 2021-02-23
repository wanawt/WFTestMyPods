//
//  LRFullVideoAdProvider.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/25.
//

#import "LRFullVideoAdProvider.h"
#import "LRAdvertLog.h"
#import "LRAdStrategyManager.h"

#import <KSAdSDK/KSAdSDK.h>
#import <WindSDK/WindSDK.h>

@interface LRFullVideoAdProvider () <KSFullscreenVideoAdDelegate, LRAdStrategyDelegate, WindFullscreenVideoAdDelegate>

@property (nonatomic, copy) NSString *adId;
@property (nonatomic, strong) HHFlsAdModel *adModel;
@property (nonatomic, strong) KSFullscreenVideoAd *fullscreenVideoAd;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, weak) id<LRFullVideoAdDelegate> delegate;
@property (nonatomic, strong) LRAdStrategyManager *strategyManager;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) BOOL adIsShowing;

@end

@implementation LRFullVideoAdProvider

+ (LRFullVideoAdProvider *)sharedInstance {
    static LRFullVideoAdProvider *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LRFullVideoAdProvider alloc] init];
    });
    return manager;
}

+ (void)showKsAdWithAdId:(HHFlsAdModel *)flsAdConfig
                delegate:(id<LRFullVideoAdDelegate>)delegate
          rootController:(UIViewController *)controller {
    if (flsAdConfig) {
        LRLog(@"全屏-展示平台顺序：%@", [flsAdConfig sort]);
        LRFullVideoAdProvider *videoAd = [LRFullVideoAdProvider sharedInstance];
        videoAd.adModel = flsAdConfig;
        videoAd.delegate = delegate;
        videoAd.controller = controller;
        [videoAd loadAdverts];
    } else {
        LRLog(@"error code: %@ 广告位ID有误，请核对！", @(LRAdErrorCode102));
    }
}

- (void)loadAdverts {
    [self.strategyManager refreshAds];
}

- (void)reloadAdvert {
    NSMutableArray *tmpArray = [self.adModel.sort mutableCopy];
    if (tmpArray.count == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(lrFullscreenVideoAdLoadFailed:error:)]) {
            NSError *error = [NSError errorWithDomain:@"" code:LRAdErrorCode303 userInfo:@{@"message":@"没有加载出广告！"}];
            [self.delegate lrFullscreenVideoAdLoadFailed:[self configAdModel] error:error];
        }
        return;
    }
    [tmpArray removeObjectAtIndex:0];
    self.adModel.sort = tmpArray;
    [self.strategyManager refreshAds];
}

- (void)show:(LRAdModel *)adModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrFullscreenVideoAdDidLoad:)]) {
        [self.delegate lrFullscreenVideoAdDidLoad:adModel];
    }
    self.adIsShowing = YES;
    if (adModel.platform.integerValue == LRAdPlatformTypeKS) {
        LRLog(@"展示快手广告");
        [self.fullscreenVideoAd showAdFromRootViewController:self.controller];
    } else if (adModel.platform.integerValue == LRAdPlatformTypeSigmob) {
        LRLog(@"展示Sigmob广告");
        BOOL isReady = [[WindRewardedVideoAd sharedInstance] isReady:self.adId];
        if (isReady) {
            NSError *error = nil;
            [[WindRewardedVideoAd sharedInstance] playAd:self.controller withPlacementId:self.adId options:nil error:&error];
            if (error) {
                LRLog(@"Sigmob loadFailed:%@", error);
                [self reloadAdvert];
            }
        } else {
            LRLog(@"Sigmob loadFailed: ad isnot ready!");
            [self reloadAdvert];
        }
    }
}

- (LRAdModel *)configAdModel {
    LRAdModel *adModel = [[LRAdModel alloc] init];
    adModel.adId = self.adId;
    return adModel;
}

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
    return 20;
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

- (void)lr_loadKsAdvert {
    self.fullscreenVideoAd = [[KSFullscreenVideoAd alloc] initWithPosId:self.adModel.ks.configFullScreen.advertId];
    self.fullscreenVideoAd.delegate = self;
    [self.fullscreenVideoAd loadAdData];
}

- (void)lr_loadSigmobAdvert {
    WindAdRequest *request = [WindAdRequest request];
    [WindFullscreenVideoAd sharedInstance].delegate = self;
    [[WindFullscreenVideoAd sharedInstance] loadRequest:request withPlacementId:self.adModel.smb.configFullScreen.advertId];
}

#pragma mark - KS Delegate

/**
 视频物料加载成功
 */
- (void)fullscreenVideoAdDidLoad:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdDidLoad: %@", fullscreenVideoAd);
}

/**
 视频加载失败
 */
- (void)fullscreenVideoAd:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    LRLog(@"KS fullscreenVideoAd:didFailWithError: %@", error);
    [self reloadAdvert];
}
/**
 视频加载成功
 */
- (void)fullscreenVideoAdVideoDidLoad:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdVideoDidLoad: %@->%@", fullscreenVideoAd, @(fullscreenVideoAd.isValid));
    if (self.fullscreenVideoAd.isValid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LRAdModel *model = [[LRAdModel alloc] initWithAdId:self.adId adView:self.fullscreenVideoAd];
            model.isAdVaild = YES;
            model.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeKS)];
            [self show:model];
        });
    } else {
        LRLog(@"KS 获取广告资源失败");
        [self reloadAdvert];
    }
}

/**
 视频出现
 */
- (void)fullscreenVideoAdDidVisible:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdDidVisible: %@", fullscreenVideoAd);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrFullscreenVideoAdDidVisible:)]) {
        [self.delegate lrFullscreenVideoAdDidVisible:[self configAdModel]];
    }
}

/**
 关闭视频
 */
- (void)fullscreenVideoAdDidClose:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdDidClose: %@", fullscreenVideoAd);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrFullscreenVideoAdDidClose:)]) {
        [self.delegate lrFullscreenVideoAdDidClose:[self configAdModel]];
    }
}

/**
 视频被点击
 */
- (void)fullscreenVideoAdDidClick:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdDidClick: %@", fullscreenVideoAd);
}

/**
 播放结束
 */
- (void)fullscreenVideoAdDidPlayFinish:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    LRLog(@"KS fullscreenVideoAd:didFailWithError: %@", error);
}

/**
 开始播放
 */
- (void)fullscreenVideoAdStartPlay:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdStartPlay: %@", fullscreenVideoAd);
}

/**
 点击跳过按钮
 */
- (void)fullscreenVideoAdDidClickSkip:(KSFullscreenVideoAd *)fullscreenVideoAd {
    LRLog(@"KS fullscreenVideoAdDidClickSkip: %@", fullscreenVideoAd);
}

#pragma mark - Sigmob Delegate

/**
 全屏视频广告物料加载成功（此时isReady=YES）
 广告是否ready请以当前回调为准
 */
- (void)onFullscreenVideoAdLoadSuccess:(NSString *)placementId {
    LRAdModel *model = [[LRAdModel alloc] initWithAdId:self.adId adView:self.fullscreenVideoAd];
    model.isAdVaild = YES;
    model.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeSigmob)];
    [self show:model];
}


/**
 全屏视频广告加载时发生错误
 @param error 发生错误时会有相应的code和message
 */
- (void)onFullscreenVideoAdError:(NSError *)error placementId:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdError:placementId:%@", placementId);
    [self reloadAdvert];
}


/**
 全屏视频广告关闭
 */
- (void)onFullscreenVideoAdClosed:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdClosed:%@", placementId);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrFullscreenVideoAdDidClose:)]) {
        [self.delegate lrFullscreenVideoAdDidClose:[self configAdModel]];
    }
}

/**
 全屏视频广告开始播放
 */
- (void)onFullscreenVideoAdPlayStart:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdPlayStart:%@", placementId);
}

/**
 全屏视频广告发生点击
 */
- (void)onFullscreenVideoAdClicked:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdClicked:%@", placementId);
}

/**
 全屏视频广告调用播放时发生错误
 @param error 发生错误时会有相应的code和message
 */
- (void)onFullscreenVideoAdPlayError:(NSError *)error placementId:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdPlayError:placementId:%@", placementId);
    [self reloadAdvert];
}

/**
 全屏视频广告视频播关闭
 */
- (void)onFullscreenVideoAdPlayEnd:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdPlayEnd:%@", placementId);
}

/**
 全屏视频广告AdServer返回广告(表示渠道有广告填充)
 */
- (void)onFullscreenVideoAdServerDidSuccess:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdServerDidSuccess:%@", placementId);
}

/**
 全屏视频广告AdServer无广告返回(表示渠道无广告填充)
 */
- (void)onFullscreenVideoAdServerDidFail:(NSString *)placementId {
    LRLog(@"Sigmob onFullscreenVideoAdServerDidFail:%@", placementId);
    [self reloadAdvert];
}

@end
