//
//  LRInfoFlowView.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/22.
//

#import "LRInfoFlowView.h"
#import "GDTUnifiedNativeAdView.h"
#import "UIImageView+AFLRNetworking.h"
#import "UIView+LRAddition.h"
#import "LRAdvertLog.h"
#import "HHHeader.h"
#import <KSAdSDK/KSAdSDK.h>

@interface LRInfoFlowView ()

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) GDTVideoConfig *videoConfig;
@property (nonatomic, strong) KSNativeAdRelatedView *relatedView;

@property (nonatomic, strong) UILabel *adTitleLabel;
@property (nonatomic, strong) UILabel *adDescLabel;
@property (nonatomic, strong) UILabel *buttonLabel;
@property (nonatomic, strong) UIImageView *buttonImageView;
@property (nonatomic, assign) CGFloat sideGap;

@end

@implementation LRInfoFlowView

- (instancetype)init {
    if (self = [super init]) {
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
        self.backgroundColor = FLSRGBValue(0xffffff);
        self.sideGap = 15*KFLSDeviceWidthScale;
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.sideGap, 0, self.lr_width - self.sideGap*2, 9.0/16.0*self.lr_width)];
        _imageView.layer.masksToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (UILabel *)adTitleLabel {
    if (!_adTitleLabel) {
        _adTitleLabel = [[UILabel alloc] init];
        _adTitleLabel.textColor = FLSRGBValue(0x333333);
        _adTitleLabel.font = [UIFont systemFontOfSize:16*KFLSDeviceWidthScale];
    }
    return _adTitleLabel;
}

- (UILabel *)adDescLabel {
    if (!_adDescLabel) {
        _adDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.lr_left, 0, self.lr_width - self.buttonLabel.lr_width - 10 - 15, 30)];
        _adDescLabel.textColor = FLSRGBValue(0x999999);
        _adDescLabel.numberOfLines = 1;
        _adDescLabel.font = [UIFont systemFontOfSize:11*KFLSDeviceWidthScale];
    }
    return _adDescLabel;
}

- (UILabel *)buttonLabel {
    if (!_buttonLabel) {
        CGFloat width = 62*KFLSDeviceWidthScale;
        _buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.lr_right - width, 0, width, 20*KFLSDeviceWidthScale)];
        _buttonLabel.textColor = FLSRGBValue(0xD8342D);
        _buttonLabel.font = [UIFont systemFontOfSize:11*KFLSDeviceWidthScale];
        _buttonLabel.layer.cornerRadius = _buttonLabel.lr_height/2;
        _buttonLabel.layer.borderColor = FLSRGBValue(0xD8342D).CGColor;
        _buttonLabel.layer.borderWidth = 0.5;
        _buttonLabel.textAlignment = NSTextAlignmentCenter;
        _buttonLabel.text = @"立即下载";
    }
    return _buttonLabel;
}

- (UIImageView *)buttonImageView {
    if (!_buttonImageView) {
        CGFloat width = 62*KFLSDeviceWidthScale;
        _buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.imageView.lr_right - width, 0, width, 20*KFLSDeviceWidthScale)];
        [_buttonImageView setImage:[UIImage imageNamed:@"FulisheAdBundle.bundle/lr_infoflow_detail_btn"]];
    }
    return _buttonImageView;
}

- (void)setupVideoConfig {
    self.videoConfig = [[GDTVideoConfig alloc] init];
    self.videoConfig.videoMuted = NO;
    self.videoConfig.autoPlayPolicy = GDTVideoAutoPlayPolicyAlways;
    self.videoConfig.userControlEnable = YES;
    self.videoConfig.autoResumeEnable = NO;
    self.videoConfig.detailPageEnable = NO;
}

- (void)registerClickableViews:(NSArray *)views {
    self.adTitleLabel.numberOfLines = 2;
    self.adTitleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.adTitleLabel.frame = CGRectMake(self.imageView.lr_left, 14, self.lr_width - self.sideGap*2, 1000);

    HHWeakSelf
    if ([self.adView isKindOfClass:[GDTUnifiedNativeAdView class]] &&
        [self.adData isKindOfClass:[GDTUnifiedNativeAdDataObject class]]) {
        GDTUnifiedNativeAdView *tmpAdView = (GDTUnifiedNativeAdView *)self.adView;
        GDTUnifiedNativeAdDataObject *tmpAdData = (GDTUnifiedNativeAdDataObject *)self.adData;
        
        [self setupButtonLabelWithGDT:tmpAdData];
        [self setupVideoConfig];
        
        if (![tmpAdView.subviews containsObject:self.adTitleLabel]) {
            [tmpAdView addSubview:self.adTitleLabel];
            [tmpAdView addSubview:self.adDescLabel];
            [tmpAdView addSubview:self.buttonLabel];
        }
        
        // 广告标题
        self.adTitleLabel.text = self.adTitle;
        [self.adTitleLabel lr_fitHeight];
        
        // 广告详情
        self.adDescLabel.text = self.adDesc;
        [self.adDescLabel lr_fitHeight];
        
        if (tmpAdData.isVideoAd || tmpAdData.isVastAd) {
            tmpAdView.mediaView.frame = CGRectMake(self.sideGap, self.adTitleLabel.lr_bottom + 11*KFLSDeviceWidthScale, self.lr_width - self.sideGap*2, 9.0/16.0*(self.lr_width - self.sideGap*2));
            LRLog(@"GDT->信息流->视频->%@", tmpAdData.desc);
            self.adDescLabel.lr_top = tmpAdView.mediaView.lr_bottom + 15*KFLSDeviceWidthScale;
            self.buttonLabel.lr_top = tmpAdView.mediaView.lr_bottom + 11*KFLSDeviceWidthScale;
            tmpAdView.logoView.lr_bottom = tmpAdView.mediaView.lr_bottom;
            tmpAdView.logoView.lr_right = tmpAdView.mediaView.lr_right;
        } else if (tmpAdData.isThreeImgsAd) {
            LRLog(@"GDT->信息流->多图->%@", tmpAdData.desc);
            [self.imageViews removeAllObjects];
            if (tmpAdData.mediaUrlList.count > 0) {
                CGFloat positionY = self.adTitleLabel.lr_bottom + 11;
                CGFloat width = (KLRScreenWidth - (tmpAdData.mediaUrlList.count + 1)*5)/tmpAdData.mediaUrlList.count;
                NSInteger count = 0;
                for (NSString *urlString in tmpAdData.mediaUrlList) {
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(count*width + 5*count, positionY, width, width)];
                    [imgView lr_setImageWithURL:[NSURL URLWithString:urlString]];
                    [self.imageViews addObject:imgView];
                    [tmpAdView addSubview:imgView];
                    count++;
                }
                
                self.adDescLabel.lr_top = positionY + width + 15*KFLSDeviceWidthScale;
                self.buttonLabel.lr_top = positionY + width + 11*KFLSDeviceWidthScale;
            } else {
                LRLog(@"GDT->信息流->多图->图片数据为空");
            }
            tmpAdView.logoView.lr_bottom = self.imageView.lr_bottom;
        } else {
            LRLog(@"GDT->信息流->图片->%@", tmpAdData.desc);
            [self.imageView lr_setImageWithURL:[NSURL URLWithString:tmpAdData.imageUrl]];
            self.imageView.lr_top = self.adTitleLabel.lr_bottom + 11;
            self.adDescLabel.lr_top = self.imageView.lr_bottom + 15*KFLSDeviceWidthScale;
            self.buttonLabel.lr_top = self.imageView.lr_bottom + 11*KFLSDeviceWidthScale;
            [tmpAdView addSubview:self.imageView];
            tmpAdView.logoView.lr_bottom = self.imageView.lr_bottom;
            tmpAdView.logoView.lr_right = self.imageView.lr_right;
        }
        tmpAdView.lr_height = self.buttonLabel.lr_bottom + 10;
        self.lr_height = tmpAdView.lr_bottom;
        [tmpAdView bringSubviewToFront:tmpAdView.logoView];
        
        NSMutableArray *tmpArray = [views mutableCopy];
        [tmpArray insertObject:self.imageView atIndex:0];
        [tmpArray addObject:self.adDescLabel];
        [tmpArray addObject:self.buttonLabel];
        [tmpAdView registerDataObject:tmpAdData clickableViews:tmpArray];
    } else if ([self.adData isKindOfClass:[KSNativeAd class]]) {
        self.relatedView = [KSNativeAdRelatedView new];
        KSNativeAd *nativeAd = (KSNativeAd *)self.adData;
        [self setupButtonLabelWithKS:nativeAd];
        
        KSAdImage *logoImage = nativeAd.data.sdkLogo;
        UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage.image];
        CGFloat logoWidth = 20;

        [self addSubview:self.adTitleLabel];
        [self addSubview:self.adDescLabel];
        [self addSubview:self.buttonLabel];
        
        // 广告标题
        self.adTitleLabel.text = self.adTitle;
        [self.adTitleLabel lr_fitHeight];
        
        // 广告详情
        self.adDescLabel.text = self.adDesc;
        [self.adDescLabel lr_fitHeight];
        
        if (nativeAd.data.materialType == KSAdMaterialTypeVideo) {
            LRLog(@"KS->信息流->视频->%@", nativeAd);
            KSVideoAdView *videoAdView = self.relatedView.videoAdView;
            videoAdView.frame = CGRectMake(self.sideGap, self.adTitleLabel.lr_bottom + 11, self.lr_width - self.sideGap*2, 9.0/16.0*self.lr_width);
            [self ksRefreshViewsWithPositionY:videoAdView.lr_bottom];
            videoAdView.videoSoundEnable = YES;
            [self addSubview:videoAdView];
            [nativeAd registerContainer:self withClickableViews:@[self.adDescLabel, self.adTitleLabel, self.buttonLabel]];
            nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            logoView.frame = CGRectMake(videoAdView.lr_right - logoWidth, videoAdView.lr_bottom - logoWidth - 5, logoWidth, logoWidth);
            [self addSubview:logoView];
        } else if (nativeAd.data.materialType == KSAdMaterialTypeSingle) {
            LRLog(@"KS->信息流->图片->%@", nativeAd);
            [self.imageView lr_setImageWithURL:[NSURL URLWithString:nativeAd.data.imageArray.firstObject.imageURL] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                [weakSelf ksRefreshViewsWithPositionY:weakSelf.imageView.lr_bottom];
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {}];
            self.adView = self.imageView;
            [self addSubview:self.imageView];
            NSMutableArray *tmpArray = [views mutableCopy];
            [tmpArray addObjectsFromArray:@[self.adDescLabel, self.adTitleLabel, self.buttonLabel]];
            [nativeAd registerContainer:self withClickableViews:tmpArray];
            
            self.imageView.lr_top = self.adTitleLabel.lr_bottom + 11;
            [self ksRefreshViewsWithPositionY:self.imageView.lr_bottom];
            
            logoView.frame = CGRectMake(self.imageView.lr_right - logoWidth, self.imageView.lr_bottom - logoWidth - 5, logoWidth, logoWidth);
            [self addSubview:logoView];
        }
        for (UIView *itemView in views) {
            [self addSubview:itemView];
        }
        [self.relatedView refreshData:nativeAd];
    }
    self.isRegisterdClickableViews = YES;
}

- (void)ksRefreshViewsWithPositionY:(CGFloat)positionY {
    self.adDescLabel.lr_top = positionY + 15*KFLSDeviceWidthScale;
    self.buttonLabel.lr_top = positionY + 11*KFLSDeviceWidthScale;
    self.buttonImageView.lr_top = positionY + 11*KFLSDeviceWidthScale;
    self.lr_height = self.buttonLabel.lr_bottom + 10;
}

- (void)registerSmallClickableViews:(NSArray *)views {
    if ([self.adView isKindOfClass:[GDTUnifiedNativeAdView class]] &&
        [self.adData isKindOfClass:[GDTUnifiedNativeAdDataObject class]]) {
        // 广点通
        GDTUnifiedNativeAdView *tmpAdView = (GDTUnifiedNativeAdView *)self.adView;
        GDTUnifiedNativeAdDataObject *tmpAdData = (GDTUnifiedNativeAdDataObject *)self.adData;
        [self setupButtonLabelWithGDT:tmpAdData];
        
        if (tmpAdView.mediaView) {
            tmpAdView.mediaView.frame = CGRectMake(10, 9, 75, 42);
        }
        
        [self.imageView lr_setImageWithURL:[NSURL URLWithString:tmpAdData.imageUrl]];
        self.imageView.frame = CGRectMake(10, 9, 75, 42);
        
        NSMutableArray *tmpArray = [views mutableCopy];
        [tmpArray insertObject:self.imageView atIndex:0];
        
        // 查看详情
        CGFloat btnWidth = 70*KFLSDeviceWidthScale;
        CGFloat btnHeight = 25*KFLSDeviceWidthScale;
        UILabel *btnLabel = [self buttonLabelWithFrame:CGRectMake(self.lr_width - 10 - btnWidth, 17.5*KFLSDeviceWidthScale, btnWidth, btnHeight)];
        
        // 标题
        UILabel *titleLabel = [self titleLabelWithFrame:CGRectMake(self.imageView.lr_right+8, self.imageView.lr_top, btnLabel.lr_left - 10 - self.imageView.lr_right - 10, 14)];
        titleLabel.text = tmpAdData.title;
        
        // 子标题
        UILabel *detailLabel = [self detailLabelWithFrame:CGRectMake(self.imageView.lr_right+8, self.imageView.lr_bottom - 12, btnLabel.lr_left - 10 - self.imageView.lr_right - 10 - 70, 10)];
        detailLabel.text = tmpAdData.desc;
        
        // 广告类型
        UILabel *typeLabel = [self detailLabelWithFrame:CGRectMake(detailLabel.lr_right + 10, detailLabel.lr_top, 60, detailLabel.lr_height)];
        typeLabel.text = @"广点通广告";
        
        [tmpAdView addSubview:btnLabel];
        [tmpAdView addSubview:titleLabel];
        [tmpAdView addSubview:detailLabel];
        [tmpAdView addSubview:typeLabel];
        [tmpArray addObjectsFromArray:@[detailLabel, titleLabel, btnLabel, typeLabel]];
        [tmpAdView registerDataObject:tmpAdData clickableViews:tmpArray];
        
        [tmpAdView addSubview:self.imageView];
        [tmpAdView bringSubviewToFront:tmpAdView.logoView];
    } else if ([self.adData isKindOfClass:[KSNativeAd class]]) {
        // 快手
        UIView *tmpPositionView;
        self.relatedView = [KSNativeAdRelatedView new];
        KSNativeAd *nativeAd = (KSNativeAd *)self.adData;
        [self setupButtonLabelWithKS:nativeAd];
        
        if (nativeAd.data.materialType == KSAdMaterialTypeSingle) {
            [self.imageView lr_setImageWithURL:[NSURL URLWithString:nativeAd.data.imageArray.firstObject.imageURL]];
            self.imageView.frame = CGRectMake(10, 9, 75, 42);
            self.adView = self.imageView;
            [self addSubview:self.imageView];
            tmpPositionView = self.imageView;
        } else {
            self.relatedView.videoAdView.frame = CGRectMake(10, 9, 75, 42);
            self.relatedView.videoAdView.videoSoundEnable = NO;
            [self addSubview:self.relatedView.videoAdView];
            nativeAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            tmpPositionView = self.relatedView.videoAdView;
        }
        
        NSMutableArray *tmpArray = [views mutableCopy];
        // 查看详情
        CGFloat btnWidth = 70*KFLSDeviceWidthScale;
        CGFloat btnHeight = 25*KFLSDeviceWidthScale;
        UILabel *btnLabel = [self buttonLabelWithFrame:CGRectMake(self.lr_width - 10 - btnWidth, 17.5*KFLSDeviceWidthScale, btnWidth, btnHeight)];
        
        // 标题
        UILabel *titleLabel = [self titleLabelWithFrame:CGRectMake(tmpPositionView.lr_right+8, tmpPositionView.lr_top, btnLabel.lr_left - 10 - tmpPositionView.lr_right - 10, 14)];
        titleLabel.text = self.adTitle;
        
        // 子标题
        UILabel *detailLabel = [self detailLabelWithFrame:CGRectMake(tmpPositionView.lr_right+8, tmpPositionView.lr_bottom - 12, btnLabel.lr_left - 10 - tmpPositionView.lr_right - 10 - 70, 10)];
        detailLabel.text = self.adDesc;
        
        // 广告类型
        UILabel *typeLabel = [self detailLabelWithFrame:CGRectMake(detailLabel.lr_right + 10, detailLabel.lr_top, 60, detailLabel.lr_height)];
        typeLabel.text = @"快手广告";
        
        [self addSubview:btnLabel];
        [self addSubview:titleLabel];
        [self addSubview:detailLabel];
        [self addSubview:typeLabel];
        [tmpArray addObjectsFromArray:@[detailLabel, titleLabel, btnLabel, typeLabel]];
        
        [nativeAd registerContainer:self withClickableViews:tmpArray];
        [self.relatedView refreshData:nativeAd];
    }
    self.isRegisterdClickableViews = YES;
}

- (UILabel *)buttonLabelWithFrame:(CGRect)frame {
    UILabel *btnLabel = [[UILabel alloc] initWithFrame:frame];
    btnLabel.text = @"查看详情";
    btnLabel.textAlignment = NSTextAlignmentCenter;
    btnLabel.font = [UIFont systemFontOfSize:12*KFLSDeviceWidthScale];
    btnLabel.backgroundColor = FLSRGBValue(0x2E93FF);
    btnLabel.textColor = FLSRGBValue(0xffffff);
    btnLabel.layer.cornerRadius = frame.size.height / 2;
    btnLabel.layer.masksToBounds = YES;
    return btnLabel;
}

- (UILabel *)titleLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:14*KFLSDeviceWidthScale];
    label.textColor = FLSRGBValue(0x333333);
    return label;
}

- (UILabel *)detailLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:10*KFLSDeviceWidthScale];
    label.textColor = FLSRGBValue(0x999999);
    return label;
}

- (void)setupButtonLabelWithGDT:(GDTUnifiedNativeAdDataObject *)adData {
    if (adData.isAppAd) {
        [self.buttonLabel setText:@"立即下载"];
    } else {
        [self.buttonLabel setText:@"立即打开"];
    }
}

- (void)setupButtonLabelWithKS:(KSNativeAd *)nativeAd {
    if (nativeAd.data.interactionType == KSAdInteractionType_App) {
        self.buttonLabel.text = @"立即下载";
    } else {
        self.buttonLabel.text = @"立即打开";
    }
}

@end
