//
//  HHADWebController.m
//  hhsqad
//
//  Created by 张维凡 on 2020/10/15.
//

#import "HHADWebController.h"
#import "LRHomeTipController.h"
#import "HHFlsNewsListController.h"
#import "HHFlsVideoAdController.h"
#import "HHContinueTaskController.h"
#import "HHFlsNewsController.h"

#import "WKProcessPool+FlsSharedProcessPool.h"
#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "HHAdViewManager.h"
#import "GDTRewardVideoAd.h"
#import "NSObject+YYLRModel.h"
#import "LRAdvertLog.h"
#import "LRVideoAdProvider.h"

#import "LRFullVideoAdProvider.h"
#import "UIImageView+AFLRNetworking.h"

@interface HHADWebController () <WKNavigationDelegate, WKScriptMessageHandler, LRVideoAdProtocol, LRFullVideoAdDelegate>

@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *currentSendDataString;    // 当前sendData
@property (nonatomic, assign) BOOL isShowNewsList;
@property (nonatomic, strong) LRHomeTipController *homeTipController;
@property (nonatomic, strong) NSDictionary *adConfigDict;
@property (nonatomic, copy) NSString *adDetailBtnUrl;   // 信息流查看详情按钮url

@property (nonatomic, assign) BOOL lookVideoAgain;//test
@property (nonatomic, strong) UITextView *textView;

@end

@implementation HHADWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = KLRColorWhite;
    [self.view addSubview:self.webView];
    
    if (self.urlString) {
        NSURL *remoteURL = [NSURL URLWithString:self.urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
        [self.webView loadRequest:request];
    }
    [self setupCustomNavbar];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(KLRScreenWidth - 60, KFLSTopHeight, 60, 40)];
    button.backgroundColor = [UIColor yellowColor];
    [button addTarget:self action:@selector(showDebug) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
}

- (void)showDebug {
    if ([self.view.subviews containsObject:self.textView]) {
        [self.textView removeFromSuperview];
    } else {
        self.textView = [[HHAdViewManager sharedManager] debugLogTextView];
        [self.view addSubview:self.textView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isShowNewsList = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"title"];
}

#pragma mark - Event

- (void)hh_backAction {
    __weak __typeof(self)weakSelf = self;
    NSString *js = @"clientCallCanBack()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (error) {
            [weakSelf flsClose];
        }
    }];
}

// 关闭按钮
- (void)rightButtonAction {
    __weak __typeof(self)weakSelf = self;
    NSString *js = @"clientCallCanClose()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (error) {
            [weakSelf flsClose];
        }
    }];
}

// 加载视频
- (void)loadVideo:(NSDictionary *)dict {
    [self showLoading];
    HHFlsAdModel *advertModel = [HHFlsAdModel yylr_modelWithDictionary:dict];
    [LRVideoAdProvider videoAdWithAd:advertModel delegate:self fromController:self];
}

// 获取剪切板内容
- (void)getClip:(NSString *)string {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [self passToWebWithPbString:pb.string];
}

- (void)passToWebWithPbString:(NSString *)pbString {
    if (pbString && pbString.length > 0) {
        NSString *flsClipString = [NSString stringWithFormat:@"flsClip('%@')", pbString];
        [self.webView evaluateJavaScript:flsClipString completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
            NSLog(@"");
        }];
    }
}

// 关闭当前窗口
- (void)flsClose {
    if ([HHAdViewManager sharedManager].showWithPresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 替换粘贴板内容 js调用native
- (void)clientCallPasteConChange:(NSDictionary *)dict {
    NSString *text = dict[@"con"];
    if (text) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:text];
    }
}

- (LRHomeTipController *)homeTipController {
    if (!_homeTipController) {
        _homeTipController = [[LRHomeTipController alloc] init];
        _homeTipController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return _homeTipController;
}

// 显示弹窗
- (void)flsShowSignAd:(NSDictionary *)dict {
    NSString *sendData = dict[@"sendData"];
    NSDictionary *sendDataDict = [self hh_dictionaryWithJsonString:sendData];
    self.currentSendDataString = sendData;
    self.adDetailBtnUrl = sendDataDict[@"twoLookDetailImg"];
    [self.homeTipController refreshWithParams:dict];
    self.homeTipController.sendDataString = sendData;
    if ([self.dataSource respondsToSelector:@selector(hhAnimatedViewWithUrl:)]) {
    }
    
    __weak __typeof(self)weakSelf = self;
    self.homeTipController.closeTipBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *js = [NSString stringWithFormat:@"clientCallPopupClose('%@')", sendData];
            [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                NSLog(@"----->>>>>>%@--%@", response, error);
            }];
        });

    };
    // 观看视频
    self.homeTipController.callLookVideoBlock = ^{
        if (weakSelf.isShowNewsList) {
            [weakSelf.navigationController popToViewController:weakSelf animated:YES];
        } else {
//            if ([sendDataDict[@"twoBtnPopCloseStatus"] integerValue] == 1) {
//                // 关闭弹窗
////                [weakSelf.navigationController popToViewController:weakSelf animated:NO];
//                [weakSelf.homeTipController.view removeFromSuperview];
//            }
//            // 不关闭弹窗，只隐藏视图，看完视频之后，再显示视图
//            [weakSelf.homeTipController hideViews];
            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.lookVideoAgain = YES;
                NSString *js = [NSString stringWithFormat:@"clientCallLookVideoAgain('%@')", sendData];
                [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                    NSLog(@"----->>>>>>%@--%@", response, error);
                }];
            });
        }

    };
    self.homeTipController.imgTextLaunchBlock = ^(NSString * _Nonnull status, NSString * _Nonnull sendDataS) {
        NSDictionary *clientParam = @{@"status":status, @"backMsg":@""};
        NSString *clientParamString = [weakSelf hh_stringWithJsonObj:clientParam];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *js = [NSString stringWithFormat:@"clientBackDataInfoFlowEnter('%@','%@')", sendDataS, clientParamString];
            [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                NSLog(@"----->>>>>>%@--%@", response, error);
            }];
        });
    };
//    if (![self.navigationController.viewControllers containsObject:self.homeTipController]) {
//        [self.navigationController pushViewController:self.homeTipController animated:NO];
//    }
    BOOL hasNewsList = NO;
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[HHFlsNewsListController class]]) {
            hasNewsList = YES;
            HHFlsNewsListController *newsList = (HHFlsNewsListController *)controller;
            [newsList showTaskFinishTipView:self.homeTipController.view];
            break;
        }
    }
    if (!hasNewsList) {
        if (![self.view.subviews containsObject:self.homeTipController.view]) {
            [self.view addSubview:self.homeTipController.view];
        }
    }
}

// 吊起激励视频
- (void)flsShowRewardAd:(NSDictionary *)dict {
    NSString *sendData = dict[@"sendData"];
    self.currentSendDataString = sendData;
    
    NSDictionary *configNow = dict[@"configNow"];
    if (configNow) {
        NSDictionary *adConfig = configNow[@"advertConfigAll"];
        [self loadVideo:adConfig];
    }
}

// 初始化
- (void)initFLSAd:(NSDictionary *)params {
    NSDictionary *sendConfigDict = [self hh_dictionaryWithJsonString:params[@"advertConfigInt"]];
    if (self.adConfigDict == nil) {
        self.adConfigDict = sendConfigDict;
    }
}

- (void)flsGoBackOrForward:(NSDictionary *)dict {
    if (dict) {
        NSString *step = dict[@"step"];
        NSInteger stepInt = step.integerValue;
        if (stepInt < 0) {
            for (NSInteger i=stepInt; i<0; i++) {
                if ([self.webView canGoBack]) [self.webView goBack];
            }
        } else if (stepInt > 0) {
            for (NSInteger i=stepInt; i<0; i++) {
                if ([self.webView canGoForward]) [self.webView goForward];
            }
        } else {
            [self flsClose];
        }
    } else {
        [self flsClose];
    }
}

- (void)clientCallTaskStart:(NSDictionary *)dict {
    NSDictionary *sendConfigDict = [self hh_dictionaryWithJsonString:dict[@"sendConfig"]];
    self.isShowNewsList = YES;
    __weak __typeof(self)weakSelf = self;
    HHFlsNewsListController *taskController = [[HHFlsNewsListController alloc] init];
    taskController.sendConfig = dict[@"sendConfig"];
    taskController.sendConfigDict = sendConfigDict;
    taskController.dataSource = self.dataSource;
    taskController.adConfigDict = self.adConfigDict;
    taskController.taskCallBackBlock = ^(NSString * _Nonnull sendConfig, NSString * _Nonnull sourceType) {
        NSLog(@"----=======------===----  taskCallBackBlock %@---%@", sendConfig, sourceType);

        // 从任务列表页回到当前页，调用这个方法
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *clientData = @{@"sourceType" : sourceType};
            NSString *text = [NSString stringWithFormat:@"clientCallWebviewBackClose('%@', '%@')", dict[@"sendConfig"], [weakSelf hh_stringWithJsonObj:clientData]];
            [weakSelf.webView evaluateJavaScript:text completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
                NSLog(@"----=======------===-----%@---%@---%@", text, responseObj, error);
                if (error) {
//                    [weakSelf showErrorWithMsg:error.description];
                }
            }];
        });

    };
    taskController.finishedAdTaskBlock = ^(NSString * _Nonnull sendConfig) {
        // 任务完成
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *text = [NSString stringWithFormat:@"clientBackTaskComplete('%@')", sendConfig];
            [weakSelf.webView evaluateJavaScript:text completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
                
            }];
        });

    };
    if ([sendConfigDict[@"comStatus"] integerValue] == 1) {
        // 已完成任务
        taskController.isFinished = YES;
    } else {
        taskController.isFinished = NO;
    }
    [self.navigationController pushViewController:taskController animated:YES];
}

- (void)videoCallBackWithStatus:(NSString *)status {
    NSDictionary *clientParam = @{@"status":status, @"backMsg":@""};
    NSString *clientParamString = [self hh_stringWithJsonObj:clientParam];
    NSString *js = [NSString stringWithFormat:@"clientBackDataRewardEnter('%@','%@')", self.currentSendDataString, clientParamString];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"----->>>>>>%@--%@-------%@", response, error, js);
    }];
}

// 挽留弹窗
- (void)flsShowDetainHomeTask:(NSDictionary *)params {
    self.currentSendDataString = params[@"sendData"];
    NSLog(@"----=======------===----挽留弹窗方法---%@", params[@"sendData"]);
    HHWeakSelf
    HHContinueTaskController *continueTask = [[HHContinueTaskController alloc] init];
    continueTask.continueBlock = ^{
        [weakSelf continueAction];
    };
//    continueTask.continueTaskBlock = ^(NSString * _Nonnull sendData) {
//        [weakSelf continueTaskAction:sendData];
//    };
    continueTask.finishTaskBlock = ^{
        [weakSelf finishTaskAction];
    };
//    [continueTask showStayViewWith:params adConfigDict:self.adConfigDict buttonUrl:self.adDetailBtnUrl];
    [continueTask refreshWithParams:params];
    [self.view addSubview:continueTask.view];
    [self addChildViewController:continueTask];
}

- (void)flsKsVideoFullScreen:(NSDictionary *)dict {
    [self showLoading];
//    LRLog(@"flsKsVideoFullScreen->%@", dict);
    
    NSString *sendData = dict[@"sendData"];
    self.currentSendDataString = sendData;
    
    NSDictionary *configNow = dict[@"configNow"];
    if (configNow) {
        NSDictionary *adConfig = configNow[@"advertConfigAll"];
        HHFlsAdModel *advertModel = [HHFlsAdModel yylr_modelWithDictionary:adConfig];
        [LRFullVideoAdProvider showKsAdWithAdId:advertModel delegate:self rootController:self];
    }
//    [[LRFullVideoAdManager sharedInstance] showKsAdWithAdId:@"5390000009" rootController:self.navigationController delegate:self];
}

- (void)clientCallTaskStartVersionTwo:(NSDictionary *)dict {
//    LRLog(@"clientCallTaskStartVersionTwo->%@->%@", dict, dict[@"sendConfig"]);
    HHWeakSelf
    NSDictionary *sendConfigDict = [self hh_dictionaryWithJsonString:dict[@"sendConfig"]];
    HHFlsNewsController *nc = [[HHFlsNewsController alloc] init];
    nc.sendConfig = dict[@"sendConfig"];
    nc.sendConfigDict = sendConfigDict;
    nc.taskCallBackBlock = ^(NSString * _Nonnull sendConfig, NSString * _Nonnull sourceType) {
        // 从任务列表页回到当前页，调用这个方法
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *clientData = @{@"sourceType" : sourceType};
            NSString *text = [NSString stringWithFormat:@"clientCallWebviewBackClose('%@', '%@')", dict[@"sendConfig"], [weakSelf hh_stringWithJsonObj:clientData]];
            [weakSelf.webView evaluateJavaScript:text completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
//                LRLog(@"----=======------===-----%@---%@---%@", text, responseObj, error);
            }];
        });

    };
    [self.navigationController pushViewController:nc animated:YES];
}

#pragma mark - Delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            [self hh_setupTitle:self.webView.title];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation  {
    // 拦截地图
    NSString *urlString = webView.URL.absoluteString;
    if ([urlString containsString:@"iosamap://"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id461703208?ls=1&mt=8"]];
        }
    }
}

- (NSDictionary *)hh_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
//        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)hh_stringWithJsonObj:(NSDictionary *)dict {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&err];
    if (err) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 配置
    [self.webView evaluateJavaScript:@"getConfig()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"");
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSString *orgUrlString = navigationAction.request.URL.absoluteString;
    orgUrlString = [orgUrlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *urlString = [orgUrlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 淘宝、京东、拼多多
    if ([urlString containsString:@"taobao://"] || [urlString containsString:@"openapp.jdmobile://"] || [urlString containsString:@"pinduoduo://"]) {
//        NSLog(@"-----=======-------%@", urlString);
        [self openUrl:urlString];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 微信
    if ([urlString containsString:@"weixin://"]) {
        BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
        if (!isInstalled) {
            decisionHandler(actionPolicy);
            return;
        }
        [self openUrl:urlString];
    }
    
    // 阿里
    if ([urlString containsString:@"alipay"]) {
        BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://alipayclient/?"]];
        if (!isInstalled) {
            decisionHandler(actionPolicy);
            return;
        }
        [self openUrl:urlString];
    }
    
    // 拦截地图
    if ([urlString containsString:@"https://wap.amap.com"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([urlString containsString:@"action=ali.open.nav"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)openUrl:(NSString *)urlString {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (@available(iOS 10.0,*)) {
            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        [[UIApplication sharedApplication] openURL:self.webView.URL];
    }
}

// 去意已决
- (void)finishTaskAction {
    [self removeContinueTip];
    NSString *js = @"clientCallDetainTaskGoLeaveEnter()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"----->>>>>>%@--%@-------%@", response, error, js);
    }];
}

// 继续赚钱
- (void)continueAction {
    [self removeContinueTip];
    NSString *js = @"clientCallDetainTaskGoContinueEnter()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"----->>>>>>%@--%@-------%@", response, error, js);
    }];
}

- (void)flsMoneyPopButtonFree:(NSDictionary *)dict {
//    LRLog(@"->%@", dict);
    NSString *sendData = dict[@"sendData"];
    NSDictionary *sendDataDict = [self hh_dictionaryWithJsonString:sendData];
    self.currentSendDataString = sendData;
    self.adDetailBtnUrl = sendDataDict[@"twoLookDetailImg"];
    [self.homeTipController refreshWithParams:dict];
    self.homeTipController.sendDataString = sendData;
    if ([self.dataSource respondsToSelector:@selector(hhAnimatedViewWithUrl:)]) {
    }
    
    __weak __typeof(self)weakSelf = self;
    self.homeTipController.closeTipBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *js = [NSString stringWithFormat:@"clientCallPopupClose('%@')", sendData];
            [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                NSLog(@"----->>>>>>%@--%@", response, error);
            }];
        });

    };
    // 观看视频
    self.homeTipController.callLookVideoBlock = ^{
        if ([sendDataDict[@"twoBtnPopCloseStatus"] integerValue] == 1) {
            // 关闭弹窗
            [weakSelf.homeTipController.view removeFromSuperview];
        }
//        else {
//            // 不关闭弹窗，只隐藏视图，看完视频之后，再显示视图
//            [weakSelf.homeTipController hideViews];
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.lookVideoAgain = YES;
            NSString *js = [NSString stringWithFormat:@"clientCallLookVideoAgain('%@')", sendData];
            [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                    NSLog(@"----->>>>>>%@--%@", response, error);
            }];
        });

    };
    self.homeTipController.imgTextLaunchBlock = ^(NSString * _Nonnull status, NSString * _Nonnull sendDataS) {
        NSDictionary *clientParam = @{@"status":status, @"backMsg":@""};
        NSString *clientParamString = [weakSelf hh_stringWithJsonObj:clientParam];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *js = [NSString stringWithFormat:@"clientBackDataInfoFlowEnter('%@','%@')", sendDataS, clientParamString];
            [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                NSLog(@"----->>>>>>%@--%@", response, error);
            }];
        });
    };
    BOOL hasNewsList = NO;
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[HHFlsNewsListController class]]) {
            hasNewsList = YES;
            HHFlsNewsListController *newsList = (HHFlsNewsListController *)controller;
            [newsList showTaskFinishTipView:self.homeTipController.view];
            break;
        }
    }
    if (!hasNewsList) {
        if (![self.view.subviews containsObject:self.homeTipController.view]) {
            [self.view addSubview:self.homeTipController.view];
        }
    }
}

// 微信分享 是否可以分享
- (void)flsGetWxShare:(NSDictionary *)dict {
    LRShareWxStatus shareStatus = LRShareWxStatusCantOpen;
    if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(lrShareWxStatus)]) {
        shareStatus = [self.shareDelegate lrShareWxStatus];
    }
    
    NSString *sendConfigString = dict[@"sendConfig"];
//    LRLog(@"flsGetWxShare---->>>>>%@--%@", dict, sendConfigString);
    
    NSDictionary *clientData = @{@"status":@(shareStatus)};
    NSString *shareScript = [NSString stringWithFormat:@"clientCallWxShareBack('%@', '%@')", sendConfigString, [clientData yylr_modelToJSONString]];
    [self.webView evaluateJavaScript:shareScript completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
//        LRLog(@"clientCallWxShareBack---->>>>>%@--%@--%@", shareScript, responseObj, error);
    }];
}

// 有微信分享功能的微信分享
- (void)flsWxShareCall:(NSDictionary *)dict {
    if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(lrShareToWxWithInfo:)]) {
        NSDictionary *sendConfigDict = [self hh_dictionaryWithJsonString:dict[@"sendConfig"]];
        [self.shareDelegate lrShareToWxWithInfo:sendConfigDict];
    }
}

// 没有微信分享功能的分享
- (void)flsWxAppCall:(NSDictionary *)dict {
    if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(lrOpenWxToShare)]) {
        [self.shareDelegate lrOpenWxToShare];
    }
}

- (void)removeContinueTip {
    for (UIView *view in self.view.subviews) {
        if (view.tag == 100) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Getter

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"initFLSAd"];
        [wkUController addScriptMessageHandler:self name:@"flsClose"];
        [wkUController addScriptMessageHandler:self name:@"flsGoBackOrForward"];
        [wkUController addScriptMessageHandler:self name:@"getClip"];
        [wkUController addScriptMessageHandler:self name:@"clientCallPasteConChange"];
        [wkUController addScriptMessageHandler:self name:@"flsShowRewardAd"];
        [wkUController addScriptMessageHandler:self name:@"clientCallTaskStart"];
        [wkUController addScriptMessageHandler:self name:@"flsShowDetainHomeTask"];
        [wkUController addScriptMessageHandler:self name:@"flsKsVideoFullScreen"];
        [wkUController addScriptMessageHandler:self name:@"clientCallTaskStartVersionTwo"];
        [wkUController addScriptMessageHandler:self name:@"flsMoneyPopButtonFree"];
        [wkUController addScriptMessageHandler:self name:@"flsGetWxShare"];
        [wkUController addScriptMessageHandler:self name:@"flsWxShareCall"];
        [wkUController addScriptMessageHandler:self name:@"flsWxAppCall"];

        config.userContentController = wkUController;
        config.processPool = [WKProcessPool sharedProcessPool];

        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.javaScriptEnabled = YES;
        config.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, KFLSTopHeight, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight) configuration:config];
        _webView.navigationDelegate = self;
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self.webView reload];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *parameter = message.body;
    NSLog(@"----=======------===----%@, %@", message.name, message.body);
    if([message.name isEqualToString:@"initFLSAd"]){
        [self initFLSAd:parameter];
    } else if ([message.name isEqualToString:@"flsClose"]) {
        [self flsClose];
    } else if ([message.name isEqualToString:@"flsGoBackOrForward"]) {
        [self flsGoBackOrForward:parameter];
    } else if ([message.name isEqualToString:@"getClip"]) {
        NSString *clipString = (NSString *)parameter;
        [self getClip:clipString];
    } else if ([message.name isEqualToString:@"clientCallPasteConChange"]) {
        [self clientCallPasteConChange:parameter];
    } else if ([message.name isEqualToString:@"flsShowRewardAd"]) {
        [self flsShowRewardAd:parameter];
//    } else if ([message.name isEqualToString:@"flsShowSignAd"]) {
//        [self flsShowSignAd:parameter];
    } else if ([message.name isEqualToString:@"clientCallTaskStart"]) {
        [self clientCallTaskStart:parameter];
    } else if ([message.name isEqualToString:@"flsShowDetainHomeTask"]) {
        [self flsShowDetainHomeTask:parameter];
    } else if ([message.name isEqualToString:@"flsKsVideoFullScreen"]) {
        [self flsKsVideoFullScreen:parameter];
    } else if ([message.name isEqualToString:@"clientCallTaskStartVersionTwo"]) {
        [self clientCallTaskStartVersionTwo:parameter];
    } else if ([message.name isEqualToString:@"flsMoneyPopButtonFree"]) {
        [self flsMoneyPopButtonFree:parameter];
    } else if ([message.name isEqualToString:@"flsGetWxShare"]) {
        // H5获取是否能微信分享
        [self flsGetWxShare:parameter];
    } else if ([message.name isEqualToString:@"flsWxShareCall"]) {
        // 有微信分享功能，分享到微信
        [self flsWxShareCall:parameter];
    } else if ([message.name isEqualToString:@"flsWxAppCall"]) {
        // 无微信分享，能唤起微信
        [self flsWxAppCall:parameter];
    }
}

#pragma mark - Full Screen Video Delegate

/// 视频出现
- (void)lrFullscreenVideoAdDidVisible:(LRAdModel *)adModel {
    
}

- (void)lrFullscreenVideoAdVideoDidLoad:(LRAdModel *)adModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
    });
}

- (void)lrFullscreenVideoAdLoadFailed:(LRAdModel *)adModel error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self videoCallBackWithStatus:@"fail"];
        [self hideLoadingWithError:error];
    });
}

- (void)lrFullscreenVideoAdDidClose:(LRAdModel *)adModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self videoCallBackWithStatus:@"success"];
    });
}

- (void)lrFullscreenVideoAdDidLoad:(LRAdModel *)adModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
    });
}

#pragma mark - Video Delegate

- (void)lrRewardedVideoAdDidLoad:(LRAdModel *)adModel {
    [self hideLoading];
}

- (void)lrRewardedVideoAd:(LRAdModel *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self videoCallBackWithStatus:@"fail"];
    [self hideLoadingWithError:error];
}

/**
 广告已出现
 */
- (void)lrRewardedVideoAdDidVisible:(LRAdModel *)rewardedVideoAd {
    if ([self.view.subviews containsObject:self.homeTipController.view]) {
        [self.homeTipController.view removeFromSuperview];
        self.homeTipController = nil;
    }
}

/**
 广告已关闭
 */
- (void)lrRewardedVideoAdDidClose:(LRAdModel *)rewardedVideoAd {
    [self videoCallBackWithStatus:@"success"];
}

/**
 点击跳过按钮
 */
- (void)lrRewardedVideoAdDidClickSkip:(LRAdModel *)rewardedVideoAd {
    
}

/**
 视频播放完毕
 */
- (void)lrRewardedVideoAdDidPlayFinish:(LRAdModel *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    
}

/**
 视频广告无效
 */
- (void)lrRewardedVideoAdLoseEffectiveness {
    
}

/**
 视频广告播放达到激励条件
 */
- (void)lrRewardVideoAdDidRewardEffective:(BOOL)hasReward {
    
}

@end
 
