//
//  LRInfoFlowAdProvider.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/15.
//

#import "LRInfoFlowAdProvider.h"
#import "BUAdSDK.h"
#import "UIView+LRAddition.h"
#import <KSAdSDK/KSAdSDK.h>
#import "GDTSDKConfig.h"
#import "GDTSDKConfig.h"
#import "GDTUnifiedNativeAd.h"

#import "LRInfoFlowView.h"
#import "LRAdConfigManager.h"
#import "LRAdStrategyManager.h"
#import "LRAdConfigModel.h"

#import "HHHeader.h"

@interface LRInfoFlowAdProvider () <KSNativeAdsManagerDelegate, KSNativeAdDelegate, GDTUnifiedNativeAdDelegate, GDTUnifiedNativeAdViewDelegate, BUNativeExpressAdViewDelegate, BUNativeExpressAdViewDelegate, LRAdStrategyDelegate>

@property (nonatomic, copy) NSString *adId;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, assign) CGSize adSize;    // 广告大小

@property (nonatomic, weak) id<LRInfoFlowAdDelegate> delegate;
@property (nonatomic, strong) BUNativeExpressAdManager *nativeExpressAdManager;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) KSNativeAdsManager *nativeAdsManager;
@property (nonatomic, strong) GDTUnifiedNativeAd *unifiedNativeAd;
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) LRAdStrategyManager *strategyManager;
@property (nonatomic, assign) BOOL adLoadIsTimeout; // 加载超时
@property (nonatomic, assign) BOOL adIsShowing;     // 已展示广告
@property (nonatomic, assign) NSInteger adCount;

@property (nonatomic, strong) HHFlsAdModel *adModel;
@property (nonatomic, assign) BOOL isLoadingAdvert;

@property (nonatomic, assign) NSInteger loadTimeCount;  // 记录加载次数

@end

@implementation LRInfoFlowAdProvider

+ (LRInfoFlowAdProvider *)sharedInstance {
    static LRInfoFlowAdProvider *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LRInfoFlowAdProvider alloc] init];
    });
    return manager;
}

+ (void)infoFlowAdWithAd:(HHFlsAdModel *)flsAdConfig
                delegate:(nonnull id<LRInfoFlowAdDelegate>)delegate
              adViewSize:(CGSize)size
                 adCount:(NSInteger)adCount
          fromController:(nonnull UIViewController *)controller {
    LRInfoFlowAdProvider *infoFlowAd = [LRInfoFlowAdProvider sharedInstance];
    if (flsAdConfig) {
        LRLog(@"信息流-展示平台顺序：%@", [flsAdConfig sort]);
        if (infoFlowAd.isLoadingAdvert) {
            LRLog(@"信息流-正在加载");
            [infoFlowAd infoFlowAdIsLoading];
            return;
        }
        infoFlowAd.adLoadIsTimeout = NO;
        infoFlowAd.adIsShowing = NO;
        [infoFlowAd.datas removeAllObjects];
        
        infoFlowAd.adSize = size;
        infoFlowAd.adCount = adCount;
        infoFlowAd.adModel = flsAdConfig;
        infoFlowAd.delegate = delegate;
        infoFlowAd.controller = controller;
        [infoFlowAd loadAdverts];
    } else {
        LRLog(@"error code: %@ 广告位ID有误，请核对！", @(LRAdErrorCode102));
    }
}

- (void)infoFlowAdIsLoading {
    LRLog(@"信息流-正在加载，准备调取回调");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrInfoFlowAdIsLoading:)]) {
        LRLog(@"信息流-正在加载，调取回调");
        [self.delegate lrInfoFlowAdIsLoading:YES];
    }
}

#pragma mark - Getter

- (LRAdStrategyManager *)strategyManager {
    if (!_strategyManager) {
        _strategyManager = [[LRAdStrategyManager alloc] init];
        _strategyManager.delegate = self;
    }
    return _strategyManager;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

#pragma mark - Event

- (void)loadAdverts {
    self.isLoadingAdvert = YES;
    [self.strategyManager refreshAds];
}

- (void)show:(LRAdModel *)model {
    self.adIsShowing = YES;
    self.loadTimeCount = 0;
    if (model.platform.integerValue == LRAdPlatformTypeCSJ) {
        LRLog(@"展示穿山甲广告");
    } else if (model.platform.integerValue == LRAdPlatformTypeKS) {
        LRLog(@"展示快手广告");
    } else if (model.platform.integerValue == LRAdPlatformTypeGDT) {
        LRLog(@"展示广点通广告->%@", @(model.adViewArray.count));
    }
    self.isLoadingAdvert = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrNativeExpressAdSuccessToLoad:)]) {
        [self.delegate lrNativeExpressAdSuccessToLoad:model];
    }
}


- (LRAdModel *)configAdModel {
    LRAdModel *model = [[LRAdModel alloc] init];
    model.adId = self.adId;
    return model;
}

#pragma mark - CSJ Delegate

/**
 * 广告视图加载成功
 */
- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAdManager views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    LRLog(@"CSJ nativeExpressAdSuccessToLoad ad->%@", views);
    NSMutableArray *array = [NSMutableArray array];
    if (views.count) {
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
            expressView.rootViewController = self.controller;
            // important: 此处会进行WKWebview的渲染，建议一次最多预加载三个广告，如果超过3个会很大概率导致WKWebview渲染失败。
            [expressView render];

            expressView.frame = CGRectMake(0, 0, self.adSize.width, expressView.lr_height/expressView.lr_width*self.adSize.width);
            
            LRInfoFlowView *adView = [[LRInfoFlowView alloc] init];
            adView.adView = expressView;
            adView.frame = expressView.bounds;
            [adView addSubview:expressView];
            [array addObject:adView];
        }];

        LRAdModel *adModel = [[LRAdModel alloc] initWithAdId:self.adId adViewArray:array];
        adModel.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeCSJ)];
        [self show:adModel];
    }
}

/**
 * 广告视图加载失败
 */
- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAdManager error:(NSError *_Nullable)error {
    self.adIsShowing = NO;
    
    [self reloadAdvert];
    LRLog(@"CSJ nativeExpressAdFailToLoad ad->%@", error);
    LRLog(@"error code: %@  广告加载失败", @(LRAdErrorCode301));
}

/**
 * 广告视图渲染成功
 */
- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    LRLog(@"CSJ nativeExpressAdViewRenderSuccess ad->%@", nativeExpressAdView);
}

/**
 * 广告视图渲染失败
 */
- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *_Nullable)error {
    LRLog(@"CSJ nativeExpressAdViewRenderFail ad->%@", error);
}

/**
 * 广告内容即将展示
 */
- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    LRLog(@"CSJ nativeExpressAdViewWillShow ad->%@", nativeExpressAdView);
}

/**
 * 广告被点击
 */
- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    LRLog(@"CSJ nativeExpressAdViewDidClick ad->%@", nativeExpressAdView);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrNativeExpressAdViewDidClick:)]) {
        [self.delegate lrNativeExpressAdViewDidClick:[self configAdModel]];
    }
}

/**
 * 视频广告状态变更
 * @param playerState : 视频状态
 */
- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView stateDidChanged:(BUPlayerPlayState)playerState {
    LRLog(@"CSJ nativeExpressAdView stateDidChanged ad->%@", nativeExpressAdView);
}

/**
 * 视频播放结束
 */
- (void)nativeExpressAdViewPlayerDidPlayFinish:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    LRLog(@"CSJ nativeExpressAdViewPlayerDidPlayFinish ad->%@", error);
}

/**
 * 用户点击不喜欢
 * @param filterWords : 不喜欢的原因
 */
- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    LRLog(@"CSJ nativeExpressAdView dislikeWithReason ad->%@", nativeExpressAdView);
}

/**
 * Sent after an ad view is clicked, a ad landscape view will present modal content
 */
- (void)nativeExpressAdViewWillPresentScreen:(BUNativeExpressAdView *)nativeExpressAdView {
    LRLog(@"CSJ nativeExpressAdViewWillPresentScreen ad->%@", nativeExpressAdView);
}

/**
 * This method is called when another controller has been closed.
 * @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeExpressAdViewDidCloseOtherController:(BUNativeExpressAdView *)nativeExpressAdView interactionType:(BUInteractionType)interactionType {
    LRLog(@"CSJ nativeExpressAdViewDidCloseOtherController ad->%@", nativeExpressAdView);
}

#pragma mark - KS NativeAdsManagerDelegate

- (void)nativeAdsManagerSuccessToLoad:(KSNativeAdsManager *)adsManager nativeAds:(NSArray<KSNativeAd *> *_Nullable)nativeAdDataArray {
    if (nativeAdDataArray.count == 0) {
        LRLog(@"KS error code: %@ 平台没有返回广告", @(LRAdErrorCode302));
    }
    LRLog(@"KS nativeExpressAdSuccessToLoad ad->%@", nativeAdDataArray);
    //【重要】不能保存太多view，需要在合适的时机手动释放不用的，否则内存会过大
    NSMutableArray *array = [NSMutableArray array];
    for (KSNativeAd *ksAd in nativeAdDataArray) {
        ksAd.delegate = self; // 设置了delegate之后，feedAdDidShowOtherController 处会崩溃，原因未知
        ksAd.rootViewController = self.controller;
        LRInfoFlowView *adView = [[LRInfoFlowView alloc] init];
        adView.canRegisterClickableViews = YES;
        adView.canRegisterClickableSmallViews = YES;
        adView.canRegisterClickableTipViews = YES;
        adView.frame = CGRectMake(0, 0, self.adSize.width, self.adSize.height);
        adView.adData = ksAd;
        adView.adTitle = ksAd.data.adDescription;
        adView.adDesc = ksAd.data.adSource;
        adView.adPlatform = @"快手广告";
        [array addObject:adView];
    }
    LRAdModel *adModel = [[LRAdModel alloc] initWithAdId:self.adId adViewArray:array];
    adModel.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeKS)];
    [self show:adModel];
}

- (void)nativeAdsManager:(KSNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self reloadAdvert];
    
    LRLog(@"KS nativeAdsManager:didFailWithError:->%@", error);
    LRLog(@"KS error code: %@  广告加载失败", @(LRAdErrorCode301));
}

- (void)nativeAdDidLoad:(KSNativeAd *)nativeAd {
    LRLog(@"KS nativeAdDidLoad");
}

- (void)nativeAd:(KSNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    [self reloadAdvert];
    LRLog(@"KS nativeAd:didFailWithError:%@", error);
    LRLog(@"KS error code: %@  广告加载失败", @(LRAdErrorCode301));
}

- (void)nativeAdDidClick:(KSNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    LRLog(@"KS nativeAdDidClick");
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrNativeExpressAdViewDidClick:)]) {
        [self.delegate lrNativeExpressAdViewDidClick:[self configAdModel]];
    }
}

#pragma mark - GDT UnifiedNativeAdDelegate

/**
 * 拉取广告的回调，包含成功和失败情况
 */
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (unifiedNativeAdDataObjects == nil || unifiedNativeAdDataObjects.count == 0 || error) {
        [self reloadAdvert];
        LRLog(@"GDT error code: %@ 平台没有返回广告", @(LRAdErrorCode302));
        if (error) {
            if (error.code == 5004) {
                LRLog(@"GDT 没匹配的广告，禁止重试，否则影响流量变现效果");
            } else if (error.code == 5005) {
                LRLog(@"GDT 流量控制导致没有广告，超过日限额，请明天再尝试");
            } else if (error.code == 5009) {
                LRLog(@"GDT 流量控制导致没有广告，超过小时限额");
            } else if (error.code == 5006) {
                LRLog(@"GDT 包名错误");
            } else if (error.code == 5010) {
                LRLog(@"GDT 广告样式校验失败");
            } else if (error.code == 3001) {
                LRLog(@"GDT error code: %@ 网络错误", @(LRAdErrorCode200));
            } else {
                LRLog(@"GDT ERROR: %@", error);
            }
        }
        return;
    }

    NSMutableArray *array = [NSMutableArray array];
    for (GDTUnifiedNativeAdDataObject *dataObject in unifiedNativeAdDataObjects) {
        GDTUnifiedNativeAdView *unifiedNativeAdView = [[GDTUnifiedNativeAdView alloc] init];
        
        CGFloat adViewWidth = (CGFloat)dataObject.imageWidth;
        CGFloat adViewHeight = (CGFloat)dataObject.imageHeight;
        if (adViewWidth > 0) {
            adViewHeight = adViewHeight/adViewWidth*self.adSize.width;
        } else {
            adViewHeight = self.adSize.height;
        }
        adViewWidth = self.adSize.width;
        
        unifiedNativeAdView.frame = CGRectMake(0, 0, adViewWidth, adViewHeight);
        unifiedNativeAdView.delegate = self;
        unifiedNativeAdView.viewController = self.controller; // 设置点击跳转的 VC
        
        LRInfoFlowView *adView = [[LRInfoFlowView alloc] init];
        adView.canRegisterClickableViews = YES;
        adView.canRegisterClickableSmallViews = YES;
        adView.canRegisterClickableTipViews = YES;
        adView.frame = CGRectMake(0, 0, self.adSize.width, 9.0/16.0*self.adSize.width);
        adView.adView = unifiedNativeAdView;
        adView.adData = dataObject;
        adView.adTitle = dataObject.desc;
        adView.adDesc = dataObject.title;
        adView.adPlatform = @"广点通广告";
        [adView addSubview:unifiedNativeAdView];
        [array addObject:adView];
    }
    
    LRAdModel *adModel = [[LRAdModel alloc] initWithAdId:self.adId adViewArray:array];
    adModel.platform = [NSString stringWithFormat:@"%@", @(LRAdPlatformTypeGDT)];
    [self show:adModel];
}

#pragma mark - Delegate

/**
 广告曝光回调
 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    LRLog(@"gdt_unifiedNativeAdViewWillExpose:%@", unifiedNativeAdView);
}

/**
 广告点击回调
 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    LRLog(@"gdt_unifiedNativeAdViewDidClick:%@", unifiedNativeAdView);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lrNativeExpressAdViewDidClick:)]) {
        [self.delegate lrNativeExpressAdViewDidClick:[self configAdModel]];
    }
}

/**
 广告详情页关闭回调
 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    LRLog(@"gdt_unifiedNativeAdDetailViewClosed:%@", unifiedNativeAdView);
}

/**
 当点击应用下载或者广告调用系统程序打开时调用
 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    LRLog(@"gdt_unifiedNativeAdViewApplicationWillEnterBackground:%@", unifiedNativeAdView);
}

/**
 广告详情页面即将展示回调
 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    LRLog(@"gdt_unifiedNativeAdDetailViewWillPresentScreen:%@", unifiedNativeAdView);
}

/**
 视频广告播放状态更改回调
 @param nativeExpressAdView GDTUnifiedNativeAdView 实例
 @param status 视频广告播放状态
 @param userInfo 视频广告信息
 */
- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    LRLog(@"gdt_unifiedNativeAdView:playerStatusChanged:userInfo:%@", unifiedNativeAdView);
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

// 穿山甲-模板
- (void)lr_loadCsjAdvert {
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = self.adModel.csj.configFlow.advertId;
    slot1.AdType = BUAdSlotAdTypeFeed;
    BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
    slot1.imgSize = imgSize;
    slot1.position = BUAdSlotPositionFeed;
    self.nativeExpressAdManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(self.adSize.width, self.adSize.height)];
    self.nativeExpressAdManager.delegate = self;
    [self.nativeExpressAdManager loadAdDataWithCount:self.adCount];
}

// 快手-自渲染
- (void)lr_loadKsAdvert {
    self.nativeAdsManager = [[KSNativeAdsManager alloc] initWithPosId:self.adModel.ks.configFlow.advertId];
//    self.nativeAdsManager = [[KSNativeAdsManager alloc] initWithPosId:@"5390000084"];
    self.nativeAdsManager.delegate = self;
    [self.nativeAdsManager loadAdDataWithCount:self.adCount];
}

// 广点通-自渲染
- (void)lr_loadGdtAdvert {
    self.unifiedNativeAd = [[GDTUnifiedNativeAd alloc] initWithPlacementId:self.adModel.gdt.configFlow.advertId];
    self.unifiedNativeAd.delegate = self;
    [self.unifiedNativeAd loadAdWithAdCount:self.adCount];
}

- (void)lr_loadSigmobAdvert {
    [self reloadAdvert];
}

- (void)lr_matchedAdPlatformNotSupport {
    [self reloadAdvert];
}

- (void)reloadAdvert {
    LRLog(@"reloadAdvert->%@", self.adModel.sort);
    NSMutableArray *tmpArray = [self.adModel.sort mutableCopy];
    if (tmpArray.count == 0) {
        self.isLoadingAdvert = NO;
        self.adModel.sort = [self.adModel.tmpSort mutableCopy];
        if (self.delegate && [self.delegate respondsToSelector:@selector(lrNativeExpressAdFailToLoad:error:)]) {
            NSError *error = [NSError errorWithDomain:@"" code:LRAdErrorCode303 userInfo:@{@"message":@"没有加载出广告！"}];
            [self.delegate lrNativeExpressAdFailToLoad:[self configAdModel] error:error];
            LRLog(@"广告策略sort空了，广告加载失败！！！！");
        }
        self.loadTimeCount++;
        return;
    }
    [tmpArray removeObjectAtIndex:0];
    self.adModel.sort = tmpArray;
    [self.strategyManager refreshAds];
}

+ (BOOL)canReloadAd {
    if ([LRInfoFlowAdProvider sharedInstance].loadTimeCount <= 5) {
        return YES;
    }
    return NO;
}

+ (void)clearProvider {
    LRInfoFlowAdProvider *infoFlowAd = [LRInfoFlowAdProvider sharedInstance];
    infoFlowAd.delegate = nil;
    infoFlowAd.controller = nil;
    infoFlowAd.isLoadingAdvert = NO;
}

@end
