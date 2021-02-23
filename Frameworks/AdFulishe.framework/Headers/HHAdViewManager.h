//
//  HHAdViewManager.h
//  hhsqad
//
//  Created by 张维凡 on 2020/10/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HHADWebController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHAdViewManager : NSObject

@property (nonatomic, weak) id<LRShareWxProtocol> shareDelegate;

/// 是否是 测试环境，默认NO
@property (nonatomic, assign) BOOL isDevelop;

/// 是否打印日志
/// 请写在 - (void)initFLSWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret 之前
@property (nonatomic, assign) BOOL isDebug;

/// 以present方式展示，默认否
@property (nonatomic, assign) BOOL showWithPresent;

+ (HHAdViewManager *)sharedManager;
/// 展示日志
/// @param show 展示
- (void)showDebugLog:(BOOL)show;

- (UITextView *)debugLogTextView;

/// 初始化SDK
/// @param appKey 请联向管理员索取appKey
/// @param appSecret 请向管理员索取appSecret
- (void)initFLSWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;

/// 加载福利社
/// @param controller 必传 当前controller，转场方式默认为push，如需present，请设置showWithPresent
/// @param userId 必传 请获取deviceId
/// @param phone 手机号 可以为空
/// @param nickName 昵称 可以为空
/// @param redirectUrl 重定向url 可以为空
/// @param deviceId 必传 目前请传deviceId，同上边的userId
- (void)showFLSFrom:(UIViewController *)controller
             userId:(NSString *)userId
              phone:(NSString *)phone
           nickName:(NSString *)nickName
        redirectUrl:(NSString *)redirectUrl
     deviceIdentify:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
