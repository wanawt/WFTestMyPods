//
//  LRDismissAnimation.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/13.
//

#import "LRDismissAnimation.h"
#import "HHHeader.h"

@implementation LRDismissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.backgroundColor = FLSRGBAValue(0x000000, 0);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
