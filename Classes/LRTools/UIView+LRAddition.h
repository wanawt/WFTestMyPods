//
//  UIView+LRAddition.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LRAddition)

@property (nonatomic, assign) CGPoint lr_origin;
@property (nonatomic, assign) CGSize lr_size;

@property (nonatomic, assign) CGFloat lr_height;
@property (nonatomic, assign) CGFloat lr_width;

@property (nonatomic, assign) CGFloat lr_top;
@property (nonatomic, assign) CGFloat lr_left;
@property (nonatomic, assign) CGFloat lr_bottom;
@property (nonatomic, assign) CGFloat lr_right;

@property (nonatomic, readonly) CGPoint lr_bottomLeft;
@property (nonatomic, readonly) CGPoint lr_bottomRight;
@property (nonatomic, readonly) CGPoint lr_topRight;

- (void)setupCornerRadius:(CGFloat)cornerRadius;
- (void)setupCornerRadius:(CGFloat)cornerRadius withBorderWidth:(CGFloat)width borderColor:(UIColor *)color;
- (void)setupCornerRadius:(CGFloat)cornerRadius withType:(UIRectCorner)cornerType;

- (void)lr_fitWidth;
- (void)lr_fitHeight;

+ (UIWindow *)lr_lastWindow;

- (void)addTopShadowLineWithColor:(UIColor *)theColor;

@end

NS_ASSUME_NONNULL_END
