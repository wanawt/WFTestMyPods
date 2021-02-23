//
//  HHContinueTaskController.h
//  AdFulishe
//
//  Created by 张维凡 on 2020/12/14.
//

#import <AdFulishe/AdFulishe.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^finishTaskBlock)(void);
typedef void(^continueTaskBlock)(NSString *sendData);
typedef void(^continueBlock)(void);

@interface HHContinueTaskController : HHFlsBaseController

@property (nonatomic, copy) finishTaskBlock finishTaskBlock;
@property (nonatomic, copy) continueBlock continueBlock;
@property (nonatomic, copy) continueTaskBlock continueTaskBlock;

@property (nonatomic, assign) BOOL viewsIsHidden;   // 视图已隐藏
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSString *sendDataString;

- (void)hideViews;  // 隐藏式图
- (void)refreshWithParams:(NSDictionary *)params;   // 刷新视图（会显示，viewsIsHidden会置yes）

@end

NS_ASSUME_NONNULL_END
