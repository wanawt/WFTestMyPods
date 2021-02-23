//
//  HHFlsNewsWebController.h
//  importevent
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHFlsNewsWebController : HHFlsBaseController

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *aid;

@property (nonatomic, copy) NSString *sendConfig;
@property (nonatomic, assign) BOOL isFinished;

@end

NS_ASSUME_NONNULL_END
