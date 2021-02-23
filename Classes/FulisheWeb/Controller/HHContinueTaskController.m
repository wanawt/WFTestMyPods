//
//  HHContinueTaskController.m
//  AdFulishe
//
//  Created by 张维凡 on 2020/12/14.
//

#import "HHContinueTaskController.h"
#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "HHAnimateRectView.h"
#import "UIImageView+AFLRNetworking.h"
#import "UIButton+AFLRNetworking.h"

#import "GDTSDKConfig.h"
#import "GDTUnifiedNativeAd.h"
#import "UnifiedNativeAdCustomView.h"
#import "NSObject+YYLRModel.h"
#import "HHFlsAdModel.h"

#import "LRInfoFlowAdProvider.h"
#import "LRInfoFlowView.h"

@interface HHContinueTaskController () <LRInfoFlowAdDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIViewController *controller;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIImageView *icHhCongratulationsView; // 恭喜获得
@property (nonatomic, strong) UIImageView *giftUrlView; //  彩带
@property (nonatomic, strong) UILabel *moneyTipLabel;   // 奖励文案
@property (nonatomic, strong) UILabel *congLabel;   // 恭喜获得
@property (nonatomic, strong) UIButton *centerButton;    // 中间按钮
@property (nonatomic, strong) UIButton *leaveButton;    // 中间按钮

// 信息流广告
@property (nonatomic, strong) UIView *bottomWhiteView;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIImageView *leftLine;
@property (nonatomic, strong) UIImageView *rightLine;

@property (nonatomic, copy) NSDictionary *adConfigDict;
@property (nonatomic, strong) HHFlsAdModel *adModel;

@end

@implementation HHContinueTaskController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tag = 100;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    LRLog(@"-------viewdidload");
    
    [self.view addSubview:self.baseView];
    [self.baseView addSubview:self.giftUrlView];
    [self.baseView addSubview:self.icHhCongratulationsView];
    [self refreshViews];

    [self.baseView addSubview:self.moneyTipLabel];
    [self.baseView addSubview:self.bottomWhiteView];
    self.baseView.lr_height = self.bottomWhiteView.lr_bottom;
    self.baseView.center = CGPointMake(KLRScreenWidth/2, KLRScreenHeight/2);
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
//    LRLog(@"------000------%@----", sendData);
    NSDictionary *sendDataDict = (NSDictionary *)[NSObject yylr_jsonObjWithString:sendData];
    
    _params = sendDataDict;
    [self showViews];
    [self refreshViews];
    
    NSDictionary *adDict = params[@"configNow"][@"advertConfigAll"];
    self.adModel = [HHFlsAdModel yylr_modelWithDictionary:adDict];
    [self loadImageText];
}

- (HHFlsAdModel *)adModel {
    if (!_adModel) {
        _adModel = [[HHFlsAdModel alloc] init];
    }
    return _adModel;
}

- (void)refreshViews {
    // 金额
    UIColor *textColor = FLSRGBValue(0x333333);
    NSString *text = [NSString stringWithFormat:@"%@\n%@", self.params[@"detainTaskMsgMiddleOne"], self.params[@"detainTaskMsgMiddleTwo"]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:textColor}];
    [attrString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*KFLSDeviceWidthScale], NSForegroundColorAttributeName:textColor} range:NSMakeRange(0, text.length - 1)];
    [attrString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16*KFLSDeviceWidthScale], NSForegroundColorAttributeName:textColor} range:NSMakeRange(text.length - 1, 1)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString length])];
    
    self.moneyTipLabel.attributedText = attrString;
    
    // 恭喜
    __weak __typeof(self)weakSelf = self;
    [self.icHhCongratulationsView lr_setImageWithURL:[NSURL URLWithString:self.params[@"p2OneImgTop"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            CGFloat scale = image.size.width/image.size.height;
            weakSelf.icHhCongratulationsView.lr_width = 25*KFLSDeviceWidthScale*scale;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    [self.giftUrlView lr_setImageWithURL:[NSURL URLWithString:self.params[@"detainTaskImgTopBg"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            CGFloat scale = image.size.height/image.size.width;
            weakSelf.giftUrlView.lr_height = 300*KFLSDeviceWidthScale*scale;
            weakSelf.bottomWhiteView.lr_top = weakSelf.giftUrlView.lr_bottom - 1;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    self.bottomLabel.text = self.params[@"detainTaskMsgTop"];
    [self.bottomLabel lr_fitWidth];
    self.bottomLabel.lr_left = (self.bottomWhiteView.lr_width - self.bottomLabel.lr_width)/2;
    
    [self.leftLine lr_setImageWithURL:[NSURL URLWithString:self.params[@"detainTaskImgTopLeft"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            weakSelf.leftLine.lr_left = weakSelf.bottomLabel.lr_left - weakSelf.leftLine.lr_width - 15;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    [self.rightLine lr_setImageWithURL:[NSURL URLWithString:self.params[@"detainTaskImgTopRight"]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            weakSelf.rightLine.lr_left = weakSelf.bottomLabel.lr_right + 15;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    
    [self.centerButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:self.params[@"detainTaskImgBtnContinue"]]];
    
    NSString *leaveString = self.params[@"detainTaskMsgMiddleThree"];
    NSAttributedString *leaveAttr = [[NSAttributedString alloc] initWithString:leaveString attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle), NSForegroundColorAttributeName:FLSRGBValue(0xEAA8A7), NSFontAttributeName:[UIFont systemFontOfSize:13*KFLSDeviceWidthScale]}];
    [self.leaveButton setAttributedTitle:leaveAttr forState:UIControlStateNormal];
}

- (void)loadImageText {
    CGFloat width = self.bottomWhiteView.lr_width;
    [LRInfoFlowAdProvider infoFlowAdWithAd:self.adModel delegate:self adViewSize:CGSizeMake(width, width/KLRCsjInfoFlowTipScale) adCount:1 fromController:self];
}


- (void)finishTaskAction {
    if (self.finishTaskBlock) {
        self.finishTaskBlock();
    }
}

- (void)continueAction {
    if (self.continueBlock) {
        self.continueBlock();
    }
}

#pragma mark - Getter

- (UIView *)baseView {
    if (!_baseView) {
        _baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 10)];
    }
    return _baseView;
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
    
    [_giftUrlView addSubview:self.bottomLabel];
    [_giftUrlView addSubview:self.leftLine];
    [_giftUrlView addSubview:self.rightLine];
    
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
        _moneyTipLabel.frame = CGRectMake(0, 50*KFLSDeviceWidthScale, KLRScreenWidth, 70);
        _moneyTipLabel.textAlignment = NSTextAlignmentCenter;
        _moneyTipLabel.numberOfLines = 2;
    }
    return _moneyTipLabel;
}

- (UIView *)bottomWhiteView {
    if (!_bottomWhiteView) {
        _bottomWhiteView = [[UIView alloc] initWithFrame:CGRectMake(self.giftUrlView.lr_left, self.giftUrlView.lr_bottom, self.giftUrlView.lr_width, 280*KFLSDeviceWidthScale)];
        _bottomWhiteView.backgroundColor = KLRColorWhite;
        [_bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
        [_bottomWhiteView addSubview:self.centerButton];
        [_bottomWhiteView addSubview:self.leaveButton];
    }
    return _bottomWhiteView;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 17*KFLSDeviceWidthScale)];
        _bottomLabel.textColor = FLSRGBValue(0x333333);
        _bottomLabel.font = [UIFont boldSystemFontOfSize:17*KFLSDeviceWidthScale];
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
        CGFloat width = 220*KFLSDeviceWidthScale;
        CGFloat gap = (_bottomWhiteView.lr_width - width)/2;
        _centerButton = [[UIButton alloc] initWithFrame:CGRectMake(gap, 0, width, 44*KFLSDeviceWidthScale)];
        [_centerButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerButton;
}

- (UIButton *)leaveButton {
    if (!_leaveButton) {
        _leaveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.centerButton.lr_left, self.centerButton.lr_bottom + 10, self.centerButton.lr_width, 22)];
        [_leaveButton addTarget:self action:@selector(finishTaskAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leaveButton;
}

#pragma mark - Ad Delegate

- (void)lrNativeExpressAdSuccessToLoad:(LRAdModel *)adModel {
    UIView *tmpAdView = [self.view viewWithTag:101];
    if (tmpAdView) {
        [tmpAdView removeFromSuperview];
    }
    tmpAdView = nil;
    
    if (adModel.adView) {
          
    } else if (adModel.adViewArray && adModel.adViewArray.count > 0) {
        NSArray *adViewArray = adModel.adViewArray;
        LRInfoFlowView *adView = adViewArray[0];
        
        adView.lr_top = self.leaveButton.lr_bottom + 15;
        if (adView.canRegisterClickableViews) {
            [adView registerClickableViews:@[]];
        }
        [self.bottomWhiteView addSubview:adView];
        self.bottomWhiteView.lr_height = adView.lr_bottom;
        [self.bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    }
    self.baseView.lr_height = self.bottomWhiteView.lr_bottom;
    self.baseView.center = CGPointMake(KLRScreenWidth/2, KLRScreenHeight/2);
    [self refreshBaseView];
}

- (void)lrNativeExpressAdFailToLoad:(LRAdModel *)nativeExpressAdManager error:(NSError *)error {
    self.bottomWhiteView.lr_height = self.leaveButton.lr_bottom + 10 + 12*KFLSDeviceWidthScale;
    [self.bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    [self refreshBaseView];
}

- (void)refreshBaseView {
    self.baseView.lr_height = self.bottomWhiteView.lr_bottom;
    self.baseView.center = CGPointMake(KLRScreenWidth/2, KLRScreenHeight/2);
}

- (void)lrInfoFlowAdIsLoading:(BOOL)isLoading {
    if (isLoading) {
        self.bottomWhiteView.lr_height = self.leaveButton.lr_bottom + 10 + 12*KFLSDeviceWidthScale;
        [self.bottomWhiteView setupCornerRadius:12*KFLSDeviceWidthScale withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
        [self refreshBaseView];
    }
}


@end
