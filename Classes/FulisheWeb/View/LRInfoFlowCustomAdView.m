//
//  LRInfoFlowCustomAdView.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/18.
//

#import "LRInfoFlowCustomAdView.h"
#import "HHHeader.h"
#import "UIImageView+AFLRNetworking.h"

@interface LRInfoFlowCustomAdView ()

@property (nonatomic, assign) CGFloat gap;

@end

@implementation LRInfoFlowCustomAdView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        [self addSubview:self.mediaView];
        [self addSubview:self.iconImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.clickButton];
        [self addSubview:self.CTAButton];
    }
    return self;
}

- (instancetype)initWithGap:(CGFloat)gap {
    if (self = [super init]) {
        self.gap = gap;
        self.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        [self addSubview:self.mediaView];
        [self addSubview:self.iconImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.clickButton];
        [self addSubview:self.CTAButton];
    }
    return self;
}

- (void)setupWithUnifiedNativeAdObject:(GDTUnifiedNativeAdDataObject *)unifiedNativeDataObject imageLaunched:(nonnull lrInfoFlowImageLaunched)imageLaunched {
    [self registerDataObject:unifiedNativeDataObject clickableViews:@[self.imageView, self.titleLabel, self.iconImageView]];
    self.titleLabel.text = unifiedNativeDataObject.title;
    self.titleLabel.lr_width = self.lr_width;
    self.descLabel.text = unifiedNativeDataObject.desc;
    self.descLabel.lr_width = self.descLabel.lr_width - 72*KFLSDeviceWidthScale - 10;
    HHWeakSelf
    NSURL *iconURL = [NSURL URLWithString:unifiedNativeDataObject.iconUrl];
    [self.iconImageView lr_setImageWithURL:iconURL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { }];
    
    NSURL *imageURL = [NSURL URLWithString:unifiedNativeDataObject.imageUrl];
    [self.imageView lr_setImageWithURL:imageURL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
            weakSelf.imageView.lr_height = image.size.height/image.size.width*weakSelf.imageView.lr_width;
            weakSelf.iconImageView.lr_top = weakSelf.imageView.lr_bottom + 5;
            weakSelf.lr_height = weakSelf.iconImageView.lr_bottom + 5;
            weakSelf.logoView.lr_bottom = weakSelf.imageView.lr_bottom;
        }
        if (imageLaunched) {
            imageLaunched(CGSizeMake(weakSelf.lr_width, weakSelf.imageView.lr_bottom));
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { }];

    if ([unifiedNativeDataObject.callToAction length] > 0) {
        [self.clickButton setHidden:YES];
        [self.CTAButton setHidden:NO];
        [self.CTAButton setTitle:unifiedNativeDataObject.callToAction forState:UIControlStateNormal];
    } else {
        [self.clickButton setHidden:NO];
        [self.CTAButton setHidden:YES];
        
        if (unifiedNativeDataObject.isAppAd) {
            [self.clickButton setTitle:@"下载" forState:UIControlStateNormal];
        } else {
            [self.clickButton setTitle:@"打开" forState:UIControlStateNormal];
        }
    }
    
    if (unifiedNativeDataObject.isVideoAd || unifiedNativeDataObject.isVastAd) {
        self.mediaView.hidden = NO;
    } else {
        self.mediaView.hidden = YES;
    }
}

- (void)setupDetailButtonWithUrl:(NSString *)url {
    [self.iconImageView lr_setImageWithURL:[NSURL URLWithString:url]];
}

#pragma mark - proerty getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.lr_width, 33)];
        _titleLabel.userInteractionEnabled = YES;
        _titleLabel.textColor = FLSRGBValue(0x333333);
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.accessibilityIdentifier = @"titleLabel_id";
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.titleLabel.lr_bottom, 230*KFLSDeviceWidthScale, 123*KFLSDeviceWidthScale)];
        _imageView.userInteractionEnabled = YES;
        _imageView.layer.cornerRadius = 6;
        _imageView.layer.masksToBounds = YES;
        _imageView.accessibilityIdentifier = @"imageView_id";
    }
    return _imageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.accessibilityIdentifier = @"descLabel_id";
    }
    return _descLabel;
}

- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [[UIButton alloc] init];
        _clickButton.accessibilityIdentifier = @"clickButton_id";
    }
    return _clickButton;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.userInteractionEnabled = YES;
        CGFloat width = 65*KFLSDeviceWidthScale;
        CGFloat height = 22*KFLSDeviceWidthScale;
        _iconImageView.frame = CGRectMake(self.imageView.lr_right - width, self.imageView.lr_bottom - 13, width, height);
        _iconImageView.accessibilityIdentifier = @"iconImageView_id";
    }
    return _iconImageView;
}

- (UIButton *)CTAButton {
    if (!_CTAButton) {
        _CTAButton = [[UIButton alloc] init];
        _CTAButton.accessibilityIdentifier = @"CTAButton_id";
    }
    
    return _CTAButton;
}

@end
