//
//  HHFlsNewsImgsCell.h
//  importevent
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHFlsNewsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHFlsNewsImgsCell : UITableViewCell

- (void)setupData:(HHFlsNewsModel *)model;
+ (CGFloat)cellHeightWith:(HHFlsNewsModel *)model;

@end

NS_ASSUME_NONNULL_END
