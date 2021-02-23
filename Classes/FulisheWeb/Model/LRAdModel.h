//
//  LRAdModel.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import <UIKit/UIKit.h>
#import "HHHeader.h"

// 广告类型
typedef NS_ENUM(NSUInteger, LRAdPositionType) {
    LRAdPositionTypeVideo     = 10000,  // 激励视频
    LRAdPositionTypeBanner    = 10001,  // banner
    LRAdPositionTypeSplash    = 10002,  // 开屏
    LRAdPositionTypeFlowImgs  = 10003,  // 信息流多图
    LRAdPositionTypeFlowVideo = 10004,  // 信息流 视频
    LRAdPositionTypeFlow      = 10005   // 信息流
};

NS_ASSUME_NONNULL_BEGIN

@interface LRAdModel : NSObject

@property (nonatomic, copy) NSString *platform;
@property (nonatomic, assign) BOOL isAdVaild;
@property (nonatomic, copy) NSString *adId;
@property (nonatomic, copy) NSString *slotID;   // 同adId
@property (nonatomic, strong) id adView;
@property (nonatomic, strong) NSArray *adViewArray;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithAdId:(NSString *)adId adView:(id)adView;
- (instancetype)initWithAdId:(NSString *)adId adViewArray:(NSArray *)adViewArray;

@end

NS_ASSUME_NONNULL_END
