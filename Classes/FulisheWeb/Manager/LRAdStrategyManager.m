//
//  LRAdStrategyManager.m
//  LRAD
//
//  广告展示策略
//
//  Created by 张维凡 on 2020/12/25.
//

#import "LRAdStrategyManager.h"
#import "LRAdConfigModel.h"
#import "HHHeader.h"
//#import "LRMacroHeader.h"
//#import "LRAdManager.h"

@interface LRAdStrategyManager ()

@property (nonatomic, strong) NSArray *adArray; // 已加载的广告
@property (nonatomic, strong) NSArray *adStrategyArray; // 广告平台展示策略
@property (nonatomic, assign) BOOL isTimeout;

@end

@implementation LRAdStrategyManager

- (void)loadCSJ {
    if ([self.delegate respondsToSelector:@selector(lr_loadCsjAdvert)]) {
        [self.delegate lr_loadCsjAdvert];
    }
}

- (void)loadGDT {
    if ([self.delegate respondsToSelector:@selector(lr_loadGdtAdvert)]) {
        [self.delegate lr_loadGdtAdvert];
    }
}

- (void)loadKS {
    if ([self.delegate respondsToSelector:@selector(lr_loadKsAdvert)]) {
        [self.delegate lr_loadKsAdvert];
    }
}

- (void)loadSigmob {
    if ([self.delegate respondsToSelector:@selector(lr_loadSigmobAdvert)]) {
        [self.delegate lr_loadSigmobAdvert];
    }
}

- (void)loadDF {
    if ([self.delegate respondsToSelector:@selector(lr_loadDfAdvert)]) {
        [self.delegate lr_loadDfAdvert];
    }
}

- (void)refreshAds {
    // 代理为空 或者 不响应 lr_matchedStrategyAdvertModel: 方法，立即返回
    if (self.delegate == nil) {
        return;
    }
    
    [self reloadData];
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(lr_advertLoadIsTimeout)]) {
        self.isTimeout = [self.delegate lr_advertLoadIsTimeout];
    }
    if ([self.delegate respondsToSelector:@selector(lr_advertArray)]) {
        self.adArray = [self.delegate lr_advertArray];
    }
    if ([self.delegate respondsToSelector:@selector(lr_advertPlatformStrategyArray)]) {
        self.adStrategyArray = [self.delegate lr_advertPlatformStrategyArray];
    }
    
    NSString *adPlatform = [self.adStrategyArray firstObject];
    if ([adPlatform isEqualToString:@"csj"]) {
        [self loadCSJ];
    } else if ([adPlatform isEqualToString:@"ks"]) {
        [self loadKS];
    } else if ([adPlatform isEqualToString:@"gdt"]) {
        [self loadGDT];
    } else if ([adPlatform isEqualToString:@"smb"]) {
        [self loadSigmob];
//    } else if ([adPlatform isEqualToString:@"df"]) {
//        [self loadDF];
    } else {
        [self.delegate lr_matchedAdPlatformNotSupport];
    }
}

@end
