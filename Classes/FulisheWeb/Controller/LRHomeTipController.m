//
//  LRHomeTipController.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/18.
//

#import "LRHomeTipController.h"
#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "HHAnimateRectView.h"
#import "UIImageView+AFLRNetworking.h"

#import "GDTSDKConfig.h"
#import "GDTUnifiedNativeAd.h"
#import "UnifiedNativeAdCustomView.h"
#import "NSObject+YYLRModel.h"
#import "HHFlsAdModel.h"
#import "UIButton+AFLRNetworking.h"

#import "LRInfoFlowAdProvider.h"
#import "LRInfoFlowView.h"

@interface LRHomeTipController () <LRInfoFlowAdDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIViewController *controller;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIButton *closeButton;    // 关闭
@property (nonatomic, strong) UIImageView *icHhCongratulationsView; // 恭喜获得
@property (nonatomic, strong) UIImageView *giftUrlView; //  彩带
@property (nonatomic, strong) UILabel *moneyTipLabel;   // 奖励文案
@property (nonatomic, strong) UILabel *congLabel;   // 恭喜获得
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *betaTimer;   // 确保6s之后必须展示关闭按钮
@property (nonatomic, strong) UIButton *centerButton;    // 中间按钮

// 信息流广告
@property (nonatomic, strong) UIView *bottomWhiteView;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIImageView *leftLine;
@property (nonatomic, strong) UIImageView *rightLine;

@property (nonatomic, copy) NSDictionary *adConfigDict;
@property (nonatomic, strong) HHFlsAdModel *adModel;
@property (nonatomic, strong) UIView *adView;

@end

@implementation LRHomeTipController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    [self.view addSubview:self.baseView];
    [self.baseView addSubview:self.giftUrlView];
    [self.baseView addSubview:self.icHhCongratulationsView];
    [self refreshViews];

    [self.baseView addSubview:self.moneyTipLabel];
    [self.baseView addSubview:self.bottomWhiteView];
    self.baseView.lr_height = self.bottomWhiteView.lr_bottom;
    self.baseView.center = CGPointMake(KLRScreenWidth/2, KLRScreenHeight/2);
    
    [self.view addSubview:self.closeButton];
    self.closeButton.hidden = YES;
    
    [self loadImageText];
}

#pragma mark - Event

- (void)hideViews {
    self.viewsIsHidden = YES;
    for (UIView *view in self.view.subviews) {
        view.hidden = YES;
    }
}

- (void)showViews {
    self.viewsIsHidden = NO;
    for (UIView *view in self.view.subviews) {
        view.hidden = NO;
    }
}

- (void)refreshWithParams:(NSDictionary *)params {
    NSString *sendData = params[@"sendData"];
    NSLog(@"------000------%@----", sendData);
    NSDictionary *sendDataDict = (NSDictionary *)[NSObject yylr_jsonObjWithString:sendData];
    
    if (_params == nil) {
        _params = sendDataDict;
    } else {
        _params = sendDataDict;
        
        // 定时器
        CGFloat closeTime = [self.params[@"twoCloseTime"] floatValue] / 1000;
        self.timer = [NSTimer timerWithTimeInterval:closeTime target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    [self showViews];
    self.closeButton.hidden = YES;
    [self refreshViews];
    
    NSDictionary *adDict = params[@"configNow"][@"advertConfigAll"];
    NSLog(@"------->>>>>>>%@----%@", params[@"configNow"], params[@"configNow"][@"advertConfigAll"]);
    self.adModel = [HHFlsAdModel yylr_modelWithDictionary:adDict];
    [self loadImageText];
    [self startBetaTimer];
}

- (HHFlsAdModel *)adModel {
    if (!_adModel) {
        _adModel = [[HHFlsAdModel alloc] init];
    }
    return _adModel;
}

- (void)refreshViews {
    UIView *adView = [self.view viewWithTag:101];
    if (adView) {
        [adView removeFromSuperview];
        adView = nil;
    }
    // 金额
    UIColor *textColor = [UIColor colorWithRed:241.0/255.0 green:38.0/255.0 blue:32.0/255.0 alpha:1];
    NSString *text = [NSString stringWithFormat:@"%@元", self.params[@"money"]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:textColor}];
    [attrString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50], NSForegroundColorAttributeName:textColor} range:NSMakeRange(0, text.length - 1)];
    [attrString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:textColor} range:NSMakeRange(text.length - 1, 1)];
    self.moneyTipLabel.attributedText = attrString;
    
    __weak __typeof(self)weakSelf = self;
    [self.icHhCongratulationsView lr_setImageWithURL:[NSURL URLWithString:self.params[@"p2OneImgTop"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            CGFloat scale = image.size.width/image.size.height;
            weakSelf.icHhCongratulationsView.lr_width = 25*KFLSDeviceWidthScale*scale;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    [self.giftUrlView lr_setImageWithURL:[NSURL URLWithString:self.params[@"p2OneImgMainBg"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            CGFloat scale = image.size.height/image.size.width;
            weakSelf.giftUrlView.lr_height = 300*KFLSDeviceWidthScale*scale;
        } else {
            weakSelf.giftUrlView.lr_width = 145.0/300.0*KLRScreenWidth;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    // 中间按钮
    if ([self.params[@"hasAgain"] boolValue]) {
        CGFloat gap = 30*KFLSDeviceWidthScale;
        CGFloat btnWidth = _bottomWhiteView.lr_width - gap*2;
        CGFloat height = 44.0/240.0*btnWidth;
        self.centerButton.frame = CGRectMake(gap, 5, btnWidth, height);
        [self.centerButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:self.params[@"p2OneButtonImg"]]];
        self.bottomLabel.lr_top = self.centerButton.lr_bottom + 22;
        self.leftLine.lr_top = self.bottomLabel.lr_top + 5;
        self.rightLine.lr_top = self.bottomLabel.lr_top + 5;
        self.adView.lr_top = self.bottomLabel.lr_bottom + 15;
    }
    
    // 猜你喜欢
    self.bottomLabel.text = self.params[@"p2OneBelowMiddleMsg"];
    [self.bottomLabel lr_fitWidth];
    self.bottomLabel.lr_left = (self.bottomWhiteView.lr_width - self.bottomLabel.lr_width)/2;
    
    [self.leftLine lr_setImageWithURL:[NSURL URLWithString:self.params[@"p2OnebelowLeftImg"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            weakSelf.leftLine.lr_left = weakSelf.bottomLabel.lr_left - weakSelf.leftLine.lr_width - 15;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    [self.rightLine lr_setImageWithURL:[NSURL URLWithString:self.params[@"p2OneBelowRightImg"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            weakSelf.rightLine.lr_left = weakSelf.bottomLabel.lr_right + 15;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
}

- (void)loadImageText {
    CGFloat width = self.bottomWhiteView.lr_width;
    [LRInfoFlowAdProvider infoFlowAdWithAd:self.adModel delegate:self adViewSize:CGSizeMake(width, width/KLRCsjInfoFlowTipScale) adCount:1 fromController:self];
}

- (void)closeTip {
    if (self.closeTipBlock) {
        self.closeTipBlock();
    }
    self.closeButton.hidden = YES;
    [self.view removeFromSuperview];
    [self clearAdView];
}

- (void)lookAdAction {
    if (self.callLookVideoBlock) {
        self.callLookVideoBlock();
    }
}

#pragma mark - Getter

- (UIView *)baseView {
    if (!_baseView) {
        _baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 10)];
    }
    return _baseView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(KLRScreenWidth - 40 - 35, self.baseView.lr_top - 40, 40, 40)];
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/task_tip_close"];
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeTip) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView *)icHhCongratulationsView {
    if (!_icHhCongratulationsView) {
        _icHhCongratulationsView = [[UIImageView alloc] init];
        CGFloat width = 124*KFLSDeviceWidthScale;
        CGFloat height = 25*KFLSDeviceWidthScale;
        _icHhCongratulationsView.frame = CGRectMake((KLRScreenWidth-width)/2, 0, width, height);
    }
    return _icHhCongratulationsView;
}

- (UIImageView *)giftUrlView {
    if (!_giftUrlView) {
        _giftUrlView = [[UIImageView alloc] init];
    }
    CGFloat width = 300*KFLSDeviceWidthScale;
    CGFloat height = 145*KFLSDeviceWidthScale;
    _giftUrlView.frame = CGRectMake((KLRScreenWidth - width)/2, self.icHhCongratulationsView.lr_top + 5, width, height);
    _giftUrlView.userInteractionEnabled = YES;
    [_giftUrlView addSubview:self.congLabel];
    return _giftUrlView;
}

- (UILabel *)congLabel {
    if (!_congLabel) {
        _congLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38*KFLSDeviceWidthScale, _giftUrlView.lr_width, 16*KFLSDeviceWidthScale)];
        _congLabel.textAlignment = NSTextAlignmentCenter;
        _congLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
        _congLabel.text = self.params[@"twoMoneyTip"];
        _congLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    }
    return _congLabel;
}

- (UILabel *)moneyTipLabel {
    if (!_moneyTipLabel) {
        _moneyTipLabel = [[UILabel alloc] init];
        _moneyTipLabel.frame = CGRectMake(0, self.giftUrlView.lr_top + 70*KFLSDeviceWidthScale, KLRScreenWidth, 45*KFLSDeviceWidthScale);
        _moneyTipLabel.textAlignment = NSTextAlignmentCenter;
        UIColor *textColor = [UIColor colorWithRed:241.0/255.0 green:38.0/255.0 blue:32.0/255.0 alpha:1];
        NSString *text = [NSString stringWithFormat:@"%@元", self.params[@"money"]];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:textColor}];
        [attrString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:45], NSForegroundColorAttributeName:textColor} range:NSMakeRange(0, text.length - 1)];
        [attrString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:textColor} range:NSMakeRange(text.length - 1, 1)];
        _moneyTipLabel.attributedText = attrString;
    }
    return _moneyTipLabel;
}

- (UIView *)bottomWhiteView {
    if (!_bottomWhiteView) {
        _bottomWhiteView = [[UIView alloc] initWithFrame:CGRectMake(self.giftUrlView.lr_left, self.giftUrlView.lr_bottom - 1, self.giftUrlView.lr_width, 220*KFLSDeviceWidthScale)];
        _bottomWhiteView.backgroundColor = KLRColorWhite;
        [_bottomWhiteView addSubview:self.centerButton];
        [_bottomWhiteView addSubview:self.bottomLabel];
        [_bottomWhiteView addSubview:self.leftLine];
        [_bottomWhiteView addSubview:self.rightLine];
    }
    return _bottomWhiteView;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 100, 12)];
        _bottomLabel.textColor = FLSRGBValue(0x999999);
        _bottomLabel.font = [UIFont systemFontOfSize:11*KFLSDeviceWidthScale];
    }
    return _bottomLabel;
}

- (UIImageView *)leftLine {
    if (!_leftLine) {
        _leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bottomLabel.lr_top+5, 60, 1)];
    }
    return _leftLine;
}

- (UIImageView *)rightLine {
    if (!_rightLine) {
        _rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bottomLabel.lr_top+5, 60, 1)];
    }
    return _rightLine;
}

- (UIButton *)centerButton {
    if (!_centerButton) {
        CGFloat gap = 30*KFLSDeviceWidthScale;
        _centerButton = [[UIButton alloc] initWithFrame:CGRectMake(gap, 5, _bottomWhiteView.lr_width - gap*2, 0.1)];
        [_centerButton addTarget:self action:@selector(lookAdAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerButton;
}

- (void)startTimerForCloseButton {
    CGFloat closeTime = [self.params[@"twoCloseTime"] floatValue] / 1000;
    self.timer = [NSTimer timerWithTimeInterval:closeTime target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)startBetaTimer {
    self.betaTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(betaTimeChange) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.betaTimer forMode:NSRunLoopCommonModes];
}

- (void)betaTimeChange {
    self.closeButton.hidden = NO;
    [self.betaTimer invalidate];
    self.betaTimer = nil;
}

- (void)timeChange {
    self.closeButton.hidden = NO;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)clearAdView {
    UIView *adView = [self.view viewWithTag:101];
    if (adView) {
        [adView removeFromSuperview];
    }
    adView = nil;
}

#pragma mark - Ad Delegate

- (void)lrNativeExpressAdSuccessToLoad:(LRAdModel *)adModel {
    [self startTimerForCloseButton];
    [self clearAdView];
    
    if (adModel.adView) {
        
    } else if (adModel.adViewArray && adModel.adViewArray.count > 0) {
        NSArray *adViewArray = adModel.adViewArray;
        LRInfoFlowView *infoFlowView = adViewArray[0];
        infoFlowView.tag = 101;
        infoFlowView.lr_top = self.bottomLabel.lr_bottom + 15;
        if (infoFlowView.canRegisterClickableViews) {
            [infoFlowView registerClickableViews:@[]];
        }
        [self.bottomWhiteView addSubview:infoFlowView];
        self.bottomWhiteView.lr_height = infoFlowView.lr_bottom;
        [self.bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    }
    [self refreshBaseView];
}

- (void)lrNativeExpressAdFailToLoad:(LRAdModel *)nativeExpressAdManager error:(NSError *)error {
    [self startTimerForCloseButton];

    self.bottomWhiteView.lr_height = 66*KFLSDeviceWidthScale;
    [self.bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    [self refreshBaseView];
}

- (void)lrInfoFlowAdIsLoading:(BOOL)isLoading {
    if (isLoading) {
        [self startTimerForCloseButton];

        self.bottomWhiteView.lr_height = 66*KFLSDeviceWidthScale;
        [self.bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
        [self refreshBaseView];
    }
}

- (void)refreshBaseView {
    self.baseView.lr_height = self.bottomWhiteView.lr_bottom;
    self.baseView.center = CGPointMake(KLRScreenWidth/2, KLRScreenHeight/2);
    self.closeButton.frame = CGRectMake(KLRScreenWidth - 40 - 35, self.baseView.lr_top - 40, 40, 40);
}

@end
