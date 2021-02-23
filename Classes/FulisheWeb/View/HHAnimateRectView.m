//
//  HHAnimateRectView.m
//  AdFulishe
//
//  Created by 张维凡 on 2020/11/25.
//

#import "HHAnimateRectView.h"
#import "HHHeader.h"

@interface HHAnimateRectView ()

@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) CAShapeLayer *animateLayer;

@end

@implementation HHAnimateRectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (UIImageView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _bubbleView.center = CGPointMake(0, 0);
        [_bubbleView setAnimationImages:[self imagesArray]];
        [_bubbleView setAnimationDuration:0.5];
        [_bubbleView startAnimating];
    }
    return _bubbleView;
}

- (NSArray *)imagesArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        NSString *name = [NSString stringWithFormat:@"FulisheAdBundle.bundle/adv_sparkling_0%@", @(i+1)];
        UIImage *image = [UIImage imageNamed:name];
        [array addObject:image];
    }
    return array;
}

- (void)clearAnimateLayer {
    if (_animateLayer) {
        [_animateLayer removeFromSuperlayer];
        _animateLayer = nil;
    }
    [self.bubbleView removeFromSuperview];
}

- (void)setupAnimateLayer {
    NSLog(@"--------------------------%@", NSStringFromCGRect(self.frame));
    if (_animateLayer == nil && self.lr_width > 0) {
        _animateLayer = [CAShapeLayer layer];
        _animateLayer.fillColor = [UIColor clearColor].CGColor;
        _animateLayer.lineWidth =  5.0f;
        _animateLayer.cornerRadius = 10;
        _animateLayer.lineCap = kCALineCapRound;
        _animateLayer.lineJoin = kCALineJoinRound;
        _animateLayer.strokeColor = [UIColor yellowColor].CGColor;
        [self.layer addSublayer:_animateLayer];

        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(self.lr_width, 0)];
        [path addLineToPoint:CGPointMake(self.lr_width, self.lr_height)];
        [path addLineToPoint:CGPointMake(0, self.lr_height)];
        [path addLineToPoint:CGPointMake(0, 0)];
        _animateLayer.path = path.CGPath;

        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
        animation.values = @[@(0.0f),@(1.0f)];
        animation.duration = 3;
        animation.removedOnCompletion = NO;
        animation.repeatCount = CGFLOAT_MAX;
        animation.calculationMode = kCAAnimationPaced;
        [_animateLayer addAnimation:animation forKey:nil];
        _animateLayer.strokeEnd = 1;
        
        /* 移动 */
        UIBezierPath *imagePath = [UIBezierPath bezierPath];
        [imagePath moveToPoint:CGPointMake(0, 0)];
        [imagePath addLineToPoint:CGPointMake(self.lr_width, 0)];
        [imagePath addLineToPoint:CGPointMake(self.lr_width, self.lr_height)];
        [imagePath addLineToPoint:CGPointMake(0, self.lr_height)];
        [imagePath addLineToPoint:CGPointMake(0, 0)];
        
        CAKeyframeAnimation *imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        imageAnimation.path = imagePath.CGPath;
        imageAnimation.duration = 3;
        imageAnimation.repeatCount = CGFLOAT_MAX;
        imageAnimation.removedOnCompletion = NO;
        imageAnimation.calculationMode = kCAAnimationPaced;
        [_bubbleView.layer addAnimation:imageAnimation forKey:@"move-layer"];
    }
    [self addSubview:self.bubbleView];
}

@end
