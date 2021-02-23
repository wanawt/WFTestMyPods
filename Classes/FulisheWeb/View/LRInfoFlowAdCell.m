//
//  LRInfoFlowAdCell.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/17.
//

#import "LRInfoFlowAdCell.h"
#import "HHHeader.h"
#import "LRInfoFlowView.h"

@interface LRInfoFlowAdCell ()

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *adView;

//@property (nonatomic, strong) UILabel *adTextLabel;
//@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *buttonLabel;

@end

@implementation LRInfoFlowAdCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = KLRColorWhite;
        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 299 - 1, KLRScreenWidth, 0.5)];
        self.line.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1];
        [self.contentView addSubview:self.line];
    }
    return self;
}

- (void)setupController:(UIViewController *)controller adView:(UIView *)adView {
    _controller = controller;
    _adView = adView;
    
    [self.contentView addSubview:adView];
    self.line.lr_top = adView.lr_height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
