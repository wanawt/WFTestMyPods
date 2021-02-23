//
//  LRTaskFinishTipController.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/18.
//

#import <AdFulishe/AdFulishe.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHCloseTipBlock)(void);   // 关闭回调
typedef void(^HHCallLookVideoBlock)(void);  // 观看视频回调
typedef void(^HHImgTextLaunchBlock)(NSString *status, NSString *sendData);  // 信息流加载状态回调

@interface LRTaskFinishTipController : HHFlsBaseController

@property (nonatomic, copy) HHCloseTipBlock closeTipBlock;
@property (nonatomic, copy) HHCallLookVideoBlock callLookVideoBlock;
@property (nonatomic, copy) HHImgTextLaunchBlock imgTextLaunchBlock;

@property (nonatomic, assign) BOOL viewsIsHidden;   // 视图已隐藏
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSString *sendDataString;

- (void)hideViews;  // 隐藏式图
- (void)refreshWithParams:(NSDictionary *)params;   // 刷新视图（会显示，viewsIsHidden会置yes）

@end

NS_ASSUME_NONNULL_END
