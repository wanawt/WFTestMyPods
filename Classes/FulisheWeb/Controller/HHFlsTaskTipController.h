//
//  HHFlsTaskTipController.h
//  AdFulishe
//
//  Created by 张维凡 on 2020/11/12.
//

#import "HHFlsBaseController.h"

NS_ASSUME_NONNULL_BEGIN
//
typedef void(^HHWithdrawTaskBlock)(void);   // 关闭回调

@interface HHFlsTaskTipController : HHFlsBaseController

@property (nonatomic, copy) HHWithdrawTaskBlock withdrawTaskBlock;

@end

NS_ASSUME_NONNULL_END
