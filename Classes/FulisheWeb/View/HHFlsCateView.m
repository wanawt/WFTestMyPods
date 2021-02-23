//
//  HHFlsCateView.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/12.
//

#import "HHFlsCateView.h"
#import "HHHeader.h"
#import "LRNewsCateModel.h"

@interface HHFlsCateView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) NSArray *cates;
@property (nonatomic, strong) UIView *redLine;

@end

@implementation HHFlsCateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = KLRColorWhite;
        [self addSubview:self.scrollView];
        [self addSubview:self.moreButton];
        [self.scrollView addSubview:self.redLine];
    }
    return self;
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.lr_width = self.lr_width - 40;
        _scrollView.scrollEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)redLine {
    if (!_redLine) {
        _redLine = [[UIView alloc] initWithFrame:CGRectMake(0, 31, 20, 2)];
        _redLine.layer.cornerRadius = 1;
        _redLine.layer.backgroundColor = FLSRGBValue(0xD8342D).CGColor;
    }
    return _redLine;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        CGFloat width = 40;
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.lr_width - width, 0, width, 33)];
        [_moreButton setImage:[UIImage imageNamed:@"FulisheAdBundle.bundle/lr_news_cate_more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreCateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

#pragma mark - Event

- (void)setupCates:(NSArray *)array selectedIndex:(NSInteger)index {
    _cates = array;
    _selectedIndex = index;
    [self clearCateButtons];
    [self setupButtons];
    [self.scrollView bringSubviewToFront:self.redLine];
}

- (void)clearCateButtons {
    NSArray *subViews = self.scrollView.subviews;
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)setupButtons {
    NSInteger index = 0;
    CGFloat width = 48;
    CGFloat totalWidth = 0;
    for (LRNewsCateModel *cateModel in self.cates) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(totalWidth, 0, width, 33)];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.tag = index;
        [button setTitle:cateModel.name forState:UIControlStateNormal];
        [button setTitleColor:FLSRGBValue(0x333333) forState:UIControlStateNormal];
        [button setTitleColor:FLSRGBValue(0xD8342D) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectCateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 33)];
        label.font = [UIFont systemFontOfSize:14];
        label.text = cateModel.name;
        [label sizeToFit];
        button.lr_width = label.lr_width + 20;
        
        index++;
        totalWidth = button.lr_right;
    }
    self.scrollView.contentSize = CGSizeMake(totalWidth, 33);
    [self refreshSelectedButtonPosition];
}

- (void)refreshSelectedButtonPosition {
    NSInteger index = 0;
    for (UIButton *button in self.scrollView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (index == self.selectedIndex) {
                button.selected = YES;
                self.redLine.lr_left = button.lr_left + (button.lr_width - 20)/2;
                
                if (button.lr_right > self.scrollView.lr_width+self.scrollView.contentOffset.x) {
                    self.scrollView.contentOffset = CGPointMake(button.lr_right - self.scrollView.lr_width, 0);
                } else if (button.lr_left < self.scrollView.contentOffset.x) {
                    self.scrollView.contentOffset = CGPointMake(button.lr_left, 0);
                }
            } else {
                button.selected = NO;
            }
            index++;
        }
    }
}

- (void)selectCateAction:(UIButton *)button {
    for (UIButton *tmpButton in self.scrollView.subviews) {
        if ([tmpButton isKindOfClass:[UIButton class]]) {
            tmpButton.selected = NO;
        }
    }
    button.selected = YES;
    
    _selectedIndex = button.tag;
    if (self.lrNewsCateSelectBlock) {
        self.lrNewsCateSelectBlock(button.tag);
    }
    [self refreshSelectedButtonPosition];
}

- (void)moreCateAction {
    self.moreButton.selected = !self.moreButton.selected;
    if (self.lrNewsMoreCateBlock) {
        self.lrNewsMoreCateBlock();
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (self.cates && self.cates.count > 0) {
        for (UIButton *button in self.scrollView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                if (button.tag == selectedIndex) {
                    button.selected = YES;
                } else {
                    button.selected = NO;
                }
            }
        }
    }
    [self refreshSelectedButtonPosition];
}

@end
