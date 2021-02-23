//
//  HHAdHHAdViewManagerViewManager.m
//  hhsqad
//
//  Created by 张维凡 on 2020/10/15.
//

#import "HHAdViewManager.h"
#import "HHADNavigationController.h"
#import "GDTSDKConfig.h"
#import "LRAdvertLog.h"
#import <KSAdSDK/KSAdSDK.h>
#import <WindSDK/WindSDK.h>
#import "BUAdSDK.h"
//#import "XMAd.h"
//#import "XMCommon.h"
//#import "XMCommonManager.h"
//#import "XMAdBridge.h"
//#import "XMComHisBridge.h"
#import "HHHeader.h"

@interface HHAdViewManager ()

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation HHAdViewManager

+ (HHAdViewManager *)sharedManager {
    static HHAdViewManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HHAdViewManager alloc] init];
    });
    return manager;
}

- (void)initFLSWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    self.appKey = appKey;
    self.appSecret = appSecret;
    
    [LRAdvertLog sharedInstance].showDebugLog = self.isDebug;
    
//    // 广点通
//    BOOL GDTISSUccess = [GDTSDKConfig registerAppId:@"1110955921"];
//    NSLog(@"LRAD: GDT init is %d", GDTISSUccess);
//
//    // 快手
//    [KSAdSDKManager setAppId:@"539000003"];
//
//    //sigmob
//    WindAdOptions *options = [WindAdOptions options];
//    options.appId = @"5688";
//    options.apiKey = @"2220cc71feb55393";
//    [WindAds startWithOptions:options];
//
//    // 穿山甲
//    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
//    [BUAdSDKManager setAppID:@"5129713"];
    
//    XMConfigParam *param = [[XMConfigParam alloc] init];
//    param.QID_Default = @"AppStore";
//    param.APP_TypeId   = @"300006";
//    //param.sdkRunMode = XMSDKRunModeITest;// 设置测试环境
//    if (self.isDebug) {
//        param.logLevel = XMSDKLogLevelDebug; // log打印开关
//    }
//    XMComHisBridge *his               = [[XMComHisBridge alloc] init];
//    XMComDynamicParamBridge *dynParam = [[XMComDynamicParamBridge alloc] init];
//    [XMCommonManager setupWithConfig:param hisBridge:his paramBridge:dynParam];
//    // Ad
//    XMAdConfig *adCondig = [[XMAdConfig alloc] init];
//    // 请传入实现了XMAdConfigBridge的对象
//    adCondig.adConfigBridge              = [[XMAdBridge alloc] init];
//    [XMAdMain admainWithConf:adCondig];
    
//    NSString *appKey = @"28dc2576349abbce6aea8d80f0611044";
//    NSString *appSecret = @"11ca6463a7796bfa7a30119acef909b5";
}

- (void)showFLSFrom:(UIViewController *)controller userId:(NSString *)userId phone:(NSString *)phone nickName:(NSString *)nickName redirectUrl:(NSString *)redirectUrl deviceIdentify:(NSString *)deviceId {

    NSString *flsUrl = @"https://lrqd.wasair.com/transfer/sdk/into";    // 正式
    if (self.isDevelop) {
        flsUrl = @"http://sandbox.lrqd.wasair.com/transfer/sdk/into";   // 测试
    }
    NSString *url = [NSString stringWithFormat:@"%@?appKey=%@&appSecret=%@&userId=%@&phone=%@&nickName=%@&redirectUrl=%@&deviceId=%@&title=%@&deviceType=%@&version=%@&time=%@&advertTypesVideo=%@&advertTypesInfoFlow=%@", flsUrl, self.appKey, self.appSecret, userId, phone, nickName, redirectUrl, deviceId, @"", @"ios", @"2.3.2", @([NSDate date].timeIntervalSince1970), @"gdt,ks,csj,smb", @"csj"];
    
    [[LRAdvertLog sharedInstance] logDebugMessage:url];
    
    HHADWebController *adWeb = [[HHADWebController alloc] init];
    adWeb.urlString = url;
    adWeb.dataSource = controller;
    adWeb.shareDelegate = self.shareDelegate;
    HHADNavigationController *adnv = [[HHADNavigationController alloc] initWithRootViewController:adWeb];
    adnv.modalPresentationStyle = UIModalPresentationCustom;
    if (self.showWithPresent) {
        [controller presentViewController:adnv animated:YES completion:nil];
    } else {
        [controller.navigationController pushViewController:adWeb animated:YES];
    }
}


- (UITextView *)debugLogTextView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, KLRScreenHeight/4.0, KLRScreenWidth, KLRScreenHeight/4.0*3.0)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.textColor = [UIColor blackColor];
        _textView.font = [UIFont systemFontOfSize:14];
    }
    return _textView;
}

- (void)showDebugLog:(BOOL)show {
    [LRAdvertLog sharedInstance].showDebugLog = show;
}

@end
