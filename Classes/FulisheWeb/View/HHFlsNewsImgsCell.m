//
//  HHFlsNewsImgsCell.m
//  importevent
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsNewsImgsCell.h"
#import "HHHeader.h"
#import "UIImageView+AFLRNetworking.h"

@interface HHFlsNewsImgsCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) NSMutableArray *imgViewArray;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) HHFlsNewsModel *model;

@end

@implementation HHFlsNewsImgsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = KLRColorWhite;
        [self.contentView addSubview:self.titleLabel];
        CGFloat positionY = 0;
        for (int i=0; i<3; i++) {
            UIImageView *imgView = [self singleImgView];
            imgView.lr_left = 15+i*(imgView.lr_width+4);
            [self.contentView addSubview:imgView];
            [self.imgViewArray addObject:imgView];
            positionY = imgView.lr_bottom;
        }
        self.descLabel.lr_top = positionY+10;
        [self.contentView addSubview:self.descLabel];

        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLRScreenWidth, 0.5)];
        self.line.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1];
        [self.contentView addSubview:self.line];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, KLRScreenWidth - 15*2, 16*KFLSDeviceWidthScale)];
        _titleLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
        _titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, [self heightForImage]+10,  KLRScreenWidth - 30, 12)];
        _descLabel.font = [UIFont systemFontOfSize:11*KFLSDeviceWidthScale];
        _descLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    }
    return _descLabel;
}

- (NSMutableArray *)imgViewArray {
    if (!_imgViewArray) {
        _imgViewArray = [NSMutableArray array];
    }
    return _imgViewArray;
}

- (UIImageView *)singleImgView {
    CGFloat width = (KLRScreenWidth - 30 - 4*2) / 3;
    CGFloat height = 75.0/112.0*width;
    UIImageView *singleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.titleLabel.lr_bottom + 12, width, height)];
    singleImgView.layer.cornerRadius = 4;
    singleImgView.layer.masksToBounds = YES;
    singleImgView.backgroundColor = FLSRGBValue(0xc1c1c1);
    return singleImgView;
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
    
    self.titleLabel.lr_width = KLRScreenWidth - 30;
    CGRect frame = self.titleLabel.frame;
    [self.titleLabel sizeToFit];
    frame.size.height = self.titleLabel.lr_height;
    self.titleLabel.frame = frame;
    
    self.descLabel.text = model.leftBottom;
    if (model.images && [model.images count] == 3) {
        for (int i=0; i<model.images.count; i++) {
            if (i >= 3) {
                break;
            }
            UIImageView *imgView = self.imgViewArray[i];
            [imgView lr_setImageWithURL:[NSURL URLWithString:model.images[i]]];
            imgView.lr_top = self.titleLabel.lr_bottom + 12;
            self.descLabel.lr_top = imgView.lr_bottom + 10;
        }
    }
    
    self.line.lr_top = self.descLabel.lr_bottom + 9;
}

- (CGFloat)heightForImage {
    CGFloat width = (KLRScreenWidth - 30 - 4*2) / 3;
    return 75.0/112.0*width;
}

+ (CGFloat)cellHeightWith:(HHFlsNewsModel *)model {
    CGFloat width = (KLRScreenWidth - 30 - 4*2) / 3;
    CGFloat height = 75.0/112.0*width;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, KLRScreenWidth - 30, 16*KFLSDeviceWidthScale)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
    titleLabel.text = model.title;
    [titleLabel sizeToFit];
    return 18 + titleLabel.lr_height + 12 + height + 10*2 + 12;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
