//
//  HHFlsAdCell.m
//  importevent
//
//  Created by 张维凡 on 2020/11/6.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "HHFlsAdCell.h"

#import <WebKit/WebKit.h>
#import "HHHeader.h"
#import "UnifiedNativeAdCustomView.h"
#import "UIImageView+AFLRNetworking.h"

@interface HHFlsAdCell () <GDTUnifiedNativeAdViewDelegate>

// 信息流广告
@property (nonatomic, strong) GDTUnifiedNativeAdView *adBgView;
@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) UILabel *adTextLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *buttonLabel;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) HHFlsNewsModel *model;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *imgTextAd;

@end

@implementation HHFlsAdCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.adBgView];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 299 - 1, KLRScreenWidth, 0.5)];
        self.line.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1];
        [self.contentView addSubview:self.line];
    }
    return self;
}

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self.contentView addSubview:self.adBgView];
//
//        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 299 - 1, KLRScreenWidth, 0.5)];
//        self.line.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1];
////        [self.contentView addSubview:self.line];
//    }
//    return self;
//}

- (GDTUnifiedNativeAdView *)adBgView {
    if (!_adBgView) {
        _adBgView = [[GDTUnifiedNativeAdView alloc] init];
        _adBgView.frame = CGRectMake(0, 0, KLRScreenWidth, 300);
        _adBgView.delegate = self;
        [_adBgView addSubview:self.titleLabel];
        [_adBgView addSubview:self.adImageView];
        [_adBgView addSubview:self.adTextLabel];
        [_adBgView addSubview:self.buttonLabel];
    }
    return _adBgView;
}

- (UIImageView *)adImageView {
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.titleLabel.lr_bottom+12, KLRScreenWidth - 30, 194)];
        _adImageView.layer.cornerRadius = 8;
        _adImageView.layer.masksToBounds = YES;
        _adImageView.backgroundColor = KLRColorWhite;
    }
    return _adImageView;
}

- (UILabel *)adTextLabel {
    if (!_adTextLabel) {
        _adTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.adImageView.lr_bottom, KLRScreenWidth- 30 - 65, 45)];
        _adTextLabel.font = [UIFont systemFontOfSize:14];
        _adTextLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
    }
    return _adTextLabel;
}

- (UILabel *)buttonLabel {
    if (!_buttonLabel) {
        _buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.adImageView.lr_right - 60, self.adImageView.lr_bottom+10, 60, 20)];
        _buttonLabel.font = [UIFont systemFontOfSize:11];
        _buttonLabel.text = @"立即下载";
        _buttonLabel.textColor = [UIColor colorWithRed:241.0/255.0 green:38.0/255.0 blue:21.0/255.0 alpha:1];
        _buttonLabel.textAlignment = NSTextAlignmentCenter;
        _buttonLabel.layer.cornerRadius = 10;
        _buttonLabel.layer.borderWidth = 0.5;
        _buttonLabel.layer.borderColor = [UIColor colorWithRed:241.0/255.0 green:38.0/255.0 blue:21.0/255.0 alpha:1].CGColor;
    }
    return _buttonLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, KLRScreenWidth - 30, 16*KFLSDeviceWidthScale)];
        _titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (void)setupController:(nonnull UIViewController *)controller data:(nonnull GDTUnifiedNativeAdDataObject *)adModel {
    _controller = controller;
    _imgTextAd = adModel;
    [self showImageText];
}

- (void)showImageText {
    if (self.imgTextAd) {
//        [self.imgTextAd unRegistAdContainer];
        self.adBgView.hidden = NO;
        self.line.hidden = NO;
    } else {
        self.adBgView.hidden = YES;
        self.line.hidden = YES;
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    self.adBgView.viewController = self.controller; // 设置点击跳转的 VC
    [self.adBgView registerDataObject:self.imgTextAd clickableViews:@[self.adImageView, self.titleLabel, self.adTextLabel, self.buttonLabel]];
    
//    //此处略去其它广告元素的创建，请开发者参考Demo或者自行创建
//    /*定义视频媒体视图*/
//    // 配置视频播放属性
//    self.videoConfig = [[GDTVideoConfig alloc] init];
//    self.videoConfig.videoMuted = NO;
//    self.videoConfig.autoPlayPolicy = GDTVideoAutoPlayPolicyAlways;
//    self.videoConfig.userControlEnable = YES;
//    self.videoConfig.autoResumeEnable = NO;
//    self.videoConfig.detailPageEnable = NO;
    
    
    NSMutableArray *array = @[].mutableCopy;
    [array addObjectsFromArray:@[self.adImageView, self.adTextLabel, self.titleLabel, self.buttonLabel]];
//    [self.imgTextAd registerAdContainer:self.adBgView ableClickViews:array presentVC:self.controller];
    
    [self.adImageView lr_setImageWithURL:[NSURL URLWithString:self.imgTextAd.imageUrl] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        NSLog(@"setImage success:----%@, %@, %@", request, response, image);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"setImage fail:----%@, %@, %@", request, response, error);
    }];
    
    self.adTextLabel.text = self.imgTextAd.title ? : @"";
    self.titleLabel.text = self.imgTextAd.desc ?:@"";
    
    self.titleLabel.lr_width = KLRScreenWidth - 30;
    CGRect frame = self.titleLabel.frame;
    [self.titleLabel sizeToFit];
    frame.size.height = self.titleLabel.lr_height;
    self.titleLabel.frame = frame;
    self.adImageView.lr_top = self.titleLabel.lr_bottom + 12;
    self.adTextLabel.lr_top = self.adImageView.lr_bottom;
    self.buttonLabel.lr_top = self.adImageView.lr_bottom + 10;
    
//    XMAdImage *image = self.imgTextAd.coverImage;
//    CGFloat radio = image.imgWidth / CGRectGetWidth(self.adImageView.frame);
//    CGFloat imageHeight = image.imgHeight / radio;
    self.adImageView.hidden = NO;
    self.line.lr_top = self.adTextLabel.lr_bottom;
    self.adBgView.lr_height = self.line.lr_bottom;
    self.contentView.lr_height = self.adBgView.lr_height;
    self.lr_height = self.adBgView.lr_height;
}

+ (CGFloat)cellHeightWith:(HHFlsNewsModel *)model adModel:(nonnull GDTUnifiedNativeAdDataObject *)adModel {
    if (adModel == nil || adModel.title == nil) {
        return 0.01;
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, KLRScreenWidth - 30, 16*KFLSDeviceWidthScale)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
    titleLabel.text = adModel.desc;
    [titleLabel sizeToFit];
    CGFloat height = 14 + titleLabel.lr_height + 12 + 194 + 45;
    return height;
}

/**
 广告曝光回调

 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView  {
    
}


/**
 广告点击回调

 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}


/**
 广告详情页关闭回调

 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    if (self.adClickBlock) {
        self.adClickBlock();
    }
}


/**
 当点击应用下载或者广告调用系统程序打开时调用
 
 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}


/**
 广告详情页面即将展示回调

 @param unifiedNativeAdView GDTUnifiedNativeAdView 实例
 */
- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}


/**
 视频广告播放状态更改回调

 @param nativeExpressAdView GDTUnifiedNativeAdView 实例
 @param status 视频广告播放状态
 @param userInfo 视频广告信息
 */
- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
