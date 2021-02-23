//
//  HHFlsNewsWebController.m
//  importevent
//
//  新闻内容
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsNewsWebController.h"
#import "LRHomeTipController.h"
#import "WKProcessPool+FlsSharedProcessPool.h"
#import "HHFlsNewsCell.h"
#import "HHFlsNewsImgsCell.h"

#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "HHAdViewManager.h"
#import "LRTaskFinishTipController.h"

#import "LRInfoFlowAdProvider.h"
#import "LRInfoFlowView.h"

@interface HHFlsNewsWebController () <WKNavigationDelegate, WKScriptMessageHandler, LRInfoFlowAdDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebView *tmpWebView;
@property (nonatomic, copy) NSString *currentSendDataString;    // 当前sendData

@property (nonatomic, strong) UIView *circleBgView;
@property (nonatomic, strong) UIView *progressBgView;
@property (nonatomic, strong) UIView *redProgressView;
@property (nonatomic, strong) UIImageView *coinView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGFloat timeMin;        // 最小浏览时长（秒）
@property (nonatomic, assign) CGFloat currentAngle;     // 当前圆弧
@property (nonatomic, assign) CGFloat secondAngle;      // 一秒对应的圆弧
@property (nonatomic, assign) NSInteger currentTaskCount;   // 未展示进度的任务
@property (nonatomic, assign) BOOL isArticleShow;       // 当前正在展示新闻
@property (nonatomic, strong) NSTimer *timer;           // 倒计时 计时器
@property (nonatomic, strong) NSTimer *refreshAdTimer;           // 倒计时 计时器
@property (nonatomic, assign) NSInteger timeCounter;    // 计时器

@property (nonatomic, strong) UIImageView *redTipView;
@property (nonatomic, strong) UILabel *redTipLabel;
@property (nonatomic, strong) LRTaskFinishTipController *tipController;

@property (nonatomic, strong) NSDictionary *bottomAdConfig;
@property (nonatomic, strong) HHFlsAdModel *advertModel;
@property (nonatomic, assign) BOOL isShowingTip;    // 正在展示完成任务弹窗

@end

@implementation HHFlsNewsWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KLRColorWhite;
    [self setupLeftButton];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.tmpWebView];
    
    [self setupCustomNavbarWithLine];
    [self hh_setupTitle:self.title];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    NSURL *remoteURL = [NSURL URLWithString:@"https://lrqd.wasair.com/advert/task/con/transition"]; // 正式
    if ([HHAdViewManager sharedManager].isDevelop) {
        remoteURL = [NSURL URLWithString:@"http://sandbox.lrqd.wasair.com/advert/task/con/transition"]; // 测试
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
    [self.tmpWebView loadRequest:request];
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.refreshAdTimer) {
        [self.refreshAdTimer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    if (self.taskCallBackBlock && self.finishedSendConfig) {
//        self.taskCallBackBlock(self.finishedSendConfig, self.sourceType);
//    } else if (self.taskCallBackBlock && self.sourceType) {
//        self.taskCallBackBlock(self.sendConfig, self.sourceType);
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.refreshAdTimer) {
        [self.refreshAdTimer invalidate];
        self.refreshAdTimer = nil;
    }
}

#pragma mark - Event

- (void)hh_backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    _webView = nil;
    
    NSURL *remoteURL = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
    [self.webView loadRequest:request];
}

- (void)setupLeftButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"FulisheAdBundle.bundle/nav_back_dark"] forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    [button addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barItem;
}

// 返回按钮
- (void)leftButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
        LRLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)hh_stringWithJsonObj:(NSDictionary *)dict {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    // 配置
//    NSString *text = [NSString stringWithFormat:@"clientBackTaskConMore('%@')", self.sendConfig];
//    NSString *s = [[NSString alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
//    NSString *ss = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [self.webView evaluateJavaScript:text completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        LRLog(@"");
//    }];
    if (webView == self.tmpWebView) {
        // 获取配置详情
        NSDictionary *dict = @{@"cid":self.cid?:@"", @"aid":self.aid?:@""};
        NSString *text = [NSString stringWithFormat:@"clientCallTaskNewsDetail('%@')", [dict lr_stringWithJsonObj:dict]];
        [self.tmpWebView evaluateJavaScript:text completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
//                LRLog(@"evaluateJavaScript--%@--%@--%@", text, responseObj, error);
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }  else {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {

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

#pragma mark - Getter

- (LRTaskFinishTipController *)tipController {
    if (!_tipController) {
        HHWeakSelf
        _tipController = [[LRTaskFinishTipController alloc] init];
        _tipController.modalPresentationStyle = UIModalPresentationCustom;
        _tipController.closeTipBlock = ^{
            weakSelf.isShowingTip = NO;
        };
    }
    return _tipController;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"flsBackNewsList"];

        config.userContentController = wkUController;
        config.processPool = [WKProcessPool sharedProcessPool];

        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, KFLSTopHeight, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight) configuration:config];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (WKWebView *)tmpWebView {
    if (!_tmpWebView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"flsTaskNewsDetail"];
        [wkUController addScriptMessageHandler:self name:@"flsMoneyPopNoButton"];
        
        config.userContentController = wkUController;
        config.processPool = [WKProcessPool sharedProcessPool];

        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preferences;
        
        _tmpWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) configuration:config];
        _tmpWebView.navigationDelegate = self;
    }
    return _tmpWebView;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *parameter = message.body;
    if ([message.name isEqualToString:@"flsTaskNewsDetail"]) {
        [self flsTaskNewsDetail:parameter];
    } else if ([message.name isEqualToString:@"flsMoneyPopNoButton"]) {
        [self flsMoneyPopNoButton:parameter];
    } else if ([message.name isEqualToString:@"flsBackNewsList"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 任务完成弹窗
- (void)flsMoneyPopNoButton:(NSDictionary *)dict {
    self.isShowingTip = YES;
    NSString *sendData = dict[@"sendData"];
//    NSDictionary *sendDataDict = [self lr_dictionaryWithJsonString:sendData];
    self.sendConfig = sendData;
//    self.finishedSendConfig = sendData;
    
    [self.tipController refreshWithParams:dict];
    self.tipController.sendDataString = sendData;
    if (![self.view.subviews containsObject:self.tipController.view]) {
        [self.view addSubview:self.tipController.view];
    }
}

// 新闻任务相关配置
- (void)flsTaskNewsDetail:(NSDictionary *)dict {
    NSString *sendConfigString = dict[@"sendConfig"];
    self.bottomAdConfig = [self lr_dictionaryWithJsonString:sendConfigString];
    
    // 提示信息
    [self.view addSubview:self.redTipView];
    NSString *showMsg = self.bottomAdConfig[@"showMsg"];
    self.redTipLabel.text = showMsg;

    NSInteger ingStatus = [self.bottomAdConfig[@"ingStatus"] integerValue];
    if (ingStatus == 0) {
        // 未完成, 倒计时时间
        NSString *rewardTime = self.bottomAdConfig[@"rewardTime"];
        self.timeMin = rewardTime.floatValue*10.0;
        self.timeCounter = 0;
        self.currentTaskCount = 0;
        self.currentAngle = kDegreesToRadians(270);
        self.secondAngle = 360.0/self.timeMin;
        [self setupTimer];
    } else if (ingStatus == 1) {
        // 已完成
        self.isFinished = YES;
        [self showRedTip];
    } else if (ingStatus == 2) {
        // 已达到最大次数
        self.isFinished = YES;
        [self showRedTip];
    } else {
        [self hideRedTip];
    }
    [self.view addSubview:self.circleBgView];
    [self setupBottomAd];
}

- (void)setupBottomAd {
    NSString *advertChangeTIme = self.bottomAdConfig[@"advertChangeTIme"];
    NSString *showAdvert = self.bottomAdConfig[@"showAdvert"];
    if (showAdvert.boolValue) {
        NSDictionary *adConfigDict = self.bottomAdConfig[@"advertConfigAll"];
        self.advertModel = [HHFlsAdModel yylr_modelWithDictionary:adConfigDict];
        self.advertModel.tmpSort = [self.advertModel.sort mutableCopy];
        [LRInfoFlowAdProvider infoFlowAdWithAd:self.advertModel delegate:self adViewSize:CGSizeMake(KLRScreenWidth, 60) adCount:1 fromController:self];
        [self setupRefreshTimer:advertChangeTIme.floatValue];
    }
}

- (UIView *)circleBgView {
    if (!_circleBgView) {
        CGFloat width = 55*KFLSDeviceWidthScale;
        _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(KLRScreenWidth - 15 - width, self.redTipView.lr_bottom, width, width)];
        _circleBgView.backgroundColor = KLRColorWhite;
        _circleBgView.layer.cornerRadius = width/2;
        _circleBgView.layer.borderWidth = 0.5;
        _circleBgView.layer.borderColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1].CGColor;
        [_circleBgView addSubview:self.progressBgView];
        [_circleBgView addSubview:self.redProgressView];
        [_circleBgView addSubview:self.coinView];
    }
    return _circleBgView;
}

- (UIView *)progressBgView {
    if (!_progressBgView) {
        CGFloat width = 47*KFLSDeviceWidthScale;
        _progressBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _progressBgView.center = CGPointMake(_circleBgView.lr_width/2, _circleBgView.lr_width/2);
        _progressBgView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
        _progressBgView.layer.cornerRadius = width/2;
        _progressBgView.layer.masksToBounds = YES;
    }
    return _progressBgView;
}

- (UIView *)redProgressView {
    if (!_redProgressView) {
        CGFloat width = 47*KFLSDeviceWidthScale;
        _redProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _redProgressView.center = CGPointMake(_circleBgView.lr_width/2, _circleBgView.lr_width/2);
        _redProgressView.layer.cornerRadius = width/2;
        _redProgressView.layer.masksToBounds = YES;

        UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width startAngle:kDegreesToRadians(270) endAngle:kDegreesToRadians(270) clockwise:YES];
        if (self.isFinished) {
            bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width startAngle:kDegreesToRadians(270) endAngle:kDegreesToRadians(630) clockwise:YES];
        }
        [bezPath addLineToPoint:CGPointMake(width/2, width/2)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = _redProgressView.bounds;
        shapeLayer.fillColor = [UIColor colorWithRed:225.0/255.0 green:60.0/255.0 blue:39.0/255.0 alpha:1].CGColor;
        shapeLayer.path  = bezPath.CGPath;
        [_redProgressView.layer addSublayer:shapeLayer];
        _shapeLayer = shapeLayer;
    }
    return _redProgressView;
}

- (void)itemViewWithStart:(CGFloat)starAngle end:(CGFloat)endAngle {
    CGFloat width = _redProgressView.lr_width;
    UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width/2 startAngle:kDegreesToRadians(270) endAngle:endAngle clockwise:YES];
   [bezPath addLineToPoint:CGPointMake(width/2, width/2)];
   _shapeLayer.path = bezPath.CGPath;
}

- (UIImageView *)coinView {
    if (!_coinView) {
        CGFloat width = _progressBgView.lr_width - 7;
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/test_circle_coin"];
        _coinView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _coinView.center = CGPointMake(_circleBgView.lr_width/2, _circleBgView.lr_width/2);
        _coinView.image = image;
    }
    return _coinView;
}

- (void)setupTimer {
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)setupRefreshTimer:(CGFloat)timeInterval {
    self.refreshAdTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(refreshBottomAdvert) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.refreshAdTimer forMode:NSRunLoopCommonModes];
}

- (void)refreshBottomAdvert {
    if (!self.isShowingTip) {
        [LRInfoFlowAdProvider infoFlowAdWithAd:self.advertModel delegate:self adViewSize:CGSizeMake(KLRScreenWidth, 60) adCount:1 fromController:self];
    }
}

- (void)appDidEnterBackground:(NSNotification *)notify {
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.refreshAdTimer setFireDate:[NSDate distantFuture]];
}

- (void)appDidBecomeActive:(NSNotification *)notify {
    [self.timer setFireDate:[NSDate date]];
    [self.refreshAdTimer setFireDate:[NSDate date]];
}

- (void)timeChange {
    self.timeCounter++;
    [self refreshProgressView];
    if (self.timeCounter >= self.timeMin) {
        [self checkTaskState];
    }
}

// 检查任务状态
- (void)checkTaskState {
    if (self.isFinished) {
        return;
    }
    if (self.timeCounter >= self.timeMin) { // 任务完成
        self.isFinished = YES;
        [self.timer invalidate];
        self.timer = nil;

        NSDictionary *dict = @{@"cid":self.cid?:@"", @"aid":self.aid?:@""};
        NSString *text = [NSString stringWithFormat:@"clientBackTaskComplete('%@','%@')", self.sendConfig, [dict lr_stringWithJsonObj:dict]];
        [self.tmpWebView evaluateJavaScript:text completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
        }];
//        if (self.finishedAdTaskBlock) {
//            self.finishedAdTaskBlock(self.sendConfig);
//        }
    }
}

- (void)refreshProgressView {
    CGFloat plusAngle = self.secondAngle*M_PI/180.0;
    [self itemViewWithStart:self.currentAngle end:self.currentAngle+plusAngle];
    self.currentTaskCount = 0;
    self.currentAngle += plusAngle;
}

- (UIImageView *)redTipView {
    if (!_redTipView) {
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/test_red_tip_bg"];
        _redTipView = [[UIImageView alloc] initWithImage:image];
        CGFloat positionY = KLRScreenHeight/4*3;
        _redTipView.frame = CGRectMake(KLRScreenWidth, positionY, image.size.width, image.size.height);
        [_redTipView addSubview:self.redTipLabel];
    }
    return _redTipView;
}

- (UILabel *)redTipLabel {
    if (!_redTipLabel) {
        _redTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _redTipView.lr_width - 30, _redTipView.lr_height - 6)];
        _redTipLabel.textColor = KLRColorWhite;
        _redTipLabel.font = [UIFont systemFontOfSize:11];
    }
    return _redTipLabel;
}

- (void)startTimer {
    [self.timer setFireDate:[NSDate date]];
}

- (void)stopTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)showRedTip {
    [UIView animateWithDuration:0.25 animations:^{
        self.redTipView.lr_right = self.circleBgView.lr_right;
    }];
}

- (void)hideRedTip {
    [UIView animateWithDuration:0.25 animations:^{
        self.redTipView.lr_left = KLRScreenWidth;
    }];
}

#pragma mark - Ad Delegate

- (void)lrNativeExpressAdSuccessToLoad:(LRAdModel *)adModel {
    UIView *adView = [self.view viewWithTag:101];
    UIView *lineView = [self.view viewWithTag:102];
    if (adView) {
        [adView removeFromSuperview];
    }
    if (lineView) {
        [lineView removeFromSuperview];
    }
    
    if (adModel.adView) {
          
    } else if (adModel.adViewArray && adModel.adViewArray.count > 0) {
        NSArray *adViewArray = adModel.adViewArray;
        LRInfoFlowView *adView = adViewArray[0];
        if (adView.canRegisterClickableSmallViews) {
            [adView registerSmallClickableViews:@[]];
        }
        CGRect frame = adView.frame;
        frame.origin.y = KLRScreenHeight - 60 - KFLSBottomOffset;
        adView.frame = frame;
        adView.tag = 101;
        
        UIImage *shadowImage = [UIImage imageNamed:@"FulisheAdBundle.bundle/lr_shadow_line"];
        UIImageView *shadowLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, adView.lr_top - 2, adView.lr_width, 2)];
        shadowLine.image = shadowImage;
        shadowLine.tag = 102;
        
        if ([self.view.subviews containsObject:self.tipController.view]) {
            [self.view insertSubview:adView belowSubview:self.tipController.view];
            [self.view insertSubview:shadowLine belowSubview:self.tipController.view];
        } else {
            [self.view addSubview:adView];
            [self.view addSubview:shadowLine];
        }

        self.webView.lr_height = KLRScreenHeight - KFLSTopHeight - 60 - KFLSBottomOffset;
    }
}

@end
