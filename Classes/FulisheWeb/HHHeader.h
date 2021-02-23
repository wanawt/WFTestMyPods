//
//  HHHeader.h
//  hhsqad
//
//  Created by 张维凡 on 2020/11/4.
//
#import "LRDevice.h"
#import "UIView+LRAddition.h"
#import "NSObject+LRAddition.h"
#import "LRAdvertLog.h"
#import "GDTSDKConfig.h"
#import "NSObject+YYLRModel.h"

#ifndef HHHeader_h
#define HHHeader_h

#define HHWeakSelf __weak __typeof(self)weakSelf = self;

#define KLRScreenWidth    [UIScreen mainScreen].bounds.size.width
#define KLRScreenHeight   [UIScreen mainScreen].bounds.size.height
#define KFLSStatusHeight [LRDevice lr_statusBarHeight]
#define KFLSNavigationHeight [LRDevice lr_navigationBarHeight]
#define KFLSTopHeight [LRDevice lr_topHeight]
#define KFLSTopOffset [LRDevice lr_safeHeight]
#define KFLSBottomOffset [LRDevice lr_bottomOffset]
#define KFLSTabbarHeight [LRDevice lr_tabbarHeight]
#define KFLSDeviceWidthScale ([UIScreen mainScreen].bounds.size.width)/375.0

#define KLRCsjInfoFlowScale 1.32
#define KLRCsjInfoFlowTipScale 1.22

#define KLRColorWhite FLSRGBValue(0xffffff)
#define KLRColorBlack FLSRGBValue(0x000000)

#define FLSRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define FLSRGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define FLSRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define FLSRGBAValue(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define kDegreesToRadians(x) (M_PI*(x)/180.0)                 //把角度转换成PI的方式



// 广告平台类型
typedef NS_ENUM(NSUInteger, LRAdPlatformType) {
    LRAdPlatformTypeGDT = 1,    // 广点通
    LRAdPlatformTypeCSJ = 2,    // 穿山甲
    LRAdPlatformTypeKS  = 3,    // 快手
    LRAdPlatformTypeSigmob = 4, // Sigmob
    LRAdPlatformTypeDF = 5,     // 东方
};

// 错误码
typedef NS_ENUM(NSInteger, LRAdErrorCode) {
    LRAdErrorCode100 = -100,    // 参数错误
    LRAdErrorCode101 = -101,    // 平台初始化错误
    LRAdErrorCode102 = -102,    // 广告位错误
    LRAdErrorCode103 = -103,    // 方法调用错误
    LRAdErrorCode104 = -104,    // 未找到视频
    LRAdErrorCode105 = -105,    // 未找到广告
    LRAdErrorCode106 = -106,    // 未找到视图
    LRAdErrorCode200 = -200,    // 网络错误
    LRAdErrorCode301 = -301,    // 加载广告失败
    LRAdErrorCode302 = -302,    // 平台没有返回广告
    LRAdErrorCode303 = -303,    // 广告加载超时
};


#endif /* HHHeader_h */
