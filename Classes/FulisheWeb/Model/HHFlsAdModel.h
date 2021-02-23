//
//  HHFlsAdModel.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHFlsAdModel : NSObject

@property (nonatomic, strong) HHFlsAdModel *csj;
@property (nonatomic, strong) HHFlsAdModel *gdt;
@property (nonatomic, strong) HHFlsAdModel *ks;
@property (nonatomic, strong) HHFlsAdModel *df;
@property (nonatomic, strong) HHFlsAdModel *smb;
@property (nonatomic, strong) NSArray *sort;
@property (nonatomic, strong) NSArray *tmpSort;

@property (nonatomic, copy) NSString *appTypeId;
@property (nonatomic, strong) HHFlsAdModel *configFlow;         // 信息流
@property (nonatomic, strong) HHFlsAdModel *configFlowTu;       // 信息流图片
@property (nonatomic, strong) HHFlsAdModel *configKaiping;      // 开屏广告
@property (nonatomic, strong) HHFlsAdModel *configVideo;        // 激励视频
@property (nonatomic, strong) HHFlsAdModel *configFullScreen;   // 全屏广告
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic, copy) NSString *mediaName;
@property (nonatomic, copy) NSString *typePlatform;

@property (nonatomic, copy) NSString *advertId;
@property (nonatomic, copy) NSString *advertIdentify;

@end

NS_ASSUME_NONNULL_END
