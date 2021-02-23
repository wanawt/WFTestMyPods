//
//  HHFlsNewsListController.m
//  importevent
//
//  新闻列表
//
//  Created by 张维凡 on 2020/11/4.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsNewsListController.h"
#import "LRHomeTipController.h"
#import "HHFlsNewsWebController.h"
#import "HHFlsTaskTipController.h"

#import "WKProcessPool+FlsSharedProcessPool.h"
#import "HHFlsNewsCell.h"
#import "HHFlsNewsImgsCell.h"
#import "HHFlsAdCell.h"

#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "HHAdViewManager.h"
#import "YYLRModel.h"
#import "GDTSDKConfig.h"
#import "GDTUnifiedNativeAd.h"

@interface HHFlsNewsListController () <WKNavigationDelegate, WKScriptMessageHandler, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, GDTUnifiedNativeAdDelegate> 

@property (nonatomic, strong) HHFlsNewsWebController *webController;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *adDataArray;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *yellowView;
@property (nonatomic, strong) UILabel *yellowLabel;

@property (nonatomic, strong) UIView *circleBgView;
@property (nonatomic, strong) UIView *progressBgView;
@property (nonatomic, strong) UIView *redProgressView;
@property (nonatomic, strong) UIImageView *coinView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, assign) NSInteger numNews;        // 最少浏览新闻条数
@property (nonatomic, assign) NSInteger numAdvert;      // 最少浏览广告条数
@property (nonatomic, assign) CGFloat timeMin;        // 最小浏览时长（秒）
@property (nonatomic, assign) NSInteger totalTaskCount; // numNews+numAdvert
@property (nonatomic, assign) CGFloat currentAngle;     // 当前圆弧
@property (nonatomic, assign) CGFloat taskAngle;        // 一个任务对应的圆弧
@property (nonatomic, assign) CGFloat secondAngle;      // 一秒对应的圆弧
@property (nonatomic, assign) NSInteger currentTaskCount;   // 未展示进度的任务
@property (nonatomic, assign) BOOL isArticleShow;       // 当前正在展示新闻
@property (nonatomic, assign) BOOL isLaunchingMore;     // 正在加载更多
@property (nonatomic, strong) NSTimer *timer;           // 倒计时 计时器
@property (nonatomic, strong) NSTimer *tipTimer;        // 红色提示视图 计时器
@property (nonatomic, assign) NSInteger timeCounter;    // 计时器
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, strong) UIImageView *redTipView;
@property (nonatomic, strong) UILabel *redTipLabel;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) LRHomeTipController *homeTipController;
@property (nonatomic, copy) NSString *finishedSendConfig;
@property (nonatomic, assign) BOOL isLoadingAdModel;  // 正在拉取广告model
@property (nonatomic, copy) NSString *sourceType;

@end

@implementation HHFlsNewsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.sendConfigDict[@"taskTitle"]?:@"";
    [self hh_setupTitle:title];

    self.timeCounter = 0;
    self.currentTaskCount = 0;
//    self.numNews = [self.sendConfigDict[@"numNews"] integerValue];
    self.numNews = 0;
    self.numAdvert = 1;
//    self.timeMin = [self.sendConfigDict[@"timeMin"] integerValue];
    self.timeMin = 30.0*10.0;
    self.totalTaskCount = self.numNews + self.numAdvert;
    self.currentAngle = kDegreesToRadians(270);
    self.taskAngle = 90.0/self.totalTaskCount;
    self.secondAngle = 270.0/self.timeMin;
//    NSLog(@"--------------------=============  %@   %@  %@", @(self.numNews), @(self.numAdvert), @(self.timeMin));
    self.view.backgroundColor = KLRColorWhite;
    [self.view addSubview:self.yellowView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.redTipView];
    [self.view addSubview:self.circleBgView];
    [self setupTimer];
    [self setupCustomNavbar];
    
    NSURL *remoteURL = [NSURL URLWithString:@"https://lrqd.wasair.com/advert/task/con/transition"]; // 正式
    if ([HHAdViewManager sharedManager].isDevelop) {
        remoteURL = [NSURL URLWithString:@"http://sandbox.lrqd.wasair.com/advert/task/con/transition"]; // 测试
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
    [self.webView loadRequest:request];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.taskCallBackBlock && self.finishedSendConfig) {
        self.taskCallBackBlock(self.finishedSendConfig, self.sourceType);
    } else if (self.taskCallBackBlock && self.sourceType) {
        self.taskCallBackBlock(self.sendConfig, self.sourceType);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)appDidEnterBackground:(NSNotification *)notify {
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.tipTimer setFireDate:[NSDate distantFuture]];
}

- (void)appDidBecomeActive:(NSNotification *)notify {
    [self.timer setFireDate:[NSDate date]];
    [self.tipTimer setFireDate:[NSDate date]];
}

#pragma mark - Getter

- (void)setupTimer {
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantFuture]];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    [self startTipTimer];
}

- (void)resetTipTimer {
    [self stopTipTimer];
    [self startTipTimer];
}

- (void)stopTipTimer {
    [self.tipTimer invalidate];
    self.tipTimer = nil;
}

- (void)startTipTimer {
    self.tipTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(showRedTip) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.tipTimer forMode:NSDefaultRunLoopMode];
}

- (void)showRedTip {
    if (!self.isScrolling) {
        [UIView animateWithDuration:0.25 animations:^{
            self.redTipView.lr_left = self.circleBgView.lr_left + self.circleBgView.lr_width/2 - self.redTipView.lr_width;
        }];
    }
}

- (void)hideRedTip {
    [UIView animateWithDuration:0.25 animations:^{
        self.redTipView.lr_left = KLRScreenWidth;
    }];
}

- (UIView *)yellowView {
    if (!_yellowView) {
        _yellowView = [[UIView alloc] initWithFrame:CGRectMake(0, KFLSTopHeight, KLRScreenWidth, 30)];
        _yellowView.backgroundColor = FLSRGBValue(0xDD504A);
        [_yellowView addSubview:self.yellowLabel];
    }
    return _yellowView;
}

- (UILabel *)yellowLabel {
    if (!_yellowLabel) {
        _yellowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, KLRScreenWidth-30, 30)];
        _yellowLabel.font = [UIFont systemFontOfSize:12];
        _yellowLabel.textAlignment = NSTextAlignmentCenter;
        _yellowLabel.textColor = FLSRGBValue(0xffffff);
        _yellowLabel.text = self.sendConfigDict[@"topDes"];
    }
    return _yellowLabel;
}

- (UIImageView *)redTipView {
    if (!_redTipView) {
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/test_red_tip_bg"];
        _redTipView = [[UIImageView alloc] initWithImage:image];
        CGFloat positionY = self.circleBgView.lr_top+(self.circleBgView.lr_height - image.size.height)/2;
        _redTipView.frame = CGRectMake(KLRScreenWidth, positionY, image.size.width, image.size.height);
        [_redTipView addSubview:self.redTipLabel];
    }
    return _redTipView;
}

- (UILabel *)redTipLabel {
    if (!_redTipLabel) {
        _redTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _redTipView.lr_width - 30, _redTipView.lr_height)];
        _redTipLabel.textColor = KLRColorWhite;
        _redTipLabel.font = [UIFont systemFontOfSize:11];
        _redTipLabel.text = @"请继续滑动完成任务";
    }
    return _redTipLabel;
}

#pragma mark - Event

- (void)showTaskFinishTipView:(UIView *)view {
    [self.view addSubview:view];
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
    if (self.numAdvert == 0 && self.numNews == 0 && self.timeCounter >= self.timeMin) { // 任务完成
        self.isFinished = YES;
        [self.timer invalidate];
        self.timer = nil;

        NSString *text = [NSString stringWithFormat:@"clientBackTaskComplete('%@')", self.sendConfig];
        [self.webView evaluateJavaScript:text completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
//            NSLog(@"evaluateJavaScript--%@--%@", responseObj, error);
        }];
//        if (self.finishedAdTaskBlock) {
//            self.finishedAdTaskBlock(self.sendConfig);
//        }
    }
}

// 返回按钮
- (void)hh_backAction {
    if (self.isArticleShow) {
        self.isArticleShow = NO;
        [self.webController.view removeFromSuperview];
    } else {
        if (self.isFinished) {
            self.sourceType = @"sdkGoBack";
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // 挽留弹窗
            __weak __typeof(self)weakSelf = self;
            HHFlsTaskTipController *taskTipController = [[HHFlsTaskTipController alloc] init];
            taskTipController.modalPresentationStyle = UIModalPresentationCustom;
            taskTipController.withdrawTaskBlock = ^{
                weakSelf.sourceType = @"sdkGoLeave";
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            [self presentViewController:taskTipController animated:NO completion:^{}];
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

- (void)clientCallTaskStart:(NSDictionary *)dict {
    self.isLaunchingMore = NO;
    self.sendConfig = dict[@"sendConfig"];
    self.sendConfigDict = [self hh_dictionaryWithJsonString:self.sendConfig];

    NSArray *newsDatas = dict[@"newsDatas"];
    NSLog(@"----------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>%@", newsDatas);
    [self refreshWithDatas:newsDatas];
}

- (void)refreshWithDatas:(NSArray *)array {
    for (NSDictionary *dict in array) {
        NSMutableDictionary *tmpDict = [dict mutableCopy];
        [tmpDict setObject:@(NO) forKey:@"selected"];
        HHFlsNewsModel *model = [HHFlsNewsModel yylr_modelWithDictionary:tmpDict];
        NSLog(@"111----------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>%@", tmpDict);
        if (model == nil) {
            model = [[HHFlsNewsModel alloc] init];
        }
        if ([model.type isEqualToString:@"advert"]) {
            [self.adDataArray addObject:model];
        }
        [self.dataArray addObject:model];
    }
    [self.tableView reloadData];
    [self refreshAdModel];
}

- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> * _Nullable)unifiedNativeAdDataObjects error:(NSError * _Nullable)error {
    NSMutableArray *tmpArray = [unifiedNativeAdDataObjects mutableCopy];
    for (HHFlsNewsModel *model in self.adDataArray) {
        if (model.adModel == nil && tmpArray.count > 0) {
            model.adModel = [tmpArray lastObject];
            [tmpArray removeLastObject];
        }
    }
    self.isLoadingAdModel = NO;
    [self.tableView reloadData];
}

- (void)refreshAdModel {
    // 计算空admodel数量
    NSInteger emptyAdModelCount = 0;
    for (HHFlsNewsModel *model in self.adDataArray) {
        if (model.adModel == nil) {
            emptyAdModelCount += 1;
        }
    }
    NSDictionary *gdtDict = self.adConfigDict[@"gdt"];
    NSDictionary *configFlow = gdtDict[@"configFlow"];
    NSLog(@"-------=====-----====%@----%@", gdtDict.description, configFlow[@"advertId"]);
    if (emptyAdModelCount > 0 && !self.isLoadingAdModel) {
        self.isLoadingAdModel = YES;
        // 拉取 ad
        GDTUnifiedNativeAd *gdtAd = [[GDTUnifiedNativeAd alloc] initWithPlacementId:configFlow[@"advertId"]];
        gdtAd.delegate = self;
        [gdtAd loadAdWithAdCount:emptyAdModelCount];
    }
}

#pragma mark - Delegate

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

- (NSString *)hh_stringWithJsonObj:(NSDictionary *)dict {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 配置
    NSString *text = [NSString stringWithFormat:@"clientBackTaskConMore('%@')", self.sendConfig];
    [self.webView evaluateJavaScript:text completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"");
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)openUrl:(NSString *)urlString {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (@available(iOS 10.0,*)) {
            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        [[UIApplication sharedApplication] openURL:self.webView.URL options:@{} completionHandler:nil];
    }
}

- (void)showArticle:(HHFlsNewsModel *)model {
    self.isArticleShow = YES;
    self.webController.urlString = model.url;
    self.webController.view.lr_top = self.yellowView.lr_bottom;
    [self.view insertSubview:self.webController.view belowSubview:self.circleBgView];
    [self.view insertSubview:self.webController.view belowSubview:self.redTipView];
}

- (void)refreshProgressView {
    CGFloat plusAngle = self.secondAngle*M_PI/180.0 + self.currentTaskCount*self.taskAngle*M_PI/180.0;
    if (self.timeCounter > self.timeMin) {
        plusAngle = self.currentTaskCount*self.taskAngle*M_PI/180.0;
    }
    [self itemViewWithStart:self.currentAngle end:self.currentAngle+plusAngle];
    self.currentTaskCount = 0;
    self.currentAngle += plusAngle;
}

// 显示弹窗
- (void)flsShowSignAd:(NSDictionary *)dict {
    NSString *sendData = dict[@"sendData"];
    NSDictionary *sendDataDict = [self hh_dictionaryWithJsonString:sendData];
    self.sendConfig = sendData;
    self.finishedSendConfig = sendData;

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
        weakSelf.sourceType = @"continue";
        [weakSelf.navigationController popViewControllerAnimated:YES];
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

    if (![self.view.subviews containsObject:self.homeTipController.view]) {
        [self.view addSubview:self.homeTipController.view];
    }
}

#pragma mark - Getter

- (LRHomeTipController *)homeTipController {
    if (!_homeTipController) {
        _homeTipController = [[LRHomeTipController alloc] init];
        _homeTipController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return _homeTipController;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"clientCallTaskStart"];   // 唤起任务内容
        [wkUController addScriptMessageHandler:self name:@"flsShowSignAd"];
        config.userContentController = wkUController;
        config.processPool = [WKProcessPool sharedProcessPool];

        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preferences;

        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0.1, 0.1) configuration:config];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *parameter = message.body;
    if([message.name isEqualToString:@"clientCallTaskStart"]){//点击按钮执行的方法
        [self clientCallTaskStart:parameter];
    } else if ([message.name isEqualToString:@"flsShowSignAd"]) {
        [self flsShowSignAd:parameter];
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yellowView.lr_bottom, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight - self.yellowView.lr_height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)adDataArray {
    if (!_adDataArray) {
        _adDataArray = [NSMutableArray array];
    }
    return _adDataArray;
}

- (UIView *)circleBgView {
    if (!_circleBgView) {
        CGFloat width = 55*KFLSDeviceWidthScale;
        _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(KLRScreenWidth - 15 - width, (KLRScreenHeight - KFLSTopHeight)/3*2, width, width)];
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

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 30)];
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 30)];
    moreLabel.font = [UIFont systemFontOfSize:13];
    moreLabel.textColor = [UIColor grayColor];
    moreLabel.textAlignment = NSTextAlignmentCenter;
    moreLabel.text = @"努力加载中...";
    [view addSubview:moreLabel];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHFlsNewsModel *model = self.dataArray[indexPath.row];
    if ([model.type isEqualToString:@"news"]) {
        if ([model.images count] == 1) {
            HHFlsNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell == nil) {
                cell = [[HHFlsNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setupData:model];
            return cell;
        } else {
            HHFlsNewsImgsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"morecell"];
            if (cell == nil) {
                cell = [[HHFlsNewsImgsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"morecell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setupData:model];
            return cell;
        }
    }
    HHFlsAdCell *cell = [[HHFlsAdCell alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 300)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.adClickBlock = ^{
        if (!model.selected && self.numAdvert > 0) {
            model.selected = YES;
            self.currentTaskCount++;
            self.numAdvert--;
            if (self.numAdvert < 0) {
                self.numAdvert = 0;
            }
            [self refreshProgressView];
            if (self.timeCounter >= self.timeMin) {
                [self checkTaskState];
            }
        }
    };
    [cell setupController:self data:model.adModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHFlsNewsModel *model = self.dataArray[indexPath.row];
    if ([model.type isEqualToString:@"news"]) {
        if ([model.images count] == 1) {
            return 105*KFLSDeviceWidthScale;
        } else {
            return [HHFlsNewsImgsCell cellHeightWith:model];
        }
    }
    return [HHFlsAdCell cellHeightWith:model adModel:model.adModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HHFlsNewsModel *model = self.dataArray[indexPath.row];
    if ([model.type isEqualToString:@"news"]) {
        [self showArticle:model];
        if (!model.selected && self.numNews > 0) {
            model.selected = YES;
            self.currentTaskCount++;
            self.numNews--;
            if (self.numNews < 0) {
                self.numNews = 0;
            }
        }
    }
}

- (HHFlsNewsWebController *)webController {
    if (!_webController) {
        _webController = [[HHFlsNewsWebController alloc] init];
    }
    return _webController;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    __weak __typeof(self)weakSelf = self;
    if (scrollView.contentSize.height - scrollView.contentOffset.y < self.tableView.lr_height) {
        if (!self.isLaunchingMore) {
            NSString *text = [NSString stringWithFormat:@"clientBackTaskConMore('%@')", self.sendConfig];
            [self.webView evaluateJavaScript:text completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                if (error) {
                    weakSelf.isLaunchingMore = NO;
                }
            }];
            self.isLaunchingMore = YES;
        }
    }
    if (scrollView.contentOffset.y < 0) {
        [self stopTimer];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.isFinished && !self.isScrolling && scrollView.contentOffset.y >= 0) {
        [self startTimer];
    }
    self.isScrolling = YES;
    [self stopTipTimer];
    [self hideRedTip];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 手指离开屏幕后，如果不继续滑动，停止计时器，置isScrolling为NO
        if (!self.isFinished) {
            [self stopTimer];
        }
        self.isScrolling = NO;
    }
    [self resetTipTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.isFinished) {
        [self stopTimer];
    }
    self.isScrolling = NO;
}

- (void)startTimer {
    if (!self.isScrolling) {
        [self.timer setFireDate:[NSDate date]];
    }
}

- (void)stopTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

@end
