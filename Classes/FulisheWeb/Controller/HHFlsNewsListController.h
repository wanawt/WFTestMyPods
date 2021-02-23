//
//  HHFlsNewsListController.h
//  importevent
//
//  Created by 张维凡 on 2020/11/4.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsBaseController.h"
#import "HHAnimateViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHTaskCallBackBlock)(NSString *sendConfig, NSString *sourceType);
typedef void(^HHFinishedAdTaskBlock)(NSString *sendConfig);

@interface HHFlsNewsListController : HHFlsBaseController

@property (nonatomic, copy) NSString *sendConfig;
@property (nonatomic, copy) NSDictionary *sendConfigDict;
@property (nonatomic, copy) NSDictionary *adConfigDict;
@property (nonatomic, copy) HHFinishedAdTaskBlock finishedAdTaskBlock;
@property (nonatomic, copy) HHTaskCallBackBlock taskCallBackBlock;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, weak) id<HHAnimateViewProtocol> dataSource;

- (void)showTaskFinishTipView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
