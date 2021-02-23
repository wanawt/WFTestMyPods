//
//  HHFlsNewsController.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/12.
//

#import <AdFulishe/AdFulishe.h>
#import "HHAnimateViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHTaskCallBackBlock)(NSString *sendConfig, NSString *sourceType);
typedef void(^HHFinishedAdTaskBlock)(NSString *sendConfig);

@interface HHFlsNewsController : HHFlsBaseController

@property (nonatomic, copy) NSString *sendConfig;
@property (nonatomic, copy) NSDictionary *sendConfigDict;
@property (nonatomic, copy) NSDictionary *adConfigDict;
@property (nonatomic, copy) HHFinishedAdTaskBlock finishedAdTaskBlock;
@property (nonatomic, copy) HHTaskCallBackBlock taskCallBackBlock;
@property (nonatomic, weak) id<HHAnimateViewProtocol> dataSource;

- (void)showTaskFinishTipView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
