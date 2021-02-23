//
//  HHFlsNewsModel.h
//  importevent
//
//  Created by 张维凡 on 2020/11/6.
//  Copyright © 2020 lanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDTUnifiedNativeAdDataObject.h"
#import "HHFlsAdModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHFlsNewsModel : NSObject

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *aid;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) NSInteger imgCount;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *leftBottom;
@property (nonatomic, copy) NSString *rightBottom;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *adModel;

@property (nonatomic, strong) HHFlsAdModel *advertModel;
@property (nonatomic, strong) UIView *adView;

@end

NS_ASSUME_NONNULL_END
