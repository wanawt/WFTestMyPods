//
//  UIView+LRAddition.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import "UIView+LRAddition.h"

@implementation UIView (LRAddition)

+ (UIWindow *)lr_lastWindow {
    UIWindow *window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate window];
    }
    if (![window isKindOfClass:[UIView class]]) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    return window;
}

- (CGPoint)lr_origin {
    return self.frame.origin;
}

- (void)setLr_origin:(CGPoint)aPoint {
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}

- (CGSize)lr_size {
    return self.frame.size;
}

- (void)setLr_size:(CGSize)aSize {
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

- (CGPoint)lr_bottomRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)lr_bottomLeft {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)lr_topRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

- (CGFloat)lr_height {
    return self.frame.size.height;
}

- (void)setLr_height:(CGFloat)newheight {
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat)lr_width {
    return self.frame.size.width;
}

- (void)setLr_width:(CGFloat)newwidth {
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat)lr_top {
    return self.frame.origin.y;
}

- (void)setLr_top:(CGFloat)newtop {
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}

- (CGFloat)lr_left {
    return self.frame.origin.x;
}

- (void)setLr_left:(CGFloat)newleft {
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (CGFloat)lr_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLr_bottom:(CGFloat)newbottom {
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)lr_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setLr_right:(CGFloat)newright {
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

- (void)setupCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setupCornerRadius:(CGFloat)cornerRadius withBorderWidth:(CGFloat)width borderColor:(UIColor *)color {
    [self setupCornerRadius:cornerRadius];
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)setupCornerRadius:(CGFloat)cornerRadius withType:(UIRectCorner)cornerType {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:cornerType cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)lr_fitWidth {
    CGRect frame = self.frame;
    [self sizeToFit];
    frame.size.width = self.frame.size.width;
    self.frame = frame;
}

- (void)lr_fitHeight {
    CGRect frame = self.frame;
    [self sizeToFit];
    frame.size.height = self.frame.size.height;
    self.frame = frame;
}

- (void)addTopShadowLineWithColor:(UIColor *)theColor {
    self.layer.shadowColor = theColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 5;
    // 单边阴影 顶边
    float shadowPathWidth = self.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, self.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    self.layer.shadowPath = path.CGPath;
}

@end
