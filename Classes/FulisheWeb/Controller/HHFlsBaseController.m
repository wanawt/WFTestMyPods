//
//  HHFlsBaseController.m
//  hhsqad
//
//  Created by 张维凡 on 2020/11/4.
//

#import "HHFlsBaseController.h"
#import "LRHomeTipController.h"
#import "HHFlsBaseController.h"
#import "HHHeader.h"
#import "UIImageView+AFLRNetworking.h"
#import "NSObject+YYLRModel.h"
#import "UIKit+AFLRNetworking.h"

@interface HHFlsBaseController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *navbarView;
@property (nonatomic, strong) UILabel *baseTitleLabel;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UILabel *loadingLabel;

@end

@implementation HHFlsBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL hideNavigationBar = NO;
    if ([self isKindOfClass:[LRHomeTipController class]] ||
        [self isKindOfClass:[HHFlsBaseController class]]) {
        hideNavigationBar = YES;
    }
    [self.navigationController setNavigationBarHidden:hideNavigationBar animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.navigationController.viewControllers.count > 1) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        } else {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

#pragma mark - Event

- (void)setupCustomNavbar {
    [self.view addSubview:self.navbarView];
    [self setupCustomBackItem];
}

- (void)setupCustomNavbarWithLine {
    [self setupCustomNavbar];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, KFLSTopHeight - 0.5, KLRScreenWidth, 0.5)];
    line.backgroundColor = FLSRGBValue(0xf5f5f5);
    [self.navbarView addSubview:line];
}

- (void)resetLoadingView {
    [self.loadingImageView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
    self.loadingImageView = nil;
    self.loadingLabel = nil;
    [self.loadingView addSubview:self.loadingImageView];
    [self.loadingView addSubview:self.loadingLabel];
    [self resetLabelFrame];
}

- (void)showLoading {
    [self.view addSubview:self.loadingView];
}

- (void)showErrorWithMsg:(NSString *)msg {
    self.loadingLabel.text = msg;
    [self resetLabelFrame];
    self.loadingImageView.image = [UIImage imageNamed:@"FulisheAdBundle.bundle/sdk_loading_error"];
    [self.view addSubview:self.loadingView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        [self resetLoadingView];
    });
}

- (void)resetLabelFrame {
    CGRect frame = self.loadingLabel.frame;
    [self.loadingLabel sizeToFit];
    frame.size.height = self.loadingLabel.lr_height;
    self.loadingLabel.frame = frame;
}

- (void)hideLoading {
    [self.loadingView removeFromSuperview];
}

- (void)hideLoadingWithError:(NSError *)error {
    NSString *errorInfo = error.userInfo[@"msg"] ? : error.userInfo[@"NSLocalizedDescription"];
    self.loadingLabel.text = errorInfo;
    self.loadingImageView.image = [UIImage imageNamed:@"FulisheAdBundle.bundle/sdk_loading_error"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        [self resetLoadingView];
    });
}

- (void)setupCustomBackItem {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, KFLSStatusHeight, 50, 44);
    UIImage *arrowImage = [UIImage imageNamed:@"FulisheAdBundle.bundle/nav_back_dark"];
    [backBtn setImage:arrowImage forState:UIControlStateNormal];
    [backBtn setImage:arrowImage forState:UIControlStateHighlighted];
//    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-(50 - arrowImage.size.width), 0, 0);
    [backBtn addTarget:self action:@selector(hh_backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.navbarView addSubview:backBtn];
}

- (void)hh_backAction {
    
}

- (void)hh_setupTitle:(NSString *)title {
    self.baseTitleLabel.text = title;
}

#pragma mark - Getter Tip

- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, KLRScreenHeight)];
        _loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [_loadingView addSubview:self.loadingImageView];
        [_loadingView addSubview:self.loadingLabel];
        [self resetLabelFrame];
    }
    return _loadingView;
}

- (UIImageView *)loadingImageView {
    if (!_loadingImageView) {
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/sdk_loading_img"];
        _loadingImageView = [[UIImageView alloc] initWithImage:image];
        _loadingImageView.frame = CGRectMake(KLRScreenWidth/2 - 25, KLRScreenHeight/2 - 25, 50*KFLSDeviceWidthScale, 50*KFLSDeviceWidthScale);
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat: 0];
        rotationAnimation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        rotationAnimation.duration = 1.5;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VAL;
        rotationAnimation.removedOnCompletion = NO;
        [_loadingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    return _loadingImageView;
}

- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.loadingImageView.lr_bottom + 20, KLRScreenWidth, 16)];
        _loadingLabel.numberOfLines = 0;
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.font = [UIFont systemFontOfSize:14];
        _loadingLabel.textColor = KLRColorWhite;
        _loadingLabel.text = @"看完视频即可领取奖励";
    }
    return _loadingLabel;
}

- (UIView *)navbarView {
    if (!_navbarView) {
        _navbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, KFLSTopHeight)];
        _navbarView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
        [_navbarView addSubview:self.baseTitleLabel];
    }
    return _navbarView;
}

- (UILabel *)baseTitleLabel {
    if (!_baseTitleLabel) {
        _baseTitleLabel = [[UILabel alloc] init];
        _baseTitleLabel.frame = CGRectMake(60, KFLSStatusHeight, KLRScreenWidth - 120, 44);
        _baseTitleLabel.textColor = [UIColor blackColor];
        _baseTitleLabel.textAlignment = NSTextAlignmentCenter;
        _baseTitleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _baseTitleLabel;
}

- (LRPresentAnimation *)presentAnimation {
    if (!_presentAnimation) {
        _presentAnimation = [[LRPresentAnimation alloc] init];
    }
    return _presentAnimation;
}

- (LRDismissAnimation *)dismissAnimation {
    if (!_dismissAnimation) {
        _dismissAnimation = [[LRDismissAnimation alloc] init];
    }
    return _dismissAnimation;
}

@end
