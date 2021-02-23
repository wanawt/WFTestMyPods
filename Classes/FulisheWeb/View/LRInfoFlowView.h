//
//  LRInfoFlowView.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRInfoFlowView : UIView

@property (nonatomic, copy) NSString *adTitle;
@property (nonatomic, copy) NSString *adDesc;
@property (nonatomic, copy) NSString *adPlatform;

@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSObject *adData;
@property (nonatomic, assign) BOOL isRegisterdClickableViews;
@property (nonatomic, assign) BOOL canRegisterClickableViews;       // 最大
@property (nonatomic, assign) BOOL canRegisterClickableSmallViews;  // 最小
@property (nonatomic, assign) BOOL canRegisterClickableTipViews;    // 弹窗

/// 列表信息流
- (void)registerClickableViews:(NSArray *)views;

/// 弹窗信息流
- (void)registerClickableTipViews:(NSArray *)views;

/// 新闻详情底部信息流
- (void)registerSmallClickableViews:(NSArray *)views;

@end

NS_ASSUME_NONNULL_END
