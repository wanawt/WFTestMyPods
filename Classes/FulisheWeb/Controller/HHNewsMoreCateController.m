//
//  HHNewsMoreCateController.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/13.
//

#import "HHNewsMoreCateController.h"
#import "HHHeader.h"
#import "LRNewsCateModel.h"

@interface HHNewsMoreCateController ()

@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation HHNewsMoreCateController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.blackView];
    [self.blackView addSubview:self.whiteView];
    [self setupViews];
}

#pragma mark - Event

- (void)setupViews {
    NSArray *subViews = self.whiteView.subviews;
    for (UIButton *button in subViews) {
        if ([button isKindOfClass:[UIButton class]] && button != self.closeButton) {
            [button removeFromSuperview];
        }
    }
    
    CGFloat positionY = 0;
    CGFloat sideGap = 15;
    CGFloat gap = 10;
    CGFloat height = 40*KFLSDeviceWidthScale;
    CGFloat width = (self.whiteView.lr_width - sideGap*2 - gap*3) / 4;
    NSInteger index = 0;
    for (LRNewsCateModel *cateModel in self.cateArray) {
        CGFloat positionX = sideGap + index%4 * (width + gap);
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(positionX, 44 + index/4*(height+gap), width, height)];
        button.titleLabel.font = [UIFont systemFontOfSize:14*KFLSDeviceWidthScale];
        button.tag = index;
        button.backgroundColor = FLSRGBValue(0xF2F2F2);
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        [button setTitle:cateModel.name forState:UIControlStateNormal];
        [button setTitleColor:FLSRGBValue(0x333333) forState:UIControlStateNormal];
        [button setTitleColor:FLSRGBValue(0xD8342D) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectCateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteView addSubview:button];
        
        if (self.selectedIndex == index) {
            button.selected = YES;
        }
        
        index++;
        positionY = button.lr_bottom;
    }
    
    self.whiteView.lr_height = positionY + 15;
    [self.whiteView setupCornerRadius:8 withType:UIRectCornerBottomLeft|UIRectCornerBottomRight];
}

- (void)selectCateAction:(UIButton *)button {
    for (UIButton *button in self.whiteView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.selected = NO;
        }
    }
    button.selected = YES;
    
    _selectedIndex = button.tag;
    if (self.moreCateSelectBlock) {
        self.moreCateSelectBlock(button.tag);
    }
    [self closeTip];
}

- (void)closeTip {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self closeTip];
}

#pragma mark - Getter

- (UIView *)whiteView {
    if (!_whiteView) {
        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 100)];
        _whiteView.backgroundColor = KLRColorWhite;
        [_whiteView addSubview:self.titleLabel];
        [_whiteView addSubview:self.descLabel];
        [_whiteView addSubview:self.closeButton];
    }
    return _whiteView;
}

- (UIView *)blackView {
    if (!_blackView) {
        _blackView = [[UIView alloc] initWithFrame:CGRectMake(0, KFLSTopHeight, KLRScreenWidth, KLRScreenHeight - KFLSTopHeight)];
        _blackView.backgroundColor = FLSRGBA(0, 0, 0, 0.7);
        _blackView.layer.masksToBounds = YES;
    }
    return _blackView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIImage *image = [UIImage imageNamed:@"FulisheAdBundle.bundle/lr_news_cate_more_close"];
        CGFloat width = self.titleLabel.lr_height;
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(KLRScreenWidth - width, 0, width, width)];
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeTip) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 60, 44)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = FLSRGBValue(0x333333);
        _titleLabel.text = @"我的频道";
        [_titleLabel lr_fitWidth];
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.lr_right + 5, 0, 60, 44)];
        _descLabel.font = [UIFont systemFontOfSize:11];
        _descLabel.textColor = FLSRGBValue(0x999999);
        _descLabel.text = @"点击进入频道";
        [_descLabel lr_fitWidth];
    }
    return _descLabel;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (self.cateArray && self.cateArray.count > 0) {
        for (UIButton *button in self.whiteView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                if (selectedIndex == button.tag) {
                    button.selected = YES;
                } else {
                    button.selected = NO;
                }
            }
        }
    }
}

@end
