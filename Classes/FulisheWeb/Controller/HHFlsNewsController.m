//
//  HHFlsNewsController.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/12.
//

#import "HHFlsNewsController.h"
#import "LRHomeTipController.h"
#import "HHFlsNewsWebController.h"
#import "HHFlsTaskTipController.h"

#import "WKProcessPool+FlsSharedProcessPool.h"
#import "HHFlsNewsCell.h"
#import "HHFlsNewsImgsCell.h"
#import "LRInfoFlowAdCell.h"

#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "LRHomeTipController.h"
#import "HHAdViewManager.h"
#import "YYLRModel.h"
#import "GDTSDKConfig.h"
#import "GDTUnifiedNativeAd.h"

#import "LRAdvertLog.h"
#import "HHFlsCateView.h"
#import "HHNewsMoreCateController.h"
#import "LRInfoFlowAdProvider.h"
#import "LRNewsCateModel.h"
#import "LRInfoFlowView.h"

@interface HHFlsNewsController () <WKNavigationDelegate, WKScriptMessageHandler, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIViewControllerTransitioningDelegate, LRInfoFlowAdDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LRNewsCateModel *currentCateModel;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *yellowView;
@property (nonatomic, strong) UILabel *yellowLabel;

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) LRHomeTipController *homeTipController;
@property (nonatomic, copy) NSString *finishedSendConfig;
@property (nonatomic, copy) NSString *sourceType;

@property (nonatomic, copy) NSString *fetchType;    // 拉取新闻类型 start第一页/after
@property (nonatomic, strong) HHFlsCateView *cateView;
@property (nonatomic, strong) HHNewsMoreCateController *moreCate;
@property (nonatomic, strong) NSArray *cateArray;               // 分类列表，包含新闻广告数据和tableview
@property (nonatomic, strong) NSMutableArray *cachedCateArray;  // 缓存下来的新闻列表
@property (nonatomic, assign) BOOL isLaunchingMore;     // 正在加载更多
@property (nonatomic, strong) UILabel *loadMoreLabel;
@property (nonatomic, strong) UIView *loadMoreView;

@end

@implementation HHFlsNewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.sendConfigDict[@"taskTitle"]?:@"";
    [self hh_setupTitle:title];
    
    self.currentCateModel = [[LRNewsCateModel alloc] init];
    self.currentCateModel.cid = self.sendConfigDict[@"cid"];;
    self.fetchType = @"start";
    
    self.view.backgroundColor = KLRColorWhite;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.yellowView];
    [self.view addSubview:self.tableView];

    [self setupCustomNavbar];
    
    NSURL *remoteURL = [NSURL URLWithString:@"https://lrqd.wasair.com/advert/task/con/transition"]; // 正式
    if ([HHAdViewManager sharedManager].isDevelop) {
        remoteURL = [NSURL URLWithString:@"http://sandbox.lrqd.wasair.com/advert/task/con/transition"]; // 测试
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
    [self.webView loadRequest:request];
    
    NSDictionary *adConfigDict = self.sendConfigDict[@"advertConfigAll"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.taskCallBackBlock && self.finishedSendConfig) {
        self.taskCallBackBlock(self.finishedSendConfig, @"");
    } else if (self.taskCallBackBlock) {
        self.taskCallBackBlock(self.sendConfig, @"");
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter

- (NSMutableArray *)cachedCateArray {
    if (!_cachedCateArray) {
        _cachedCateArray = [NSMutableArray array];
    }
    return _cachedCateArray;
}

- (UIView *)yellowView {
    if (!_yellowView) {
        _yellowView = [[UIView alloc] initWithFrame:CGRectMake(0, KFLSTopHeight, KLRScreenWidth, 30)];
        _yellowView.backgroundColor = FLSRGBValue(0xdd504a);
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


#pragma mark - Event

- (void)showTaskFinishTipView:(UIView *)view {
    [self.view addSubview:view];
}

// 返回按钮
- (void)hh_backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDictionary *)hh_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

- (void)clientCallTaskStartVersionTwo:(NSDictionary *)dict {
    self.isLaunchingMore = NO;
    self.sendConfig = dict[@"sendConfig"];
    self.sendConfigDict = [self hh_dictionaryWithJsonString:self.sendConfig];
    if (![self.sendConfigDict[@"endStatus"] boolValue]) {
        self.loadMoreLabel.text = @"努力加载中...";
    } else {
        self.loadMoreLabel.text = @"已经到底啦！";
    }
//    LRLog(@"clientCallTaskStartVersionTwo->dict->%@", dict);
    [self refreshWithDatas:dict[@"newsDatas"]];
}

- (void)refreshWithDatas:(NSArray *)array {
    if ([self.fetchType isEqualToString:@"start"]) {
        [self.currentCateModel.adDataArray removeAllObjects];
        [self.currentCateModel.newsArray removeAllObjects];
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
    for (NSDictionary *dict in array) {
        NSMutableDictionary *tmpDict = [dict mutableCopy];
        [tmpDict setObject:@(NO) forKey:@"selected"];
        HHFlsNewsModel *model = [HHFlsNewsModel yylr_modelWithDictionary:tmpDict];
        if (model == nil) {
            model = [[HHFlsNewsModel alloc] init];
        }
        if ([model.type isEqualToString:@"advert"]) {
            [self.currentCateModel.adDataArray addObject:model];
        }
        [self.currentCateModel.newsArray addObject:model];
    }
    [self.tableView reloadData];
    [self refreshAdModel];
}

- (void)refreshAdModel {
    // 计算空admodel数量
    NSInteger emptyAdModelCount = 0;
    for (HHFlsNewsModel *model in self.currentCateModel.adDataArray) {
        if (model.adView == nil) {
            emptyAdModelCount += 1;
        }
    }
    if (emptyAdModelCount > 0) {
        NSInteger count = emptyAdModelCount;
        if (emptyAdModelCount > 3) {
            count = 3;
        }
        NSDictionary *adConfigDict = self.sendConfigDict[@"advertConfigAll"];
        HHFlsAdModel *advertModel = [HHFlsAdModel yylr_modelWithDictionary:adConfigDict];
        [LRInfoFlowAdProvider infoFlowAdWithAd:advertModel delegate:self adViewSize:CGSizeMake(KLRScreenWidth, KLRScreenWidth/KLRCsjInfoFlowScale) adCount:count fromController:self];
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
    [self fetchMoreNews];
    [self.webView evaluateJavaScript:@"clientCallTaskNewsCates()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];
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
    HHFlsNewsWebController *webController = [[HHFlsNewsWebController alloc] init];
    webController.sendConfig = self.sendConfig;
    webController.title = self.sendConfigDict[@"taskTitle"]?:@"";
    webController.cid = model.cid;
    webController.aid = model.aid;
    webController.urlString = model.url;
    [self.navigationController pushViewController:webController animated:YES];
}


// 显示弹窗
- (void)flsShowSignAd:(NSDictionary *)dict {
    NSString *sendData = dict[@"sendData"];
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

- (void)flsTaskNewsCates:(id)param {
    NSDictionary *dict;
    if ([param isKindOfClass:[NSString class]]) {
        dict = [param lr_dictionaryWithJsonString:param];
    } else if ([param isKindOfClass:[NSDictionary class]]) {
        dict = param;
    }
    NSString *showCate = dict[@"cateDatas"][@"showCate"];
    self.cateArray = [NSArray yylr_modelArrayWithClass:[LRNewsCateModel class] json:dict[@"cateDatas"][@"cates"]];
    NSInteger index = 0;
    for (LRNewsCateModel *cateModel in self.cateArray) {
        if (self.currentCateModel.cid.integerValue == [cateModel.cid integerValue]) {
            cateModel.adDataArray = self.currentCateModel.adDataArray;
            cateModel.newsArray = self.currentCateModel.newsArray;
            cateModel.tableView = self.currentCateModel.tableView;
            self.currentCateModel = cateModel;
        }
        cateModel.cateIndex = index;
        index++;
    }
    [self.cateView setupCates:self.cateArray selectedIndex:self.currentCateModel.cateIndex];
    self.moreCate.cateArray = self.cateArray;
    [self.view addSubview:self.cateView];
    
    if (showCate.boolValue) {
        self.cateView.hidden = NO;
        self.tableView.frame = CGRectMake(0, self.cateView.lr_bottom, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight - self.yellowView.lr_height - 33);
    } else {
        self.cateView.hidden = YES;
        self.tableView.frame = CGRectMake(0, self.yellowView.lr_bottom, KLRScreenWidth, self.tableView.lr_height);
    }
}

- (void)fetchNewsWithIndex:(NSInteger)index {
    LRNewsCateModel *selectedCateModel = self.cateArray[index];
    // 缓存
    if ([self.cachedCateArray containsObject:selectedCateModel]) {
        [self.cachedCateArray removeObject:selectedCateModel];
    }
    [self.cachedCateArray addObject:selectedCateModel];
    self.currentCateModel = selectedCateModel;

    // 更换tableView
    [_tableView removeFromSuperview];
    if (self.cateView.hidden) {
        self.tableView.frame = CGRectMake(0, 0, KLRScreenWidth, self.tableView.lr_height);
    } else {
        self.tableView.frame = CGRectMake(0, self.cateView.lr_bottom, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight - self.yellowView.lr_height - 33);
    }
    [self.view addSubview:self.tableView];
    
    // 清理多出的tableview，目前只缓存5个
    [self clearTableViews];
    
    if (self.currentCateModel.newsArray.count == 0) {
        self.fetchType = @"start";
        self.loadMoreLabel.text = @"努力加载中...";
        [self fetchMoreNews];
    }
}

// 暂定只缓存5个tableview， 多余清除
- (void)clearTableViews {
    if (self.cachedCateArray.count > 5) {
        LRNewsCateModel *cateModel = self.cachedCateArray.firstObject;
        cateModel.tableView = nil;
        [cateModel.newsArray removeAllObjects];
        [cateModel.adDataArray removeAllObjects];
        [self.cachedCateArray removeObjectAtIndex:0];
        [self clearTableViews];
    }
}

- (void)fetchMoreNews {
    if ([self.fetchType isEqualToString:@"start"] || ![self.sendConfigDict[@"endStatus"] boolValue]) {
        HHWeakSelf
        NSDictionary *clientDict = @{@"cid":self.currentCateModel.cid, @"resType":self.fetchType};
        NSString *text = [NSString stringWithFormat:@"clientBackTaskConMoreVersionTwo('%@','%@')", self.sendConfig, [clientDict yylr_modelToJSONString]];
//        LRLog(@"clientBackTaskConMoreVersionTwo->%@", text);
        [self.webView evaluateJavaScript:text completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//            LRLog(@"clientBackTaskConMoreVersionTwo->completion->%@->%@", response, error);
            if (error && [self.fetchType isEqualToString:@"after"]) {
                weakSelf.isLaunchingMore = NO;
            }
        }];
    }
}

- (void)showMoreCates {
    self.moreCate.selectedIndex = self.cateView.selectedIndex;
    [self presentViewController:self.moreCate animated:YES completion:nil];
}

#pragma mark - Getter

- (HHNewsMoreCateController *)moreCate {
    if (!_moreCate) {
        _moreCate = [[HHNewsMoreCateController alloc] init];
        _moreCate.transitioningDelegate = self;
        _moreCate.modalPresentationStyle = UIModalPresentationCustom;
        HHWeakSelf
        _moreCate.moreCateSelectBlock = ^(NSInteger index) {
            [weakSelf fetchNewsWithIndex:index];
            weakSelf.cateView.selectedIndex = index;
        };
    }
    return _moreCate;
}

- (HHFlsCateView *)cateView {
    if (!_cateView) {
        _cateView = [[HHFlsCateView alloc] initWithFrame:CGRectMake(0, self.yellowView.lr_bottom, KLRScreenWidth, 33)];
        HHWeakSelf
        _cateView.lrNewsMoreCateBlock = ^{
            [weakSelf showMoreCates];
        };
        _cateView.lrNewsCateSelectBlock = ^(NSInteger index) {
            [weakSelf fetchNewsWithIndex:index];
        };
    }
    return _cateView;
}

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
        [wkUController addScriptMessageHandler:self name:@"flsShowSignAd"];
        [wkUController addScriptMessageHandler:self name:@"flsTaskNewsCates"];
        [wkUController addScriptMessageHandler:self name:@"clientCallTaskStartVersionTwo"];
        
        config.userContentController = wkUController;
        config.processPool = [WKProcessPool sharedProcessPool];

        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preferences;

        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) configuration:config];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *parameter = message.body;
//    NSLog(@"----=======------===----%@, %@", message.name, message.body);
    if ([message.name isEqualToString:@"flsShowSignAd"]) {
        [self flsShowSignAd:parameter];
    } else if ([message.name isEqualToString:@"flsTaskNewsCates"]) {
        [self flsTaskNewsCates:parameter];
    } else if ([message.name isEqualToString:@"clientCallTaskStartVersionTwo"]) {
        [self clientCallTaskStartVersionTwo:parameter];
    }
}

- (UITableView *)tableView {
    if (self.currentCateModel.tableView == nil) {
        UITableView *tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yellowView.lr_bottom, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight - self.yellowView.lr_height) style:UITableViewStyleGrouped];
        tmpTableView.backgroundColor = KLRColorWhite;
        tmpTableView.delegate = self;
        tmpTableView.dataSource = self;
        tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            tmpTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            tmpTableView.estimatedRowHeight = 0;
            tmpTableView.estimatedSectionHeaderHeight = 0;
            tmpTableView.estimatedSectionFooterHeight = 0;
        }
        self.currentCateModel.tableView = tmpTableView;
    }
    _tableView = self.currentCateModel.tableView;
    return _tableView;
}

- (UIView *)loadMoreView {
    if (!_loadMoreView) {
        _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 30)];
        [_loadMoreView addSubview:self.loadMoreLabel];
    }
    return _loadMoreView;
}

- (UILabel *)loadMoreLabel {
    if (!_loadMoreLabel) {
        _loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 30)];
        _loadMoreLabel.font = [UIFont systemFontOfSize:13];
        _loadMoreLabel.textColor = [UIColor grayColor];
        _loadMoreLabel.textAlignment = NSTextAlignmentCenter;
        _loadMoreLabel.text = @"努力加载中...";
    }
    return _loadMoreLabel;
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentCateModel.newsArray.count;
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
    return self.loadMoreView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHFlsNewsModel *model = self.currentCateModel.newsArray[indexPath.row];
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
    LRInfoFlowAdCell *cell = [[LRInfoFlowAdCell alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 300)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setupController:self adView:model.adView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHFlsNewsModel *model = self.currentCateModel.newsArray[indexPath.row];
    if ([model.type isEqualToString:@"news"]) {
        if ([model.images count] == 1) {
            return 105*KFLSDeviceWidthScale;
        } else {
            return [HHFlsNewsImgsCell cellHeightWith:model];
        }
    }
    return model.adView ? model.adView.lr_height : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HHFlsNewsModel *model = self.currentCateModel.newsArray[indexPath.row];
    if ([model.type isEqualToString:@"news"]) {
        [self showArticle:model];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y < self.tableView.lr_height) {
        if (!self.isLaunchingMore) {
            self.isLaunchingMore = YES;
            self.fetchType = @"after";
            [self fetchMoreNews];
        }
    }
}

#pragma mark - Animation

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentAnimation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dismissAnimation;
}

- (void)lrNativeExpressAdSuccessToLoad:(LRAdModel *)adModel {
    NSMutableArray *tmpArray = [adModel.adViewArray mutableCopy];
    for (HHFlsNewsModel *model in self.currentCateModel.adDataArray) {
        if (model.adView == nil && tmpArray.count > 0) {
            model.adView = [tmpArray lastObject];
            [tmpArray removeLastObject];
            
            LRInfoFlowView *infoFlowView = (LRInfoFlowView *)model.adView;
            if (infoFlowView.canRegisterClickableViews && !infoFlowView.isRegisterdClickableViews) {
                [infoFlowView registerClickableViews:@[]];
            }
        }
    }
    [self.tableView reloadData];
    [self refreshAdModel];
}

- (void)lrNativeExpressAdFailToLoad:(LRAdModel *)nativeExpressAdManager error:(NSError *)error {
    if ([LRInfoFlowAdProvider canReloadAd]) {
        [self refreshAdModel];
    }
}

- (void)lrInfoFlowAdIsLoading:(BOOL)isLoading {
    if (isLoading) {
        LRLog(@"请稍后，信息流正在加载……");
    }
}

@end
