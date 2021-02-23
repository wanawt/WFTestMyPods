//
//  LRAdConfigManager.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/24.
//

#import <Foundation/Foundation.h>
#import "LRAdConfigModel.h"
#import "HHFlsAdModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LRAdConfigManager : NSObject

@property (nonatomic, strong) NSArray *adArray;

+ (LRAdConfigManager *)sharedManager;

- (HHFlsAdModel *)adModelWithConfig:(HHFlsAdModel *)adConfig;

@end

NS_ASSUME_NONNULL_END
