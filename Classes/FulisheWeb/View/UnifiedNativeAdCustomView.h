//
//  UnifiedNativeAdCustomView.h
//  GDTMobApp
//
//  Created by royqpwang on 2019/5/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "GDTUnifiedNativeAdView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^lrInfoFlowImageLaunched)(CGSize adViewSize);

@interface UnifiedNativeAdCustomView : GDTUnifiedNativeAdView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *clickButton;
@property (nonatomic, strong) UIButton *CTAButton;

- (instancetype)initWithGap:(CGFloat)gap;
- (void)setupWithUnifiedNativeAdObject:(GDTUnifiedNativeAdDataObject *)unifiedNativeDataObject imageLaunched:(lrInfoFlowImageLaunched)imageLaunched;
- (void)setupDetailButtonWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
