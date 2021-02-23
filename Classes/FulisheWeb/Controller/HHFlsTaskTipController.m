//
//  HHFlsTaskTipController.m
//  AdFulishe
//
//  Created by 张维凡 on 2020/11/12.
//

#import "HHFlsTaskTipController.h"
#import "HHHeader.h"

@interface HHFlsTaskTipController ()

@property (nonatomic, strong) UIButton *closeButton;    // 关闭
@property (nonatomic, strong) UIImageView *iconView; // 顶部图片
@property (nonatomic, strong) UIView *bgView; //  白色背景
@property (nonatomic, strong) UILabel *label;   // 奖励文案
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation HHFlsTaskTipController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8];
    
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.iconView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Event

- (void)closeTip {
    [self dismissViewControllerAnimated:NO completion:^{
            
    }];
}

#pragma mark - Getter

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/task_tip_close"];
        CGFloat width = image.size.width;
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bgView.lr_right - width, self.bgView.lr_top - width - 12, width, width)];
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeTip) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/task_tip_icon"];
        CGFloat width = image.size.width*KFLSDeviceWidthScale;
        CGFloat height = image.size.height*KFLSDeviceWidthScale;
        _iconView = [[UIImageView alloc] initWithImage:image];
        _iconView.frame = CGRectMake(KLRScreenWidth/2 - width/2, self.bgView.lr_top - height/2, width, height);
    }
    return _iconView;
}

- (UIView *)bgView {
    if (!_bgView) {
        CGFloat gap = 35;
        CGFloat width = KLRScreenWidth - gap * 2;
        CGFloat height = 190;
        CGFloat positionY = (KLRScreenHeight - height) / 2;
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(gap, positionY, width, height)];
        _bgView.backgroundColor = KLRColorWhite;
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;

        [_bgView addSubview:self.label];
        [_bgView addSubview:self.leftButton];
        [_bgView addSubview:self.rightButton];
        _bgView.lr_height = self.leftButton.lr_bottom + 20;
    }
    return _bgView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(15, 60, _bgView.lr_width - 30, 45)];
        _label.font = [UIFont systemFontOfSize:16];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _label.numberOfLines = 0;
        _label.text = @"您的任务即将完成，\n\n确定要狠心离开吗？";
        
        [_label sizeToFit];
        _label.frame = CGRectMake(15, 60, _bgView.lr_width - 30, _label.lr_height);
    }
    return _label;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        CGFloat width = (_bgView.lr_width - 15*3)/2;
        width -= 20;
        CGFloat height = 40*KFLSDeviceWidthScale;
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.label.lr_bottom + 22, width, height)];
        _leftButton.layer.cornerRadius = height/2;
        _leftButton.layer.borderColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1].CGColor;
        _leftButton.layer.borderWidth = 0.5;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_leftButton setTitle:@"去意已决" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        CGFloat height = 40*KFLSDeviceWidthScale;
        CGFloat width = (_bgView.lr_width - 15*3)/2;
        width += 20;
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.leftButton.lr_right + 15, self.label.lr_bottom + 22, width, height)];
        _rightButton.layer.cornerRadius = height/2;
        _rightButton.layer.borderColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1].CGColor;
        _rightButton.layer.borderWidth = 0.5;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _rightButton.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:38.0/255.0 blue:1.0/255.0 alpha:1];
        [_rightButton setTitle:@"继续任务" forState:UIControlStateNormal];
        [_rightButton setTitleColor:KLRColorWhite forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (void)leftButtonAction {
    __weak __typeof(self)weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        if (weakSelf.withdrawTaskBlock) {
            weakSelf.withdrawTaskBlock();
        }
    }];
}

- (void)rightButtonAction {
    [self closeTip];
}

@end
