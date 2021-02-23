//
//  HHADWebController.h
//  hhsqad
//
//  Created by 张维凡 on 2020/10/15.
//

#import "HHFlsBaseController.h"
#import "HHAnimateViewProtocol.h"
#import "LRShareWxProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^openAppBlock)(NSString *openUrl);

@interface HHADWebController : HHFlsBaseController

@property (nonatomic, weak) id dataSource;
@property (nonatomic, weak) id<LRShareWxProtocol> shareDelegate;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) openAppBlock openAppBlock;

@end

NS_ASSUME_NONNULL_END
