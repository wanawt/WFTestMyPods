//
//  LRPresentAnimation.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/13.
//

#import "LRPresentAnimation.h"
#import "HHHeader.h"

@implementation LRPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toVC.view];
    
//    toVC.view.backgroundColor = FLSRGBAValue(0x000000, 0);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        toVC.view.backgroundColor = FLSRGBAValue(0x000000, 0.7);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
