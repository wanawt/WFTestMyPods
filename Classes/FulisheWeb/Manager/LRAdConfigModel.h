//
//  LRAdConfigModel.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRAdConfigModel : NSObject

@property (nonatomic, copy) NSString *position_id;  // 广告类型
@property (nonatomic, copy) NSString *platform;     // 广告平台
@property (nonatomic, copy) NSString *lrPlatformDesc;     // 广告平台描述
@property (nonatomic, copy) NSString *placement_id; // 广告位ID
@property (nonatomic, copy) NSString *timeout;

@property (nonatomic, strong) NSArray *placements;

- (NSString *)platformSort;

@end

NS_ASSUME_NONNULL_END
