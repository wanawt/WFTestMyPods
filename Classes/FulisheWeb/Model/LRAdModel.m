//
//  LRAdModel.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import "LRAdModel.h"

@implementation LRAdModel

- (instancetype)initWithAdId:(NSString *)adId adView:(id)adView {
    if (self = [super init]) {
        self.adId = adId;
        self.adView = adView;
    }
    return self;
}

- (instancetype)initWithAdId:(NSString *)adId adViewArray:(nonnull NSArray *)adViewArray {
    if (self = [super init]) {
        self.adId = adId;
        self.adViewArray = adViewArray;
    }
    return self;
}

@end
