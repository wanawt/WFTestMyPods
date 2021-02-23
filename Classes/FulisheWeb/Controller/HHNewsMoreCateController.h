//
//  HHNewsMoreCateController.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/13.
//

#import <AdFulishe/AdFulishe.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^moreCateSelectBlock)(NSInteger index);

@interface HHNewsMoreCateController : HHFlsBaseController

@property (nonatomic, copy) moreCateSelectBlock moreCateSelectBlock;
@property (nonatomic, strong) NSArray *cateArray;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

NS_ASSUME_NONNULL_END
