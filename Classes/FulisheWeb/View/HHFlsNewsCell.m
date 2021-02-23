//
//  HHFlsNewsCell.m
//  importevent
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsNewsCell.h"
#import "HHHeader.h"
#import "UIImageView+AFLRNetworking.h"

@interface HHFlsNewsCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *singleImgView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) HHFlsNewsModel *model;

@end

@implementation HHFlsNewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = KLRColorWhite;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.singleImgView];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 105*KFLSDeviceWidthScale - 1, KLRScreenWidth, 0.5)];
        self.line.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1];
        [self.contentView addSubview:self.line];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, self.singleImgView.lr_left - 15*2, 16*KFLSDeviceWidthScale)];
        _titleLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
        _titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 105*KFLSDeviceWidthScale - 20 - 12,  self.singleImgView.lr_left - 15*2, 12)];
        _descLabel.font = [UIFont systemFontOfSize:11*KFLSDeviceWidthScale];
        _descLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    }
    return _descLabel;
}

- (UIImageView *)singleImgView {
    if (!_singleImgView) {
        CGFloat width = 112*KFLSDeviceWidthScale;
        CGFloat height = 75*KFLSDeviceWidthScale;
        _singleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KLRScreenWidth - 15 - width, 15, width, height)];
        _singleImgView.layer.cornerRadius = 4;
        _singleImgView.layer.masksToBounds = YES;
        _singleImgView.backgroundColor = FLSRGBValue(0xc1c1c1);
    }
    return _singleImgView;
}

- (void)clearNews {
    self.titleLabel.text = @"";
    self.singleImgView.image = nil;
    self.descLabel.text = @"";
}

- (void)setupData:(HHFlsNewsModel *)model {
    _model = model;
    [self clearNews];
    if (model == nil) {
        return;
    }
    self.titleLabel.text = model.title;
    self.descLabel.text = model.leftBottom;
    if (model.images && [model.images count] > 0) {
        [self.singleImgView lr_setImageWithURL:[NSURL URLWithString:model.images[0]] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            LRLog(@"setImageWithURL:%@--%@", model.images[0], error);
        }];
    }
    self.line.lr_top = 105*KFLSDeviceWidthScale - 1;
    
    CGRect frame = self.titleLabel.frame;
    [self.titleLabel sizeToFit];
    frame.size.height = self.titleLabel.lr_height;
    self.titleLabel.frame = frame;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
