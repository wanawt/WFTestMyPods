//
//  LRAdConfigModel.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/24.
//

#import "LRAdConfigModel.h"
#import "NSObject+YYLRModel.h"
#import "LRAdModel.h"

@implementation LRAdConfigModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"placements" : [LRAdConfigModel class] };
}

- (NSString *)platformSort {
    NSMutableString *string = [NSMutableString string];
    for (LRAdConfigModel *model in self.placements) {
        [string appendFormat:@" %@ ", model.lrPlatformDesc];
    }
    return string;
}

- (NSString *)lrPlatformDesc {
//    NSInteger platformInt = self.platform.integerValue;
//    if (platformInt == LRAdPlatformTypeGDT) {
//        return @"广点通";
//    }
//    if (platformInt == LRAdPlatformTypeCSJ) {
//        return @"穿山甲";
//    }
//    if (platformInt == LRAdPlatformTypeKS) {
//        return @"快手";
//    }
//    return @"广告平台有误";
    return @"";
}

@end
