//
//  LRAdStrategyManager.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/25.
//

#import <Foundation/Foundation.h>
#import "LRAdModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LRAdStrategyDelegate <NSObject>

/// 广告平台权重策略，按先后顺序优先展示
- (NSArray *)lr_advertPlatformStrategyArray;

/// 已加载的广告
- (NSArray *)lr_advertArray;

/// 匹配到的广告
/// @param adModel 广告model
- (void)lr_matchedStrategyAdvertModel:(LRAdModel *)adModel;

/// 加载超时
- (BOOL)lr_advertLoadIsTimeout;

/// 已获取ad，正在展示
- (BOOL)lr_advertIsShowing;

@optional

/// 先过滤掉禁用的广告平台，然后调用未禁用的平台

/// 加载穿山甲广告
- (void)lr_loadCsjAdvert;

/// 加载广点通广告
- (void)lr_loadGdtAdvert;

/// 加载快手广告
- (void)lr_loadKsAdvert;

/// 加载Sigmob广告
- (void)lr_loadSigmobAdvert;

// 加载东方广告
- (void)lr_loadDfAdvert;

/// 匹配到的广告平台不支持
- (void)lr_matchedAdPlatformNotSupport;

@end

@interface LRAdStrategyManager : NSObject

@property (nonatomic, weak) id<LRAdStrategyDelegate> delegate;

- (void)refreshAds;

@end

NS_ASSUME_NONNULL_END
