//
//  HHFlsAdCell.h
//  importevent
//
//  Created by 张维凡 on 2020/11/6.
//  Copyright © 2020 lanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHFlsNewsModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHAdClickBlock)(void);

@interface HHFlsAdCell : UITableViewCell

@property (nonatomic, copy) HHAdClickBlock adClickBlock;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupController:(UIViewController *)controller data:(GDTUnifiedNativeAdDataObject *)adModel;
+ (CGFloat)cellHeightWith:(HHFlsNewsModel *)model adModel:(GDTUnifiedNativeAdDataObject *)adModel;

- (void)setupController:(UIViewController *)controller adView:(UIView *)adView;

@end

NS_ASSUME_NONNULL_END
