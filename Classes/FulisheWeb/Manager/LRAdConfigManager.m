//
//  LRAdConfigManager.m
//  LRAD
//
//  获取策略
//
//  Created by 张维凡 on 2020/12/24.
//

#import "LRAdConfigManager.h"
#import "NSObject+YYLRModel.h"
#import "LRAdConfigModel.h"
#import "LRAdModel.h"
#import "LRAdConfigModel.h"

@interface LRAdConfigManager ()

@end

@implementation LRAdConfigManager

+ (LRAdConfigManager *)sharedManager {
    static LRAdConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LRAdConfigManager alloc] init];
    });
    return manager;
}

- (NSArray *)adArray {
//    NSDictionary *adConfigDict = [[NSUserDefaults standardUserDefaults] objectForKey:KLRAdConfig];
    NSDictionary *adConfigDict;
    if (adConfigDict == nil) {
        return @[];
    }
    NSArray *array = [NSArray yylr_modelArrayWithClass:[LRAdConfigModel class] json:adConfigDict[@"positions"]];
    if (array == nil || array.count == 0) {
        return @[];
    }
    return array;
}

- (HHFlsAdModel *)adModelWithConfig:(HHFlsAdModel *)adConfig {
    return adConfig.gdt;
}

@end
