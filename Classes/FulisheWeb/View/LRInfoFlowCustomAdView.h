//
//  LRInfoFlowCustomAdView.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/18.
//

#import "GDTUnifiedNativeAdView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^lrInfoFlowImageLaunched)(CGSize adViewSize);

@interface LRInfoFlowCustomAdView : GDTUnifiedNativeAdView

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
