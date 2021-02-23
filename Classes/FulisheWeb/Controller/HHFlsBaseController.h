//
//  HHFlsBaseController.h
//  hhsqad
//
//  Created by 张维凡 on 2020/11/4.
//

#import <UIKit/UIKit.h>
#import "LRPresentAnimation.h"
#import "LRDismissAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHFlsBaseController : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) LRPresentAnimation *presentAnimation;
@property (nonatomic, strong) LRDismissAnimation *dismissAnimation;

- (void)setupCustomNavbar;
- (void)setupCustomNavbarWithLine;
- (void)hh_backAction;
- (void)hh_setupTitle:(NSString *)title;

- (void)showLoading;
- (void)showErrorWithMsg:(NSString *)msg;
- (void)hideLoading;
- (void)hideLoadingWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
